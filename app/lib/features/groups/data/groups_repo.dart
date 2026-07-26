import '../domain/group_models.dart';

/// Interface the Groups UI talks to, so a real Supabase-backed repository and
/// an in-memory demo repository are interchangeable.
abstract interface class GroupsRepo {
  Future<List<Group>> myGroups();
  Future<Group> createGroup({
    required String name,
    String? description,
    String visibility,
  });
  Future<List<GroupMember>> members(String groupId);
  Future<void> approveMember(String groupId, String userId);
  /// Local-first read: whatever chat is cached on this device, with no network
  /// call at all. Returns instantly (possibly empty) so a chat renders before
  /// any request is made and stays readable offline.
  Future<List<GroupMessage>> cachedMessages(String groupId);

  /// Refreshes from the server and returns the merged result. Throws when the
  /// network is unavailable — callers fall back to [cachedMessages] and show
  /// an offline notice rather than an empty chat.
  Future<List<GroupMessage>> messages(String groupId);

  /// Encrypts and stores the message locally first, then tries to send. A send
  /// with no network stays queued and does NOT throw.
  Future<void> sendMessage(String groupId, String text);
  Future<List<GroupPin>> pins(String groupId);
  Future<void> addPin({
    required String groupId,
    required String type,
    required String label,
    required double lat,
    required double lng,
    String? note,
  });
  Future<String> createInvite(String groupId);
  Future<String> joinByCode(String code);
}
