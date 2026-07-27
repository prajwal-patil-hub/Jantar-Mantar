import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/app.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/map/tile_providers.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';

import 'support/stub_tile_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Widget app() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        mapTileProviderProvider.overrideWith((ref) => StubTileProvider()),
      ],
      child: const CommonGroundApp(),
    );
  }

  testWidgets('app boots to the shell with all four destinations', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Dispose the tree and flush drift's stream-close timer (the map screen
    // subscribes to facility streams).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('navigation switches screens', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Alerts'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // No public alerts in a fresh DB, but Demo Mode seeds a group broadcast,
    // so the feed shows the group section rather than the empty state.
    expect(find.text('From your groups'), findsOneWidget);
    // Broadcasts from more than one city, newest first.
    expect(find.text('London — Parliament Square · Critical'), findsOneWidget);
    expect(find.text('Water Distribution · Warning'), findsOneWidget);
    expect(find.text('Group broadcast · members only'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
