import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/data/remote_pull_service.dart';
import 'package:jantar_mantar_sahayata/core/data/remote_sync_api.dart';
import 'package:jantar_mantar_sahayata/core/data/submission_repository.dart';
import 'package:jantar_mantar_sahayata/core/data/supabase_remote_api.dart';
import 'package:jantar_mantar_sahayata/core/data/sync_worker.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/sync/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mapping logic is pure and tested offline; live-server behaviour (RLS,
// decision functions) is covered by supabase/tests/rls_negative_test.sql.
void main() {
  group('SupabaseRemoteApi row mapping', () {
    test('sosRow carries client_id and fired_at', () {
      final entry = SyncQueueEntry(
        localId: 1,
        op: SyncOp.create,
        entity: 'sos',
        entityId: 'sos-uuid-1',
        payload: '{"firedAt":"2026-07-24T12:00:00.000Z"}',
        state: SyncState.pending,
        attempts: 0,
        nextAttemptAt: DateTime(2026),
        createdAt: DateTime(2026),
      );
      final row = SupabaseRemoteApi.sosRow(entry);
      expect(row['client_id'], 'sos-uuid-1');
      expect(row['fired_at'], '2026-07-24T12:00:00.000Z');
    });

    test('submissionRow pulls the local row and serialises payload', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = SubmissionRepository(db);
      final id = await repo.submit(
        payload: {'category': 'water', 'status': 'low'},
        lat: 28.62,
        lng: 77.21,
      );
      final entry = (await db.select(db.syncQueueEntries).get()).single;

      // Constructing a client makes no network calls; submissionRow never
      // touches it anyway.
      final api = SupabaseRemoteApi(
        db,
        SupabaseClient('http://localhost:54321', 'test-key'),
      );
      final row = await api.submissionRow(entry);
      expect(row!['client_id'], id);
      expect(row['facility_ref'], isNull);
      expect((row['payload'] as Map)['category'], 'water');
      expect(row['lat'], 28.62);
    });
  });

  group('RemotePullService row mapping', () {
    test('facilityCompanion maps a server row', () {
      final companion = RemotePullService.facilityCompanion({
        'id': 'f-uuid',
        'name': 'Water point',
        'type': 'water',
        'status': 'low',
        'lat': 28.6,
        'lng': 77.2,
        'canonical': true,
        'verified_at': '2026-07-24T11:55:00Z',
        'updated_at': '2026-07-24T12:00:00Z',
      });
      expect(companion.id.value, 'f-uuid');
      expect(companion.type.value, FacilityType.water);
      expect(companion.status.value, FacilityStatus.low);
      expect(companion.verifiedAt.value, isNotNull);
    });

    test('alertCompanion tolerates null geo', () {
      final companion = RemotePullService.alertCompanion({
        'id': 'a-uuid',
        'severity': 'critical',
        'body': 'Avoid north gate',
        'lat': null,
        'lng': null,
        'radius_meters': null,
        'created_by': null,
        'created_at': '2026-07-24T12:00:00Z',
        'expires_at': '2026-07-24T13:00:00Z',
      });
      expect(companion.severity.value, AlertSeverity.critical);
      expect(companion.lat.value, isNull);
    });

    test('capacityCompanion maps TTL fields', () {
      final companion = RemotePullService.capacityCompanion({
        'id': 'r-uuid',
        'facility_id': 'f-uuid',
        'resource': 'water',
        'for_people': 200,
        'verified_by': null,
        'verified_at': null,
        'expires_at': '2026-07-24T12:45:00Z',
        'created_at': '2026-07-24T12:00:00Z',
      });
      expect(companion.forPeople.value, 200);
      expect(companion.expiresAt.value.isUtc, isFalse); // localised
    });
  });

  test('SyncService without a client is a safe no-op', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final service = SyncService(
      client: null,
      worker: SyncWorker(db, const UnconfiguredRemoteApi()),
      puller: null,
    );
    service.start(); // must not schedule anything or throw
    await service.runCycle();
    service.stop();
  });
}
