import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// Queued writes (ARCHITECTURE.md sync rule 2): a submission commits locally
/// as `pending` together with its outbox entry in ONE transaction, so the
/// optimistic "Pending (yours)" pin and the eventual upload can never
/// disagree. No network is touched here, ever.
class SubmissionRepository {
  SubmissionRepository(this._db, {this._uuid = const Uuid()});

  final AppDatabase _db;
  final Uuid _uuid;

  Future<String> submit({
    required Map<String, Object?> payload,
    String? facilityId,
    double? lat,
    double? lng,
    String? photoPath,
    DateTime? now,
  }) async {
    final id = _uuid.v4();
    final createdAt = now ?? DateTime.now();
    final payloadJson = jsonEncode(payload);

    await _db.transaction(() async {
      await _db
          .into(_db.submissions)
          .insert(
            SubmissionsCompanion.insert(
              id: id,
              facilityId: Value(facilityId),
              lat: Value(lat),
              lng: Value(lng),
              payload: payloadJson,
              photoPath: Value(photoPath),
              state: SubmissionState.pending,
              createdAt: createdAt,
            ),
          );
      await _db
          .into(_db.syncQueueEntries)
          .insert(
            SyncQueueEntriesCompanion.insert(
              op: SyncOp.create,
              entity: 'submission',
              entityId: id,
              payload: payloadJson,
              nextAttemptAt: createdAt,
              createdAt: createdAt,
            ),
          );
    });
    return id;
  }

  /// All local submissions, newest first (single-user device — every row is
  /// "mine"). Feeds the pending-uploads tray in Profile (ui-ux-spec §1.12).
  Stream<List<Submission>> watchMine() {
    final query = _db.select(_db.submissions)
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return query.watch();
  }

  Stream<int> watchPendingCount() {
    final count = _db.submissions.id.count();
    final query = _db.selectOnly(_db.submissions)
      ..addColumns([count])
      ..where(_db.submissions.state.equalsValue(SubmissionState.pending));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
