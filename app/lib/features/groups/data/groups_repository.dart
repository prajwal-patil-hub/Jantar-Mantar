import 'dart:convert';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/crypto/device_identity_service.dart';
import '../../../core/crypto/e2e_crypto.dart';
import '../../../core/crypto/key_store.dart';
import '../domain/group_models.dart';
import 'groups_repo.dart';

/// Server-backed groups + E2E chat. All encryption happens here on the client;
/// the [SupabaseClient] only ever carries ciphertext and sealed key envelopes.
class GroupsRepository implements GroupsRepo {
  // ignore_for_file: prefer_initializing_formals
  GroupsRepository({
    required SupabaseClient client,
    required E2ECrypto crypto,
    required DeviceIdentityService identity,
    required KeyStore keyStore,
  }) : _client = client,
       _crypto = crypto,
       _identity = identity,
       _keyStore = keyStore;

  final SupabaseClient _client;
  final E2ECrypto _crypto;
  final DeviceIdentityService _identity;
  final KeyStore _keyStore;

  String get _uid => _client.auth.currentUser!.id;

  /// Publish this device's public key so others can seal group keys to it.
  /// Idempotent; call after sign-in and before group actions.
  Future<void> ensureDeviceKeyPublished() async {
    final pub = await _identity.publicKeyBase64();
    await _client.from('device_keys').upsert({
      'user_id': _uid,
      'public_key': pub,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<Group>> myGroups() async {
    final rows = await _client
        .from('groups')
        .select(
          'id, name, description, visibility, group_members(user_id, role, state)',
        )
        .order('created_at');
    return [
      for (final row in List<Map<String, Object?>>.from(rows))
        Group.fromRow(row, myUserId: _uid),
    ];
  }

  @override
  Future<Group> createGroup({
    required String name,
    String? description,
    String visibility = 'hidden',
  }) async {
    await ensureDeviceKeyPublished();

    final inserted = await _client
        .from('groups')
        .insert({
          'name': name,
          'description': description,
          'visibility': visibility,
        })
        .select()
        .single();
    final groupId = inserted['id'] as String;

    // Creator is the first active admin.
    await _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': _uid,
      'role': 'admin',
      'state': 'active',
      'joined_via': 'creator',
    });

    // New group key, sealed to my own device key and cached locally.
    final groupKey = _crypto.generateGroupKey();
    await _cacheGroupKey(groupId, groupKey);
    final myPub = base64Decode(await _identity.publicKeyBase64());
    final sealed = await _crypto.sealGroupKey(
      groupKey: groupKey,
      recipientPublicKey: myPub,
    );
    await _client.from('group_key_envelopes').insert({
      'group_id': groupId,
      'member_user_id': _uid,
      'key_epoch': 1,
      'sealed': sealed,
    });

    return Group(
      id: groupId,
      name: name,
      description: description,
      visibility: visibility,
      myRole: GroupRole.admin,
      myState: MemberState.active,
    );
  }

  @override
  Future<List<GroupMember>> members(String groupId) async {
    final rows = await _client
        .from('group_members')
        .select('user_id, role, state, display_name')
        .eq('group_id', groupId);
    return [
      for (final row in List<Map<String, Object?>>.from(rows))
        GroupMember.fromRow(row),
    ];
  }

  /// Approve a pending member: activate them AND seal the current group key to
  /// their device key so they can decrypt chat.
  @override
  Future<void> approveMember(String groupId, String userId) async {
    final groupKey = await _groupKey(groupId);
    if (groupKey == null) {
      throw StateError('You do not hold this group key yet.');
    }
    final keyRow = await _client
        .from('device_keys')
        .select('public_key')
        .eq('user_id', userId)
        .maybeSingle();
    if (keyRow == null) {
      throw StateError('That member has not published a device key yet.');
    }
    final sealed = await _crypto.sealGroupKey(
      groupKey: groupKey,
      recipientPublicKey: base64Decode(keyRow['public_key'] as String),
    );
    await _client.from('group_key_envelopes').insert({
      'group_id': groupId,
      'member_user_id': userId,
      'key_epoch': 1,
      'sealed': sealed,
    });
    await _client
        .from('group_members')
        .update({'state': 'active'})
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  @override
  Future<List<GroupMessage>> messages(String groupId) async {
    final groupKey = await _groupKey(groupId);
    final rows = await _client
        .from('group_messages')
        .select('id, sender_id, ciphertext, created_at')
        .eq('group_id', groupId)
        .order('created_at');

    final out = <GroupMessage>[];
    for (final row in List<Map<String, Object?>>.from(rows)) {
      String? clear;
      if (groupKey != null) {
        try {
          clear = await _crypto.decryptMessage(
            groupKey: groupKey,
            packed: row['ciphertext'] as String,
          );
        } on Object {
          clear = null; // Tamper / wrong epoch → "can't decrypt" placeholder.
        }
      }
      out.add(
        GroupMessage(
          id: row['id'] as String,
          senderId: row['sender_id'] as String,
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
          decrypted: clear,
          mine: row['sender_id'] == _uid,
        ),
      );
    }
    return out;
  }

  @override
  Future<void> sendMessage(String groupId, String text) async {
    final groupKey = await _groupKey(groupId);
    if (groupKey == null) throw StateError('No group key available.');
    final ciphertext = await _crypto.encryptMessage(
      groupKey: groupKey,
      plaintext: text,
    );
    await _client.from('group_messages').insert({
      'group_id': groupId,
      'ciphertext': ciphertext,
    });
  }

  @override
  Future<List<GroupPin>> pins(String groupId) async {
    final rows = await _client
        .from('group_pins')
        .select('id, type, label, lat, lng, note')
        .eq('group_id', groupId)
        .order('created_at');
    return [
      for (final row in List<Map<String, Object?>>.from(rows))
        GroupPin.fromRow(row),
    ];
  }

  @override
  Future<void> addPin({
    required String groupId,
    required String type,
    required String label,
    required double lat,
    required double lng,
    String? note,
  }) async {
    await _client.from('group_pins').insert({
      'group_id': groupId,
      'type': type,
      'label': label,
      'lat': lat,
      'lng': lng,
      'note': note,
    });
  }

  /// Create a short invite code (default 24h, 10 uses).
  @override
  Future<String> createInvite(String groupId) async {
    final code = _randomCode();
    await _client.from('group_invites').insert({
      'group_id': groupId,
      'code': code,
      'expires_at': DateTime.now()
          .toUtc()
          .add(const Duration(hours: 24))
          .toIso8601String(),
      'max_uses': 10,
    });
    return code;
  }

  /// Join via invite code → creates a PENDING membership (mandatory approval).
  /// Returns the group name for UX.
  @override
  Future<String> joinByCode(String code) async {
    await ensureDeviceKeyPublished();
    final resolved = await _client.rpc<List<dynamic>>(
      'resolve_invite',
      params: {'p_code': code},
    );
    if (resolved.isEmpty) {
      throw StateError('Invite is invalid, expired, or used up.');
    }
    final row = resolved.first as Map<String, Object?>;
    final groupId = row['group_id'] as String;
    await _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': _uid,
      'role': 'member',
      'state': 'pending',
      'joined_via': 'link',
    });
    return row['group_name'] as String;
  }

  // --- group key cache (secure storage) ---

  String _cacheKey(String groupId) => 'group_key_$groupId';

  Future<void> _cacheGroupKey(String groupId, List<int> key) =>
      _keyStore.write(_cacheKey(groupId), base64Encode(key));

  /// The group key: from the local cache, else opened from my sealed envelope.
  Future<List<int>?> _groupKey(String groupId) async {
    final cached = await _keyStore.read(_cacheKey(groupId));
    if (cached != null) return base64Decode(cached);

    final envelope = await _client
        .from('group_key_envelopes')
        .select('sealed')
        .eq('group_id', groupId)
        .eq('member_user_id', _uid)
        .order('key_epoch', ascending: false)
        .limit(1)
        .maybeSingle();
    if (envelope == null) return null;

    final identity = await _identity.loadOrCreate();
    final key = await _crypto.openGroupKey(
      sealed: envelope['sealed'] as String,
      identity: identity,
    );
    await _cacheGroupKey(groupId, key);
    return key;
  }

  static final _rng = Random.secure();
  String _randomCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      8,
      (_) => alphabet[_rng.nextInt(alphabet.length)],
    ).join();
  }
}
