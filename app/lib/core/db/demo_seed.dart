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
      sample(
        'seed-danger-1',
        'Barricade — avoid this junction',
        FacilityType.danger,
        FacilityStatus.closed,
        28.6259,
        77.2131,
        verifiedAgo: const Duration(minutes: 12),
      ),
      sample(
        'seed-water-3',
        'Drinking water — Metro gate 4',
        FacilityType.water,
        FacilityStatus.good,
        28.6268,
        77.2185,
        verifiedAgo: const Duration(minutes: 1),
      ),
      sample(
        'seed-medical-2',
        'Ambulance standby point',
        FacilityType.medical,
        FacilityStatus.low,
        28.6295,
        77.2168,
        verifiedAgo: const Duration(minutes: 27),
      ),
      sample(
        'seed-food-2',
        'Tea and biscuits stall',
        FacilityType.food,
        FacilityStatus.low,
        28.6272,
        77.2140,
        verifiedAgo: const Duration(hours: 3),
      ),
      sample(
        'seed-toilet-2',
        'Portable toilets — north end',
        FacilityType.toilet,
        FacilityStatus.good,
        28.6288,
        77.2178,
        verifiedAgo: const Duration(minutes: 33),
      ),
      // Not yet verified — shows the grey "unverified" treatment.
      sample(
        'seed-shelter-2',
        'Shaded rest area (reported)',
        FacilityType.shelter,
        FacilityStatus.good,
        28.6244,
        77.2163,
      ),

      // --- Parliament Square, London ------------------------------------
      sample(
        'seed-ldn-water-1',
        'Water refill — Westminster Bridge',
        FacilityType.water,
        FacilityStatus.good,
        51.5008,
        -0.1246,
        verifiedAgo: const Duration(minutes: 6),
      ),
      sample(
        'seed-ldn-medical-1',
        'St John Ambulance post',
        FacilityType.medical,
        FacilityStatus.good,
        51.5003,
        -0.1289,
        verifiedAgo: const Duration(minutes: 14),
      ),
      sample(
        'seed-ldn-food-1',
        'Soup kitchen van',
        FacilityType.food,
        FacilityStatus.low,
        51.5015,
        -0.1281,
        verifiedAgo: const Duration(minutes: 48),
      ),
      sample(
        'seed-ldn-toilet-1',
        'Public toilets — Victoria Embankment',
        FacilityType.toilet,
        FacilityStatus.good,
        51.5019,
        -0.1240,
        verifiedAgo: const Duration(hours: 1),
      ),
      sample(
        'seed-ldn-safe-1',
        'Legal observer meeting point',
        FacilityType.safeArea,
        FacilityStatus.good,
        51.4998,
        -0.1272,
        verifiedAgo: const Duration(minutes: 21),
      ),
      sample(
        'seed-ldn-danger-1',
        'Kettling reported — Bridge St',
        FacilityType.danger,
        FacilityStatus.closed,
        51.5006,
        -0.1257,
        verifiedAgo: const Duration(minutes: 4),
      ),

      // --- Town Hall, Bengaluru -----------------------------------------
      sample(
        'seed-blr-water-1',
        'Water tanker — Town Hall steps',
        FacilityType.water,
        FacilityStatus.good,
        12.9663,
        77.5859,
        verifiedAgo: const Duration(minutes: 8),
      ),
      sample(
        'seed-blr-food-1',
        'Community meal counter',
        FacilityType.food,
        FacilityStatus.good,
        12.9655,
        77.5847,
        verifiedAgo: const Duration(minutes: 35),
      ),
      sample(
        'seed-blr-medical-1',
        'First-aid volunteers',
        FacilityType.medical,
        FacilityStatus.low,
        12.9670,
        77.5842,
        verifiedAgo: const Duration(minutes: 16),
      ),
      sample(
        'seed-blr-shelter-1',
        'Shade tents — JC Road side',
        FacilityType.shelter,
        FacilityStatus.good,
        12.9648,
        77.5866,
        verifiedAgo: const Duration(minutes: 52),
      ),
      sample(
        'seed-blr-toilet-1',
        'Public toilets — Hudson Circle',
        FacilityType.toilet,
        FacilityStatus.out,
        12.9676,
        77.5871,
        verifiedAgo: const Duration(hours: 2),
      ),
      sample(
        'seed-blr-safe-1',
        'Assembly point — Town Hall lawn',
        FacilityType.safeArea,
        FacilityStatus.good,
        12.9659,
        77.5854,
        verifiedAgo: const Duration(minutes: 11),
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
      CapacityReadingsCompanion.insert(
        id: 'seed-reading-3',
        facilityId: 'seed-water-3',
        resource: ResourceType.water,
        forPeople: 500,
        verifiedAt: Value(now.subtract(const Duration(minutes: 1))),
        expiresAt: now.add(const Duration(minutes: 58)),
        createdAt: now,
      ),
      CapacityReadingsCompanion.insert(
        id: 'seed-reading-4',
        facilityId: 'seed-shelter-1',
        resource: ResourceType.shelter,
        forPeople: 40,
        verifiedAt: Value(now.subtract(const Duration(hours: 2))),
        expiresAt: now.add(const Duration(minutes: 12)),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      CapacityReadingsCompanion.insert(
        id: 'seed-reading-ldn-1',
        facilityId: 'seed-ldn-food-1',
        resource: ResourceType.food,
        forPeople: 150,
        verifiedAt: Value(now.subtract(const Duration(minutes: 48))),
        expiresAt: now.add(const Duration(minutes: 20)),
        createdAt: now.subtract(const Duration(minutes: 48)),
      ),
      CapacityReadingsCompanion.insert(
        id: 'seed-reading-blr-1',
        facilityId: 'seed-blr-food-1',
        resource: ResourceType.food,
        forPeople: 300,
        verifiedAt: Value(now.subtract(const Duration(minutes: 35))),
        expiresAt: now.add(const Duration(minutes: 40)),
        createdAt: now.subtract(const Duration(minutes: 35)),
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
      // Critical alerts pin to the top of the feed AND show the full-width
      // banner on the map.
      AlertsCompanion.insert(
        id: 'seed-alert-critical',
        severity: AlertSeverity.critical,
        body:
            'Police advancing from the north barricade. Move towards the '
            'safe assembly area at the west lawn.',
        lat: const Value(28.6290),
        lng: const Value(77.2145),
        radiusMeters: const Value(400),
        createdAt: now.subtract(const Duration(minutes: 2)),
        expiresAt: now.add(const Duration(hours: 1)),
      ),
      AlertsCompanion.insert(
        id: 'seed-alert-ldn',
        severity: AlertSeverity.warn,
        body:
            'London: Bridge St is being kettled. Legal observers are at the '
            'Parliament Square meeting point.',
        createdAt: now.subtract(const Duration(minutes: 5)),
        expiresAt: now.add(const Duration(hours: 3)),
      ),
      AlertsCompanion.insert(
        id: 'seed-alert-blr',
        severity: AlertSeverity.info,
        body: 'Bengaluru: Town Hall water tanker refills at 4 PM and 8 PM.',
        createdAt: now.subtract(const Duration(minutes: 30)),
        expiresAt: now.add(const Duration(hours: 5)),
      ),
      AlertsCompanion.insert(
        id: 'seed-alert-expired',
        severity: AlertSeverity.warn,
        body: 'This alert has expired and must NOT appear in the feed.',
        createdAt: now.subtract(const Duration(hours: 4)),
        expiresAt: now.subtract(const Duration(hours: 1)),
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
