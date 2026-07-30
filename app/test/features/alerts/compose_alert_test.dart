import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/alerts/presentation/compose_alert_screen.dart';

import '../../support/l10n_harness.dart';

/// Admin authoring for PUBLIC alerts (E6). The safety-relevant behaviours are
/// the confirmation on critical, and the fact that an alert always carries an
/// expiry — a stale warning is worse than no warning.
void main() {
  late AppDatabase db;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: testAppTheme(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const ComposeAlertScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  }

  testWidgets('says plainly that the alert is public and unencrypted', (
    tester,
  ) async {
    await pump(tester);
    // Shown BEFORE typing — a group broadcast and a public alert look similar
    // and must never be confused.
    expect(find.textContaining('public map for everyone'), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('publishing a warning writes an alert with an expiry', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'Crowd surge at Gate 2');
    await tester.pump();
    await tester.ensureVisible(find.text('Publish alert'));
    await tester.pump();
    await tester.tap(find.text('Publish alert'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final alerts = await db.select(db.alerts).get();
    expect(alerts, hasLength(1));
    expect(alerts.single.body, 'Crowd surge at Gate 2');
    expect(alerts.single.severity, AlertSeverity.warn);
    // Default TTL is 2h; the point is that it expires at all.
    expect(alerts.single.expiresAt.isAfter(alerts.single.createdAt), isTrue);

    await teardown(tester);
  });

  testWidgets('a CRITICAL alert needs a second confirmation', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Critical'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Move west now');
    await tester.pump();
    await tester.ensureVisible(find.text('Publish alert').first);
    await tester.pump();
    await tester.tap(find.text('Publish alert').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The dialog is the gate: nothing is written until it is accepted.
    expect(find.text('Publish a CRITICAL alert?'), findsOneWidget);
    expect(await db.select(db.alerts).get(), isEmpty);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      await db.select(db.alerts).get(),
      isEmpty,
      reason: 'cancelling must not publish',
    );

    await teardown(tester);
  });

  testWidgets('confirming publishes the critical alert', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Critical'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Move west now');
    await tester.pump();
    await tester.ensureVisible(find.text('Publish alert').first);
    await tester.pump();
    await tester.tap(find.text('Publish alert').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // The dialog's confirm button carries the same label; take the last one.
    await tester.tap(find.text('Publish alert').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final alerts = await db.select(db.alerts).get();
    expect(alerts, hasLength(1));
    expect(alerts.single.severity, AlertSeverity.critical);

    await teardown(tester);
  });

  testWidgets('an empty message cannot be published', (tester) async {
    await pump(tester);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Publish alert'),
    );
    expect(button.onPressed, isNull);
    await teardown(tester);
  });
}
