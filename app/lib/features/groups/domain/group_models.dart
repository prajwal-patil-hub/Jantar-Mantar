/// Plain models for the groups feature (server-backed; Phase 3).
enum GroupRole { admin, member }

enum MemberState { pending, active, banned }

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.visibility,
    required this.myRole,
    required this.myState,
  });

  final String id;
  final String name;
  final String? description;
  final String visibility; // 'public' | 'hidden'
  final GroupRole myRole;
  final MemberState myState;

  bool get isAdmin => myRole == GroupRole.admin;

  factory Group.fromRow(Map<String, Object?> row, {required String myUserId}) {
    final members = (row['group_members'] as List?) ?? const [];
    Map<String, Object?>? mine;
    for (final m in members.cast<Map<String, Object?>>()) {
      if (m['user_id'] == myUserId) mine = m;
    }
    return Group(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      visibility: row['visibility'] as String? ?? 'hidden',
      myRole: (mine?['role'] == 'admin') ? GroupRole.admin : GroupRole.member,
      myState:
          MemberState.values.asNameMap()[mine?['state']] ?? MemberState.pending,
    );
  }
}

class GroupMember {
  const GroupMember({
    required this.userId,
    required this.role,
    required this.state,
    this.displayName,
    this.isMe = false,
  });

  final String userId;
  final GroupRole role;
  final MemberState state;
  final String? displayName;

  /// Set by the repository, which is the only layer that knows the signed-in
  /// id. Keeps the UI from having to guess (an admin must be able to remove
  /// another admin, but never themselves).
  final bool isMe;

  factory GroupMember.fromRow(
    Map<String, Object?> row, {
    required String myUserId,
  }) => GroupMember(
    userId: row['user_id'] as String,
    role: row['role'] == 'admin' ? GroupRole.admin : GroupRole.member,
    state: MemberState.values.asNameMap()[row['state']] ?? MemberState.pending,
    displayName: row['display_name'] as String?,
    isMe: row['user_id'] == myUserId,
  );
}

/// A decrypted chat message for display. Decryption happens client-side; if it
/// fails the UI shows a "can't decrypt" placeholder ([decrypted] == null).
class GroupMessage {
  const GroupMessage({
    required this.id,
    required this.senderId,
    required this.createdAt,
    required this.decrypted,
    required this.mine,
    this.pending = false,
  });

  final String id;
  final String senderId;
  final DateTime createdAt;
  final String? decrypted;
  final bool mine;

  /// Encrypted and stored locally, but not yet accepted by the server — the
  /// bubble shows a "Sending…" marker (icon + text, never colour alone).
  final bool pending;
}

class GroupPin {
  const GroupPin({
    required this.id,
    required this.type,
    required this.label,
    required this.lat,
    required this.lng,
    this.note,
  });

  final String id;
  final String type;
  final String label;
  final double lat;
  final double lng;
  final String? note;

  factory GroupPin.fromRow(Map<String, Object?> row) => GroupPin(
    id: row['id'] as String,
    type: row['type'] as String,
    label: row['label'] as String,
    lat: (row['lat'] as num).toDouble(),
    lng: (row['lng'] as num).toDouble(),
    note: row['note'] as String?,
  );
}
