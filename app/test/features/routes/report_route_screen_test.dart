import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/map/tile_providers.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/core/theme/app_theme.dart';
import 'package:jantar_mantar_sahayata/features/routes/presentation/report_route_screen.dart';

import '../../support/l10n_harness.dart';
import '../../support/stub_tile_provider.dart';

/// Reporting a blocked route (ADR-31).
///
/// The behaviours worth pinning: you cannot save half a line, every report
/// carries an expiry and the screen says why, and the app never claims a road
/// is open.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          // Never fetch real tiles in a test.
          mapTileProviderProvider.overrideWith((ref) => StubTileProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const ReportRouteScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('cannot save until both ends are placed', (tester) async {
    await pump(tester);

    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save route report'),
    );
    expect(save.onPressed, isNull);
    expect(find.textContaining('one end of the affected stretch'), findsOne);

    await teardown(tester);
  });

  testWidgets('placing both ends writes one report with an expiry', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Set start'));
    await tester.pump();
    await tester.tap(find.text('Set end'));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Pandu approach road');
    await tester.pump();
    await tester.ensureVisible(find.text('Save route report'));
    await tester.tap(find.text('Save route report'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final rows = await db.select(db.routeReports).get();
    expect(rows, hasLength(1));
    expect(rows.single.name, 'Pandu approach road');
    expect(rows.single.condition, RouteCondition.impassable);
    // Never open-ended: a blockage left on the map after the water drops
    // routes people away from the only road out.
    expect(rows.single.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);
    expect(
      rows.single.expiresAt.difference(DateTime.now().toUtc()).inHours,
      lessThanOrEqualTo(6),
    );

    await teardown(tester);
  });

  testWidgets('the screen explains why reports expire', (tester) async {
    await pump(tester);
    await tester.ensureVisible(find.textContaining('Every report expires'));
    expect(find.textContaining('away from the only road out'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('there is no "open" option to choose', (tester) async {
    await pump(tester);
    // Impassable / hard to pass / reopened — and nothing that asserts a road
    // is fine to drive.
    expect(find.text('Impassable'), findsOneWidget);
    expect(find.text('Hard to pass'), findsOneWidget);
    expect(find.text('Reopened'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
    expect(find.text('Safe'), findsNothing);

    await teardown(tester);
  });
}
