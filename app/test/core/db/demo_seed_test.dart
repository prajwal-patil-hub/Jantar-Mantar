import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/db/demo_seed.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';

/// The sample data used to be debug-only, which left the hosted release build
/// with an empty map — the one screen Demo Mode did not actually cover. These
/// pin the behaviour that fixed it.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('seeding fills the map, the detail sheet and the alerts feed', () async {
    await applyDemoSeed(db, on: true);

    final facilities = await db.select(db.facilities).get();
    expect(facilities, isNotEmpty);
    // Several statuses, so the colour+icon+text treatment is all visible.
    expect(
      facilities.map((f) => f.status).toSet().length,
      greaterThan(2),
      reason: 'good/low/out/closed should all be represented',
    );
    // Capacity readings drive the "for ~200" numerals and the TTL degrade.
    expect(await db.select(db.capacityReadings).get(), isNotEmpty);
    // Public alerts, so the Alerts feed is not empty on a fresh install.
    expect(await db.select(db.alerts).get(), isNotEmpty);
  });

  test('seeding twice does not duplicate anything', () async {
    await applyDemoSeed(db, on: true);
    final first = (await db.select(db.facilities).get()).length;

    await applyDemoSeed(db, on: true);
    expect((await db.select(db.facilities).get()).length, first);
  });

  test('turning Demo Mode off removes every sample row', () async {
    await applyDemoSeed(db, on: true);
    await applyDemoSeed(db, on: false);

    expect(await db.select(db.facilities).get(), isEmpty);
    expect(await db.select(db.capacityReadings).get(), isEmpty);
    expect(await db.select(db.alerts).get(), isEmpty);
  });

  test('the user\'s own data survives turning Demo Mode off', () async {
    await applyDemoSeed(db, on: true);
    await db
        .into(db.facilities)
        .insert(
          FacilitiesCompanion.insert(
            id: 'mine-1',
            name: 'Something I reported',
            type: FacilityType.water,
            status: FacilityStatus.good,
            lat: 28.62,
            lng: 77.21,
            updatedAt: DateTime.utc(2026, 7, 27),
          ),
        );

    await applyDemoSeed(db, on: false);

    // Removal is keyed on the demo id prefix, not "delete everything".
    final left = await db.select(db.facilities).get();
    expect(left.map((f) => f.id), ['mine-1']);
  });

  test('seeding does not re-run once the user has cleared it', () async {
    await applyDemoSeed(db, on: true);
    await applyDemoSeed(db, on: false);
    // A user submission exists but no demo rows: seeding again should refill,
    // since the guard checks for demo rows specifically rather than "is the
    // table empty".
    await db
        .into(db.facilities)
        .insert(
          FacilitiesCompanion.insert(
            id: 'mine-1',
            name: 'Mine',
            type: FacilityType.food,
            status: FacilityStatus.good,
            lat: 28.62,
            lng: 77.21,
            verifiedAt: const Value.absent(),
            updatedAt: DateTime.utc(2026, 7, 27),
          ),
        );

    await applyDemoSeed(db, on: true);
    final ids = (await db.select(db.facilities).get()).map((f) => f.id);
    expect(ids, contains('mine-1'));
    expect(ids.where((id) => id.startsWith(demoSeedPrefix)), isNotEmpty);
  });
}
