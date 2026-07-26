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
  Future<List<GroupMessage>> messages(String groupId);
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
