import 'package:drift/drift.dart';

import 'app_database.dart';

/// Sample facilities, capacity readings and alerts around Jantar Mantar, so
/// the map, detail sheet, freshness banding and Alerts feed are all explorable
/// with no backend (ADR-18, Demo Mode).
///
/// Previously debug-only, which meant the hosted release build showed an empty
/// map — the one part of the app Demo Mode did not cover. Tied to Demo Mode
/// instead, and [removeDemoSeed] takes it all back out when Demo Mode is
/// turned off, so sample pins can never be mistaken for real ones.
///
/// Every row id starts with [demoSeedPrefix]; that is what makes removal exact.
const demoSeedPrefix = 'seed-';

Future<void> seedDemoFacilities(AppDatabase db) async {
  // Idempotent: only seed when none of our rows are present, so a user's own
  // submissions are never disturbed.
  final existing = await (db.select(
    db.facilities,
  )..where((f) => f.id.like('$demoSeedPrefix%'))).get();
  if (existing.isNotEmpty) return;

  final now = DateTime.now();
  FacilitiesCompanion sample(
    String id,
    String name,
    FacilityType type,
    FacilityStatus status,
    double lat,
    double lng, {
    Duration? verifiedAgo,
  }) {
    return FacilitiesCompanion.insert(
      id: id,
      name: name,
      type: type,
      status: status,
      lat: lat,
      lng: lng,
      verifiedAt: Value(verifiedAgo == null ? null : now.subtract(verifiedAgo)),
      updatedAt: now,
    );
  }

  await db.batch(
    (b) => b.insertAll(db.facilities, [
      sample(
        'seed-water-1',
        'Water point — Gate 1',
        FacilityType.water,
        FacilityStatus.good,
        28.6278,
        77.2159,
        verifiedAgo: const Duration(minutes: 3),
      ),
      sample(
        'seed-water-2',
        'Water tanker — Parliament St',
        FacilityType.water,
        FacilityStatus.low,
        28.6252,
        77.2178,
        verifiedAgo: const Duration(minutes: 18),
      ),
      sample(
        'seed-food-1',
        'Langar — community kitchen',
        FacilityType.food,
        FacilityStatus.good,
        28.6283,
        77.2172,
        verifiedAgo: const Duration(minutes: 55),
      ),
      sample(
        'seed-shelter-1',
        'Night shelter — Connaught Pl',
        FacilityType.shelter,
        FacilityStatus.out,
        28.6301,
        77.2190,
        verifiedAgo: const Duration(hours: 2),
      ),
      sample(
        'seed-medical-1',
        'First-aid camp',
        FacilityType.medical,
        FacilityStatus.good,
        28.6265,
        77.2151,
        verifiedAgo: const Duration(minutes: 9),
      ),
      sample(
        'seed-toilet-1',
        'Public toilets',
        FacilityType.toilet,
        FacilityStatus.closed,
        28.6247,
        77.2143,
      ),
      sample(
        'seed-safe-1',
        'Safe assembly area',
        FacilityType.safeArea,
        FacilityStatus.good,
        28.6290,
        77.2145,
        verifiedAgo: const Duration(minutes: 40),
      ),
    ]),
  );

  await db.batch(
    (b) => b.insertAll(db.capacityReadings, [
      CapacityReadingsCompanion.insert(
        id: 'seed-reading-1',
        facilityId: 'seed-water-1',
        resource: ResourceType.water,
        forPeople: 200,
        verifiedAt: Value(now.subtract(const Duration(minutes: 3))),
        expiresAt: now.add(const Duration(minutes: 45)),
        createdAt: now,
      ),
      CapacityReadingsCompanion.insert(
        id: 'seed-reading-2',
        facilityId: 'seed-food-1',
        resource: ResourceType.food,
        forPeople: 120,
        verifiedAt: Value(now.subtract(const Duration(minutes: 55))),
        // Already past TTL — demonstrates the expired degrade in the sheet.
        expiresAt: now.subtract(const Duration(minutes: 10)),
        createdAt: now.subtract(const Duration(minutes: 55)),
      ),
    ]),
  );

  await db.batch(
    (b) => b.insertAll(db.alerts, [
      AlertsCompanion.insert(
        id: 'seed-alert-info',
        severity: AlertSeverity.info,
        body: 'Water tankers refill near Gate 1 every 2 hours.',
        createdAt: now.subtract(const Duration(minutes: 20)),
        expiresAt: now.add(const Duration(hours: 6)),
      ),
      AlertsCompanion.insert(
        id: 'seed-alert-warn',
        severity: AlertSeverity.warn,
        body:
            'Heavy crowd building at Parliament St crossing — expect '
            'slow movement.',
        createdAt: now.subtract(const Duration(minutes: 8)),
        expiresAt: now.add(const Duration(hours: 2)),
      ),
    ]),
  );
}

/// Removes every demo row, leaving anything the user created untouched.
/// Capacity readings reference facilities, so they go first.
Future<void> removeDemoSeed(AppDatabase db) async {
  await db.transaction(() async {
    await (db.delete(
      db.capacityReadings,
    )..where((c) => c.id.like('$demoSeedPrefix%'))).go();
    await (db.delete(
      db.facilities,
    )..where((f) => f.id.like('$demoSeedPrefix%'))).go();
    await (db.delete(
      db.alerts,
    )..where((a) => a.id.like('$demoSeedPrefix%'))).go();
  });
}
