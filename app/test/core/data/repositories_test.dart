import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/data/alert_repository.dart';
import 'package:jantar_mantar_sahayata/core/data/facility_repository.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';

void main() {
  late AppDatabase db;
  final t0 = DateTime(2026, 7, 24, 12);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  FacilitiesCompanion facility(
    String id,
    FacilityType type, {
    FacilityStatus status = FacilityStatus.good,
  }) {
    return FacilitiesCompanion.insert(
      id: id,
      name: 'Facility $id',
      type: type,
      status: status,
      lat: 28.6270,
      lng: 77.2160,
      updatedAt: t0,
    );
  }

  group('FacilityRepository', () {
    test('watchAll filters by type and upsert overwrites', () async {
      final repo = FacilityRepository(db);
      await repo.upsertFacilities([
        facility('w1', FacilityType.water),
        facility('f1', FacilityType.food),
      ]);

      final water = await repo.watchAll(type: FacilityType.water).first;
      expect(water.map((f) => f.id), ['w1']);

      // Upsert with same id updates in place (server refresh path).
      await repo.upsertFacilities([
        facility('w1', FacilityType.water, status: FacilityStatus.out),
      ]);
      final all = await repo.watchAll().first;
      expect(all, hasLength(2));
      expect(all.singleWhere((f) => f.id == 'w1').status, FacilityStatus.out);
    });

    test('watchCapacity returns readings newest first', () async {
      final repo = FacilityRepository(db);
      await repo.upsertFacilities([facility('w1', FacilityType.water)]);
      await repo.upsertCapacityReadings([
        CapacityReadingsCompanion.insert(
          id: 'r1',
          facilityId: 'w1',
          resource: ResourceType.water,
          forPeople: 200,
          expiresAt: t0.add(const Duration(minutes: 45)),
          createdAt: t0,
        ),
        CapacityReadingsCompanion.insert(
          id: 'r2',
          facilityId: 'w1',
          resource: ResourceType.water,
          forPeople: 120,
          expiresAt: t0.add(const Duration(minutes: 50)),
          createdAt: t0.add(const Duration(minutes: 5)),
        ),
      ]);

      final readings = await repo.watchCapacity('w1').first;
      expect(readings.map((r) => r.id), ['r2', 'r1']);
    });
  });

  group('AlertRepository', () {
    test('watchActive hides expired and ranks critical first', () async {
      final repo = AlertRepository(db);
      AlertsCompanion alert(
        String id,
        AlertSeverity severity, {
        required DateTime expiresAt,
        required DateTime createdAt,
      }) {
        return AlertsCompanion.insert(
          id: id,
          severity: severity,
          body: 'Alert $id',
          createdAt: createdAt,
          expiresAt: expiresAt,
        );
      }

      await repo.upsertAlerts([
        alert(
          'info-new',
          AlertSeverity.info,
          createdAt: t0,
          expiresAt: t0.add(const Duration(hours: 1)),
        ),
        alert(
          'critical-old',
          AlertSeverity.critical,
          createdAt: t0.subtract(const Duration(minutes: 30)),
          expiresAt: t0.add(const Duration(hours: 1)),
        ),
        alert(
          'expired',
          AlertSeverity.warn,
          createdAt: t0.subtract(const Duration(hours: 2)),
          expiresAt: t0.subtract(const Duration(minutes: 1)),
        ),
      ]);

      final active = await repo.watchActive(asOf: t0).first;
      expect(active.map((a) => a.id), ['critical-old', 'info-new']);
    });
  });
}
