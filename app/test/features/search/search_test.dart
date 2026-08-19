import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/map/map_config.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/map/application/map_providers.dart';
import 'package:jantar_mantar_sahayata/features/search/application/search_providers.dart';
import 'package:latlong2/latlong.dart';

/// Search (ui-ux-spec §1.11) reads the local cache only, so these run against
/// a real in-memory Drift database rather than a stub — the point of the
/// screen is that it works with nothing but what is already on the device.
void main() {
  late AppDatabase db;
  ProviderContainer? containerOrNull;

  final delhi = MapConfig.sites.firstWhere((s) => s.id == 'delhi');

  Future<void> seed({
    required String id,
    required String name,
    required FacilityType type,
    required LatLng at,
    FacilityStatus status = FacilityStatus.good,
  }) => db
      .into(db.facilities)
      .insert(
        FacilitiesCompanion.insert(
          id: id,
          name: name,
          type: type,
          status: status,
          lat: at.latitude,
          lng: at.longitude,
          updatedAt: DateTime.now(),
          verifiedAt: Value(DateTime.now()),
        ),
      );

  // Built on first use, which is AFTER the seeds. Creating it in setUp
  // attaches the stream listener while the table is still empty, and
  // `facilitiesProvider.future` then completes with that empty first
  // emission — so the seeded rows are simply missed. Lazy construction makes
  // the read deterministic instead of a race.
  ProviderContainer container() => containerOrNull ??= () {
    final c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    // Riverpod 3: a StreamProvider needs a listener before `.future`
    // resolves.
    c.listen(facilitiesProvider, (_, _) {});
    c.read(mapCenterProvider.notifier).set(delhi.center);
    return c;
  }();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    containerOrNull = null;
  });

  tearDown(() async {
    containerOrNull?.dispose();
    await db.close();
  });

  Future<List<SearchHit>> search(String q) async {
    final c = container();
    c.read(searchQueryProvider.notifier).set(q);
    await c.read(facilitiesProvider.future);
    return c.read(searchResultsProvider);
  }

  test('an empty query returns nothing rather than everything', () async {
    await seed(
      id: 'a',
      name: 'Water point',
      type: FacilityType.water,
      at: delhi.center,
    );
    expect(await search(''), isEmpty);
    expect(await search('   '), isEmpty, reason: 'whitespace is empty too');
  });

  test('matches a facility by name, case-insensitively', () async {
    await seed(
      id: 'a',
      name: 'Janpath Water Point',
      type: FacilityType.water,
      at: delhi.center,
    );
    expect((await search('janpath')).single.title, 'Janpath Water Point');
    expect((await search('WATER')).single.title, 'Janpath Water Point');
  });

  test('matches by facility type, so "shelter" finds the shelters', () async {
    await seed(
      id: 'a',
      name: 'Gurudwara hall',
      type: FacilityType.shelter,
      at: delhi.center,
    );
    final hits = await search('shelter');
    expect(hits.single.title, 'Gurudwara hall');
    expect(hits.single.kind, SearchResultKind.facility);
  });

  test('site names are searchable as areas', () async {
    final hits = await search('delhi');
    expect(hits.any((h) => h.kind == SearchResultKind.area), isTrue);
  });

  test('results are nearest first', () async {
    const d = Distance();
    await seed(
      id: 'far',
      name: 'Water far',
      type: FacilityType.water,
      at: d.offset(delhi.center, 900, 0),
    );
    await seed(
      id: 'near',
      name: 'Water near',
      type: FacilityType.water,
      at: d.offset(delhi.center, 100, 0),
    );
    expect((await search('water')).map((h) => h.id), ['near', 'far']);
  });

  group('a hit the map cannot reach', () {
    test('has no distance rather than a misleading one', () async {
      await seed(
        id: 'away',
        name: 'Water somewhere else',
        type: FacilityType.water,
        // Well outside every mapped box.
        at: const LatLng(20.5, 78.0),
      );
      expect((await search('water')).single.distanceMeters, isNull);
    });

    test('sorts BELOW every hit that has one', () async {
      // The trap: a null distance treated as zero, or as "unknown so probably
      // close", puts an unreachable place at the top of a list someone is
      // reading to decide where to walk. Unknown must lose to known.
      await seed(
        id: 'offmap',
        name: 'Water offmap',
        type: FacilityType.water,
        at: const LatLng(20.5, 78.0),
      );
      await seed(
        id: 'onmap',
        name: 'Water onmap',
        type: FacilityType.water,
        at: const Distance().offset(delhi.center, 1200, 0),
      );
      final hits = await search('water');
      expect(hits.map((h) => h.id), ['onmap', 'offmap']);
      expect(hits.last.distanceMeters, isNull);
    });
  });

  test('a query matching nothing returns empty, not everything', () async {
    await seed(
      id: 'a',
      name: 'Water point',
      type: FacilityType.water,
      at: delhi.center,
    );
    expect(await search('zzzznotathing'), isEmpty);
  });
}
