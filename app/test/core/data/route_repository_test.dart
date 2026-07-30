import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/data/route_repository.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';

/// Route hazards (ADR-31). The rules that matter are about what *stops*
/// showing: a blockage that outlives the water diverts people away from what
/// may be the only road out, so expiry is not cosmetic.
void main() {
  late AppDatabase db;
  late RouteRepository repo;
  final now = DateTime.utc(2026, 7, 30, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = RouteRepository(db);
  });
  tearDown(() => db.close());

  Future<void> add(
    String id, {
    RouteCondition condition = RouteCondition.impassable,
    Duration expiresIn = const Duration(hours: 6),
  }) => repo.insert(
    RouteReportsCompanion.insert(
      id: id,
      name: id,
      condition: condition,
      cause: RouteCause.flood,
      startLat: 26.1433,
      startLng: 91.7372,
      endLat: 26.1421,
      endLng: 91.7390,
      note: const Value('note'),
      expiresAt: now.add(expiresIn),
      updatedAt: now,
    ),
  );

  test('an expired report stops being shown', () async {
    await add('live');
    await add('stale', expiresIn: const Duration(hours: -1));

    final active = await repo.watchActive(asOf: now).first;
    // A blockage nobody has re-asserted must not keep diverting traffic.
    expect(active.map((r) => r.id), ['live']);
  });

  test('worst condition sorts first', () async {
    await add('reopened', condition: RouteCondition.cleared);
    await add('hard', condition: RouteCondition.difficult);
    await add('blocked');

    final active = await repo.watchActive(asOf: now).first;
    expect(active.map((r) => r.id), ['blocked', 'hard', 'reopened']);
  });

  test(
    'a re-report of the same stretch replaces it, never duplicates',
    () async {
      await add('r1');
      await repo.insert(
        RouteReportsCompanion.insert(
          id: 'r1',
          name: 'r1',
          condition: RouteCondition.cleared,
          cause: RouteCause.flood,
          startLat: 26.1433,
          startLng: 91.7372,
          endLat: 26.1421,
          endLng: 91.7390,
          expiresAt: now.add(const Duration(hours: 4)),
          updatedAt: now.add(const Duration(minutes: 30)),
        ),
      );

      final active = await repo.watchActive(asOf: now).first;
      expect(active, hasLength(1));
      expect(active.single.condition, RouteCondition.cleared);
    },
  );

  test('the stream updates when a report is added', () async {
    final seen = <int>[];
    final sub = repo.watchActive(asOf: now).listen((r) => seen.add(r.length));
    await pumpEventQueue();
    await add('r1');
    await pumpEventQueue();
    await sub.cancel();

    expect(seen, containsAllInOrder([0, 1]));
  });

  test('there is no way to record a route as open', () {
    // Guards the design decision, not the code path: crowd data can report a
    // hazard, it cannot certify a road is safe to drive through. If someone
    // ever adds an `open` value this fails and forces the conversation.
    expect(RouteCondition.values.map((c) => c.name), [
      'impassable',
      'difficult',
      'cleared',
    ]);
  });
}
