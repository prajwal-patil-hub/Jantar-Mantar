import 'package:drift/drift.dart';

import 'app_database.dart';

/// DEBUG-ONLY sample facilities around Jantar Mantar so the map has pins
/// during development. Never runs in release builds; real data arrives via
/// the verification pipeline once the backend lands.
Future<void> seedDebugFacilities(AppDatabase db) async {
  final existing = await db.select(db.facilities).get();
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
}
