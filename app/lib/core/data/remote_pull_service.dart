import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/app_database.dart';

/// Pulls verified public data (facilities, capacity, alerts) and the user's
/// own submission verdicts into Drift. The UI only ever reads Drift — this
/// runs in the background and failures leave the cache untouched
/// (local-first, ARCHITECTURE.md sync rule 1).
class RemotePullService {
  RemotePullService(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<void> pullAll() async {
    await _pullFacilities();
    await _pullCapacityReadings();
    await _pullAlerts();
    await _pullSubmissionVerdicts();
  }

  Future<void> _pullFacilities() async {
    final rows = await _client.from('facilities').select();
    if (rows.isEmpty) return;
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.facilities, [
        for (final row in rows) facilityCompanion(row),
      ]),
    );
  }

  Future<void> _pullCapacityReadings() async {
    final rows = await _client
        .from('capacity_readings')
        .select()
        .gt('expires_at', DateTime.now().toUtc().toIso8601String());
    if (rows.isEmpty) return;
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.capacityReadings, [
        for (final row in rows) capacityCompanion(row),
      ]),
    );
  }

  Future<void> _pullAlerts() async {
    final rows = await _client
        .from('alerts')
        .select()
        .gt('expires_at', DateTime.now().toUtc().toIso8601String());
    if (rows.isEmpty) return;
    await _db.batch(
      (b) => b.insertAllOnConflictUpdate(_db.alerts, [
        for (final row in rows) alertCompanion(row),
      ]),
    );
  }

  /// Server verdicts flow back into the local submissions (matched by
  /// client_id == local id) so "Pending (yours)" pins resolve.
  Future<void> _pullSubmissionVerdicts() async {
    final rows = await _client
        .from('submissions')
        .select('client_id, state, reason')
        .neq('state', 'pending');
    for (final row in rows) {
      final state = SubmissionState.values.asNameMap()[row['state']];
      if (state == null) continue;
      await (_db.update(
        _db.submissions,
      )..where((s) => s.id.equals(row['client_id'] as String))).write(
        SubmissionsCompanion(
          state: Value(state),
          rejectReason: Value(row['reason'] as String?),
        ),
      );
    }
  }

  static FacilitiesCompanion facilityCompanion(Map<String, Object?> row) {
    return FacilitiesCompanion.insert(
      id: row['id'] as String,
      name: row['name'] as String,
      type: FacilityType.values.byName(row['type'] as String),
      status: FacilityStatus.values.byName(row['status'] as String),
      lat: (row['lat'] as num).toDouble(),
      lng: (row['lng'] as num).toDouble(),
      canonical: Value(row['canonical'] as bool? ?? true),
      verifiedAt: Value(_time(row['verified_at'])),
      updatedAt: _time(row['updated_at']) ?? DateTime.now(),
    );
  }

  static CapacityReadingsCompanion capacityCompanion(Map<String, Object?> row) {
    return CapacityReadingsCompanion.insert(
      id: row['id'] as String,
      facilityId: row['facility_id'] as String,
      resource: ResourceType.values.byName(row['resource'] as String),
      forPeople: row['for_people'] as int,
      verifiedBy: Value(row['verified_by'] as String?),
      verifiedAt: Value(_time(row['verified_at'])),
      expiresAt: _time(row['expires_at'])!,
      createdAt: _time(row['created_at']) ?? DateTime.now(),
    );
  }

  static AlertsCompanion alertCompanion(Map<String, Object?> row) {
    return AlertsCompanion.insert(
      id: row['id'] as String,
      severity: AlertSeverity.values.byName(row['severity'] as String),
      body: row['body'] as String,
      lat: Value((row['lat'] as num?)?.toDouble()),
      lng: Value((row['lng'] as num?)?.toDouble()),
      radiusMeters: Value((row['radius_meters'] as num?)?.toDouble()),
      createdBy: Value(row['created_by'] as String?),
      createdAt: _time(row['created_at']) ?? DateTime.now(),
      expiresAt: _time(row['expires_at'])!,
    );
  }

  static DateTime? _time(Object? iso) =>
      iso == null ? null : DateTime.parse(iso as String).toLocal();
}
