import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/app.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/map/tile_providers.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/map/application/map_providers.dart';

import '../../support/stub_tile_provider.dart';

void main() {
  late AppDatabase db;
  final t0 = DateTime(2026, 7, 24, 12);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.batch(
      (b) => b.insertAll(db.facilities, [
        FacilitiesCompanion.insert(
          id: 'w1',
          name: 'Water point Gate 1',
          type: FacilityType.water,
          status: FacilityStatus.good,
          lat: 28.6278,
          lng: 77.2159,
          verifiedAt: Value(t0.subtract(const Duration(minutes: 3))),
          updatedAt: t0,
        ),
        FacilitiesCompanion.insert(
          id: 'f1',
          name: 'Community kitchen',
          type: FacilityType.food,
          status: FacilityStatus.low,
          lat: 28.6283,
          lng: 77.2172,
          updatedAt: t0,
        ),
      ]),
    );
  });

  tearDown(() async => db.close());

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('facilitiesProvider narrows to the selected filter chip', () async {
    final c = container();
    // An active listener is required for the stream element to stay alive.
    c.listen(facilitiesProvider, (_, _) {});

    final all = await c.read(facilitiesProvider.future);
    expect(all, hasLength(2));

    c.read(mapFilterProvider.notifier).select(FacilityType.water);
    final water = await c.read(facilitiesProvider.future);
    expect(water.map((f) => f.id), ['w1']);
  });

  test('nearbyFacilitiesProvider sorts by distance from map center', () async {
    final c = container();
    c.listen(facilitiesProvider, (_, _) {});
    await c.read(facilitiesProvider.future);

    // Default center is Jantar Mantar (28.6271, 77.2166): w1 is nearer.
    final nearby = c.read(nearbyFacilitiesProvider);
    expect(nearby.map((n) => n.facility.id), ['w1', 'f1']);
    expect(nearby.first.distanceMeters, lessThan(nearby.last.distanceMeters));
  });

  testWidgets('map screen renders pins, chips, SOS and Nearby from local DB', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          mapTileProviderProvider.overrideWith((ref) => StubTileProvider()),
        ],
        child: const CommonGroundApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    // Filter chips (labels can also appear in the Nearby list, so >= 1).
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Water'), findsWidgets);

    // The Nearby header reflects the count of facilities near the map centre
    // (both seeded facilities feed nearbyFacilitiesProvider).
    expect(find.text('Nearby · 2'), findsOneWidget);

    // SOS element and Report FAB present.
    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);

    // Filtering to Shelter (no seeded shelters) empties the Nearby list, so
    // the header drops its count.
    await tester.tap(find.text('Shelter').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Nearby · 2'), findsNothing);
    expect(find.text('Nearby'), findsOneWidget);

    // Dispose the tree and flush drift's stream-close timer so the fake
    // async zone ends with no pending timers.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
