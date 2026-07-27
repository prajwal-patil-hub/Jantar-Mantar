import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

/// Local-first store for group chat.
///
/// Holds **ciphertext only** (see [CachedGroupMessages]) plus the outgoing
/// queue, so a chat opens instantly, stays readable offline, and a message
/// composed with no signal is encrypted immediately and sent when the network
/// returns.
class GroupMessageCache {
  const GroupMessageCache(this._db);

  final AppDatabase _db;

  /// Everything we hold for a group, oldest first — sent and pending alike.
  Future<List<CachedGroupMessage>> load(String groupId) =>
      (_db.select(_db.cachedGroupMessages)
            ..where((t) => t.groupId.equals(groupId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

  /// Outgoing messages not yet accepted by the server, oldest first.
  Future<List<CachedGroupMessage>> pendingOutgoing(String groupId) =>
      (_db.select(_db.cachedGroupMessages)
            ..where((t) => t.groupId.equals(groupId) & t.pending.equals(true))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

  /// Upsert the server's view of a group's chat. Pending rows are left alone —
  /// they have local ids and are removed only once the server acknowledges
  /// them via [replacePending].
  Future<void> saveServerMessages(
    List<CachedGroupMessagesCompanion> rows,
  ) async {
    if (rows.isEmpty) return;
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.cachedGroupMessages, rows),
    );
  }

  Future<void> queueOutgoing(CachedGroupMessagesCompanion row) =>
      _db.into(_db.cachedGroupMessages).insert(row);

  /// Swap an acknowledged local row for the server's copy, in one transaction
  /// so the message is never briefly missing from the chat.
  Future<void> replacePending({
    required String localId,
    required CachedGroupMessagesCompanion server,
  }) => _db.transaction(() async {
    await (_db.delete(
      _db.cachedGroupMessages,
    )..where((t) => t.id.equals(localId))).go();
    await _db
        .into(_db.cachedGroupMessages)
        .insert(server, mode: InsertMode.insertOrReplace);
  });

  /// Forget one group's chat (leaving a group).
  Future<void> clearGroup(String groupId) => (_db.delete(
    _db.cachedGroupMessages,
  )..where((t) => t.groupId.equals(groupId))).go();

  /// Forget all cached chat — part of the panic-wipe path.
  Future<void> wipe() => _db.delete(_db.cachedGroupMessages).go();
}
