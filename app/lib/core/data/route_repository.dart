import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Route reports — "the way there is gone" (ADR-31).
///
/// Deliberately parallel to [AlertRepository] rather than to the facility
/// repository, because a route report behaves like an alert: it is a hazard
/// with a mandatory expiry, not a place that persists.
class RouteRepository {
  RouteRepository(this._db);

  final AppDatabase _db;

  /// Unexpired reports, worst first. `asOf` is captured when the stream is
  /// created; callers re-subscribe to advance it, so a cached report stays
  /// visible offline with a stale treatment rather than silently vanishing —
  /// the same rule the alerts feed follows.
  ///
  /// **Expired reports are excluded on purpose.** A blockage that has aged
  /// out is not a harmless leftover: it routes people away from what may be
  /// the only viable road. Someone has to re-assert it.
  Stream<List<RouteReport>> watchActive({DateTime? asOf}) {
    final cutoff = asOf ?? DateTime.now();
    final query = _db.select(_db.routeReports)
      ..where((r) => r.expiresAt.isBiggerThanValue(cutoff))
      ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]);
    // Impassable before difficult before cleared, by enum order rather than
    // by the text stored in SQL.
    return query.watch().map(
      (rows) =>
          rows..sort((a, b) => a.condition.index.compareTo(b.condition.index)),
    );
  }

  Future<void> upsertRoutes(List<RouteReportsCompanion> rows) =>
      _db.batch((b) => b.insertAllOnConflictUpdate(_db.routeReports, rows));

  Future<void> insert(RouteReportsCompanion row) =>
      _db.into(_db.routeReports).insertOnConflictUpdate(row);
}
