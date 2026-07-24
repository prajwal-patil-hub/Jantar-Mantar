import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Local-first reads (ARCHITECTURE.md sync rule 1): the UI always subscribes
/// to Drift streams and never awaits the network. Remote refresh lands via
/// [upsertFacilities]/[upsertCapacityReadings] when the sync layer pulls.
class FacilityRepository {
  FacilityRepository(this._db);

  final AppDatabase _db;

  Stream<List<Facility>> watchAll({FacilityType? type}) {
    final query = _db.select(_db.facilities)
      ..orderBy([(f) => OrderingTerm.asc(f.name)]);
    if (type != null) {
      query.where((f) => f.type.equalsValue(type));
    }
    return query.watch();
  }

  Stream<Facility?> watchById(String id) {
    return (_db.select(
      _db.facilities,
    )..where((f) => f.id.equals(id))).watchSingleOrNull();
  }

  /// Readings for a facility, newest first. TTL filtering happens in the UI
  /// layer (expired readings degrade visually before auto-archive, per the
  /// verification pipeline) — so expired rows are still emitted here.
  Stream<List<CapacityReading>> watchCapacity(String facilityId) {
    final query = _db.select(_db.capacityReadings)
      ..where((r) => r.facilityId.equals(facilityId))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.watch();
  }

  Future<void> upsertFacilities(List<FacilitiesCompanion> rows) {
    return _db.batch((b) => b.insertAllOnConflictUpdate(_db.facilities, rows));
  }

  Future<void> upsertCapacityReadings(List<CapacityReadingsCompanion> rows) {
    return _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.capacityReadings, rows),
    );
  }
}
