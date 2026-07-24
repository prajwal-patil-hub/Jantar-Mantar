import 'package:drift/drift.dart';

import '../db/app_database.dart';

class AlertRepository {
  AlertRepository(this._db);

  final AppDatabase _db;

  /// Unexpired alerts, critical first, newest first. `asOf` is captured when
  /// the stream is created; callers re-subscribe periodically (or on sync)
  /// to advance the cutoff — cached alerts must stay visible offline with a
  /// "may be outdated" treatment rather than vanish (ui-ux-spec §1.10).
  Stream<List<Alert>> watchActive({DateTime? asOf}) {
    final cutoff = asOf ?? DateTime.now();
    final query = _db.select(_db.alerts)
      ..where((a) => a.expiresAt.isBiggerThanValue(cutoff))
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]);
    // Severity ranks by enum index (info < warn < critical), not by the text
    // stored in SQL — sort here so critical always tops the feed.
    return query.watch().map(
      (alerts) =>
          alerts..sort((a, b) => b.severity.index.compareTo(a.severity.index)),
    );
  }

  Future<void> upsertAlerts(List<AlertsCompanion> rows) {
    return _db.batch((b) => b.insertAllOnConflictUpdate(_db.alerts, rows));
  }
}
