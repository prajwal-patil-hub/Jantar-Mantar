import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/app.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/map/tile_providers.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/auth/application/auth_providers.dart';

import '../../support/stub_tile_provider.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.now();

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.batch(
      (b) => b.insertAll(db.alerts, [
        AlertsCompanion.insert(
          id: 'a-info',
          severity: AlertSeverity.info,
          body: 'Tankers refill every 2 hours.',
          createdAt: now.subtract(const Duration(minutes: 30)),
          expiresAt: now.add(const Duration(hours: 1)),
        ),
        AlertsCompanion.insert(
          id: 'a-critical',
          severity: AlertSeverity.critical,
          body: 'Avoid the north gate.',
          createdAt: now.subtract(const Duration(minutes: 2)),
          expiresAt: now.add(const Duration(hours: 1)),
        ),
      ]),
    );
  });

  tearDown(() async => db.close());

  Widget app() {
    return ProviderScope(
      overrides: [
        // These exercise the shell, not first-run. Without this override a
        // fresh test profile has no saved flag, so the app correctly opens on
        // onboarding and the shell is never built.
        firstRunProvider.overrideWith(() => _FirstRunDone()),
        appDatabaseProvider.overrideWithValue(db),
        mapTileProviderProvider.overrideWith((ref) => StubTileProvider()),
      ],
      child: const CommonGroundApp(),
    );
  }

  testWidgets('critical alert banner shows on the map instantly', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();

    expect(find.text('Avoid the north gate.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('alerts feed lists critical first with severity labels', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.text('Alerts'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('Tankers refill every 2 hours.'), findsOneWidget);

    // Critical card is rendered above the info card.
    final criticalY = tester.getTopLeft(find.text('Avoid the north gate.')).dy;
    final infoY = tester
        .getTopLeft(find.text('Tankers refill every 2 hours.'))
        .dy;
    expect(criticalY, lessThan(infoY));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

/// first-run already completed, so the app opens on the shell.
class _FirstRunDone extends FirstRunNotifier {
  @override
  Future<bool> build() async => true;
}
