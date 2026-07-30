import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart' show SimpleKeyPair;
import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/crypto/device_identity_service.dart';
import '../../../core/crypto/e2e_crypto.dart';
import '../../../core/crypto/key_store.dart';
import '../../../core/db/app_database.dart';
import '../domain/group_message_payload.dart';
import '../domain/group_models.dart';
import 'group_message_cache.dart';
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
    required GroupMessageCache cache,
  }) : _client = client,
       _crypto = crypto,
       _identity = identity,
       _keyStore = keyStore,
       _cache = cache;

  final SupabaseClient _client;
  final E2ECrypto _crypto;
  final DeviceIdentityService _identity;
  final KeyStore _keyStore;
  final GroupMessageCache _cache;

  String get _uid => _client.auth.currentUser!.id;

  /// Publish this device's public key so others can seal group keys to it.
  /// Idempotent; call after sign-in and before group actions.
  Future<void> ensureDeviceKeyPublished() async {
    final pub = await _identity.publicKeyBase64();
    await _client.from('device_keys').upsert({
      'user_id': _uid,
      'public_key': pub,
      // Ed25519 half (ADR-29): what lets other members verify a message came
      // from this device rather than merely from someone holding the group
      // key. RLS restricts writes to auth.uid(), so nobody can publish a
      // signing key on someone else's behalf.
      'signing_public_key': await _identity.signingPublicKeyBase64(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// The group's roster of Ed25519 signing keys, cached in the OS keystore so
  /// verification still works with no network. Public data, but the keystore
  /// is already wiped by panic-wipe, which is the behaviour we want.
  String _signersKey(String groupId) => 'group_signers_$groupId';

  Future<Map<String, List<int>>> _cachedSigners(String groupId) async {
    final raw = await _keyStore.read(_signersKey(groupId));
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      return {
        for (final entry in map.entries)
          entry.key: base64Decode(entry.value! as String),
      };
    } on Object {
      return {};
    }
  }

  Future<Map<String, List<int>>> _syncSigners(String groupId) async {
    final memberRows = await _client
        .from('group_members')
        .select('user_id')
        .eq('group_id', groupId);
    final ids = [
      for (final row in List<Map<String, Object?>>.from(memberRows))
        row['user_id'] as String,
    ];
    if (ids.isEmpty) return _cachedSigners(groupId);

    final keyRows = await _client
        .from('device_keys')
        .select('user_id, signing_public_key')
        .inFilter('user_id', ids);
    final encoded = <String, String>{
      for (final row in List<Map<String, Object?>>.from(keyRows))
        if (row['signing_public_key'] != null)
          row['user_id'] as String: row['signing_public_key'] as String,
    };
    await _keyStore.write(_signersKey(groupId), jsonEncode(encoded));
    return {
      for (final entry in encoded.entries) entry.key: base64Decode(entry.value),
    };
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
    await _cacheGroupKey(groupId, 1, groupKey);
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
        GroupMember.fromRow(row, myUserId: _uid),
    ];
  }

  /// Approve a pending member: activate them AND seal the current group key to
  /// their device key so they can decrypt chat.
  @override
  Future<void> approveMember(String groupId, String userId) async {
    final keys = await _syncGroupKeys(groupId);
    final epoch = _newestEpoch(keys);
    if (epoch == null) {
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
    // Seal the CURRENT epoch only: a new member gets today's key, never the
    // history that predates them.
    final sealed = await _crypto.sealGroupKey(
      groupKey: keys[epoch]!,
      recipientPublicKey: base64Decode(keyRow['public_key'] as String),
    );
    await _client.from('group_key_envelopes').insert({
      'group_id': groupId,
      'member_user_id': userId,
      'key_epoch': epoch,
      'sealed': sealed,
    });
    await _client
        .from('group_members')
        .update({'state': 'active'})
        .eq('group_id', groupId)
        .eq('user_id', userId);
  }

  /// Remove a member and immediately rotate the group key.
  ///
  /// Returns how many remaining members could NOT be re-keyed because they
  /// have not published a device key — the caller warns about them rather
  /// than letting them silently go dark.
  @override
  Future<int> removeMember(String groupId, String userId) async {
    // Remove first: rotating while they are still a member would just hand
    // them the new key.
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId);
    return rotateGroupKey(groupId);
  }

  /// Mint a new group key at the next epoch and seal it to every remaining
  /// active member.
  ///
  /// This buys **forward secrecy only**: the removed device keeps whatever
  /// ciphertext and keys it already downloaded, which no server-side action
  /// can undo. What it guarantees is that nothing sent from now on is
  /// readable by them.
  Future<int> rotateGroupKey(String groupId) async {
    final keys = await _syncGroupKeys(groupId);
    final nextEpoch = (_newestEpoch(keys) ?? 0) + 1;
    final newKey = _crypto.generateGroupKey();

    final memberRows = await _client
        .from('group_members')
        .select('user_id')
        .eq('group_id', groupId)
        .eq('state', 'active');
    final memberIds = [
      for (final row in List<Map<String, Object?>>.from(memberRows))
        row['user_id'] as String,
    ];
    if (memberIds.isEmpty) return 0;

    final keyRows = await _client
        .from('device_keys')
        .select('user_id, public_key')
        .inFilter('user_id', memberIds);
    final publicKeys = {
      for (final row in List<Map<String, Object?>>.from(keyRows))
        row['user_id'] as String: row['public_key'] as String,
    };

    final envelopes = <Map<String, Object?>>[];
    for (final id in memberIds) {
      final pub = publicKeys[id];
      if (pub == null) continue; // No device key published yet.
      envelopes.add({
        'group_id': groupId,
        'member_user_id': id,
        'key_epoch': nextEpoch,
        'sealed': await _crypto.sealGroupKey(
          groupKey: newKey,
          recipientPublicKey: base64Decode(pub),
        ),
      });
    }
    if (envelopes.isEmpty) {
      throw StateError('No member has a device key to seal the new key to.');
    }

    await _client.from('group_key_envelopes').insert(envelopes);
    await _cacheGroupKey(groupId, nextEpoch, newKey);
    return memberIds.length - envelopes.length;
  }

  /// Local-first: decrypt what is already on the device. No network, so this
  /// is what the chat paints before (and instead of) any request.
  @override
  Future<List<GroupMessage>> cachedMessages(String groupId) async {
    final keys = await _localGroupKeys(groupId);
    final signers = await _cachedSigners(groupId);
    final rows = await _cache.load(groupId);
    final out = <GroupMessage>[];
    for (final row in rows) {
      final opened = await _tryOpen(
        keys[row.keyEpoch],
        row.ciphertext,
        context: _sigContext(groupId, row.keyEpoch),
        senderSigningKey: signers[row.senderId],
      );
      final clear = opened?.plaintext;
      final payload = clear == null ? null : GroupMessagePayload.decode(clear);
      out.add(
        GroupMessage(
          id: row.id,
          senderId: row.senderId,
          createdAt: row.createdAt.toLocal(),
          decrypted: payload?.body,
          mine: row.senderId == _uid,
          pending: row.pending,
          broadcastSeverity: payload?.broadcastSeverity,
          signature: opened?.signature ?? SenderSignature.unsigned,
        ),
      );
    }
    return out;
  }

  @override
  Future<List<GroupMessage>> messages(String groupId) async {
    // Picks up the first envelope after approval AND any rotation that
    // happened while this device was offline. Offline, [cachedMessages] just
    // shows whatever epochs we already hold.
    await _syncGroupKeys(groupId);
    await _syncSigners(groupId);
    await _flushPending(groupId);

    final rows = await _client
        .from('group_messages')
        .select('id, sender_id, ciphertext, key_epoch, created_at')
        .eq('group_id', groupId)
        .order('created_at');

    await _cache.saveServerMessages([
      for (final row in List<Map<String, Object?>>.from(rows))
        CachedGroupMessagesCompanion.insert(
          id: row['id'] as String,
          groupId: groupId,
          senderId: row['sender_id'] as String,
          ciphertext: row['ciphertext'] as String,
          keyEpoch: Value((row['key_epoch'] as num?)?.toInt() ?? 1),
          createdAt: DateTime.parse(row['created_at'] as String),
        ),
    ]);

    // One code path builds the display list, so cached and live reads can
    // never drift apart.
    return cachedMessages(groupId);
  }

  /// Encrypt on the device, persist, then try to push. With no network the
  /// message stays queued and shows as "Sending…" — composing offline is a
  /// first-class case, not an error.
  @override
  Future<void> sendMessage(String groupId, String text) =>
      _send(groupId, GroupMessagePayload(body: text));

  @override
  Future<void> sendBroadcast(
    String groupId,
    String body,
    AlertSeverity severity,
  ) => _send(
    groupId,
    GroupMessagePayload(body: body, broadcastSeverity: severity),
  );

  Future<void> _send(String groupId, GroupMessagePayload payload) async {
    // Local keys only, so composing offline works; if a rotation happened
    // meanwhile, _flushPending re-seals under the newer epoch before sending.
    var keys = await _localGroupKeys(groupId);
    if (keys.isEmpty) keys = await _syncGroupKeys(groupId);
    final epoch = _newestEpoch(keys);
    if (epoch == null) throw StateError('No group key available.');
    final ciphertext = await _crypto.encryptMessage(
      groupKey: keys[epoch]!,
      plaintext: payload.encode(),
      signingKey: await _identity.signingKey(),
      context: _sigContext(groupId, epoch),
    );
    await _cache.queueOutgoing(
      CachedGroupMessagesCompanion.insert(
        id: 'local:${DateTime.now().microsecondsSinceEpoch}-${_rng.nextInt(1 << 32)}',
        groupId: groupId,
        senderId: _uid,
        ciphertext: ciphertext,
        keyEpoch: Value(epoch),
        createdAt: DateTime.now().toUtc(),
        pending: const Value(true),
      ),
    );
    await _flushPending(groupId);
  }

  /// Drain the outgoing queue oldest-first, stopping at the first failure so
  /// messages can never arrive out of order.
  ///
  /// A message queued before a key rotation is re-sealed under the current
  /// epoch before it goes out, so a removed member cannot read anything sent
  /// after their removal — even if it was typed before it.
  Future<void> _flushPending(String groupId) async {
    final queued = await _cache.pendingOutgoing(groupId);
    if (queued.isEmpty) return;

    final keys = await _syncGroupKeys(groupId);
    final current = _newestEpoch(keys);

    for (final row in queued) {
      var ciphertext = row.ciphertext;
      var epoch = row.keyEpoch;
      if (current != null && epoch < current) {
        final resealed = await _reseal(
          ciphertext: ciphertext,
          from: keys[epoch],
          to: keys[current],
          groupId: groupId,
          toEpoch: current,
        );
        if (resealed != null) {
          ciphertext = resealed;
          epoch = current;
        }
      }

      try {
        final inserted = await _client
            .from('group_messages')
            .insert({
              'group_id': groupId,
              'ciphertext': ciphertext,
              'key_epoch': epoch,
            })
            .select('id, sender_id, created_at')
            .single();
        await _cache.replacePending(
          localId: row.id,
          server: CachedGroupMessagesCompanion.insert(
            id: inserted['id'] as String,
            groupId: groupId,
            senderId: inserted['sender_id'] as String? ?? row.senderId,
            ciphertext: ciphertext,
            keyEpoch: Value(epoch),
            createdAt: DateTime.parse(inserted['created_at'] as String),
          ),
        );
      } on Object {
        return; // Still offline — keep the rest queued, retry next cycle.
      }
    }
  }

  /// Decrypt under the old epoch and re-encrypt under the new one. Returns
  /// null if either key is missing, in which case the message goes out as-is.
  ///
  /// Re-signs as well as re-encrypts: the signature is bound to the epoch, so
  /// carrying the old one over would make our own queued message verify as
  /// invalid on every recipient's device.
  Future<String?> _reseal({
    required String ciphertext,
    required List<int>? from,
    required List<int>? to,
    required String groupId,
    required int toEpoch,
  }) async {
    if (from == null || to == null) return null;
    try {
      final clear = await _crypto.decryptMessage(
        groupKey: from,
        packed: ciphertext,
      );
      return _crypto.encryptMessage(
        groupKey: to,
        plaintext: clear,
        signingKey: await _identity.signingKey(),
        context: _sigContext(groupId, toEpoch),
      );
    } on Object {
      return null;
    }
  }

  /// Binds a signature to one group and one key epoch, so a signed message
  /// cannot be lifted into another group or replayed under a different epoch.
  String _sigContext(String groupId, int epoch) => '$groupId|$epoch';

  Future<OpenedMessage?> _tryOpen(
    List<int>? groupKey,
    String ciphertext, {
    required String context,
    required List<int>? senderSigningKey,
  }) async {
    if (groupKey == null) return null;
    try {
      return await _crypto.openMessage(
        groupKey: groupKey,
        packed: ciphertext,
        senderSigningPublicKey: senderSigningKey,
        context: context,
      );
    } on Object {
      return null; // Tamper / wrong epoch → "can't decrypt" placeholder.
    }
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

  // --- group key cache (secure storage), keyed by epoch ---
  //
  // Keys rotate when a member is removed. Every epoch this device has ever
  // held is kept so old history stays readable; new messages always use the
  // newest epoch, which a removed device never receives.

  String _epochIndexKey(String groupId) => 'group_key_epochs_$groupId';
  String _epochKeyName(String groupId, int epoch) =>
      'group_key_${groupId}_e$epoch';

  /// Pre-rotation cache location. Anything stored there is epoch 1.
  String _legacyKeyName(String groupId) => 'group_key_$groupId';

  Future<List<int>> _knownEpochs(String groupId) async {
    final raw = await _keyStore.read(_epochIndexKey(groupId));
    final epochs = <int>{
      if (raw != null && raw.isNotEmpty)
        for (final part in raw.split(',')) int.parse(part),
      if (await _keyStore.read(_legacyKeyName(groupId)) != null) 1,
    };
    return epochs.toList()..sort();
  }

  Future<void> _cacheGroupKey(String groupId, int epoch, List<int> key) async {
    await _keyStore.write(_epochKeyName(groupId, epoch), base64Encode(key));
    final epochs = {...await _knownEpochs(groupId), epoch}.toList()..sort();
    await _keyStore.write(_epochIndexKey(groupId), epochs.join(','));
  }

  /// Every group key this device holds, by epoch. Never touches the network,
  /// so it is safe on the offline read path.
  Future<Map<int, List<int>>> _localGroupKeys(String groupId) async {
    final out = <int, List<int>>{};
    for (final epoch in await _knownEpochs(groupId)) {
      final raw =
          await _keyStore.read(_epochKeyName(groupId, epoch)) ??
          (epoch == 1 ? await _keyStore.read(_legacyKeyName(groupId)) : null);
      if (raw != null) out[epoch] = base64Decode(raw);
    }
    return out;
  }

  /// Local keys plus any envelope on the server this device has not opened yet
  /// (a first read after approval, or a rotation that happened while offline).
  Future<Map<int, List<int>>> _syncGroupKeys(String groupId) async {
    final keys = await _localGroupKeys(groupId);
    final rows = await _client
        .from('group_key_envelopes')
        .select('key_epoch, sealed')
        .eq('group_id', groupId)
        .eq('member_user_id', _uid);

    SimpleKeyPair? identity;
    for (final row in List<Map<String, Object?>>.from(rows)) {
      final epoch = (row['key_epoch'] as num).toInt();
      if (keys.containsKey(epoch)) continue;
      identity ??= await _identity.loadOrCreate();
      try {
        final key = await _crypto.openGroupKey(
          sealed: row['sealed'] as String,
          identity: identity,
        );
        await _cacheGroupKey(groupId, epoch, key);
        keys[epoch] = key;
      } on Object {
        // Sealed to a different device identity — not ours to open.
      }
    }
    return keys;
  }

  static int? _newestEpoch(Map<int, List<int>> keys) =>
      keys.isEmpty ? null : keys.keys.reduce(max);

  static final _rng = Random.secure();
  String _randomCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      8,
      (_) => alphabet[_rng.nextInt(alphabet.length)],
    ).join();
  }
}
