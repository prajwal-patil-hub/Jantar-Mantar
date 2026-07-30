import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/sos/presentation/sos_screen.dart';

import '../../support/l10n_harness.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Widget app() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        home: const SosScreen(),
      ),
    );
  }

  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('shows hold button and direct-call tiles', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('SOS\nHold to send'), findsOneWidget);
    expect(find.textContaining('112'), findsOneWidget);
    expect(find.textContaining('108'), findsOneWidget);
    expect(find.textContaining('15100'), findsOneWidget);
    // The secondary tiles scroll on a short screen now — the hero keeps its
    // height instead (ADR-34) — so the last one may start below the fold.
    await tester.scrollUntilVisible(
      find.text('Nearest medical on map'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Nearest medical on map'), findsOneWidget);

    await flushTimers(tester);
  });

  testWidgets('holding through the countdown queues an SOS', (tester) async {
    await tester.pumpWidget(app());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('SOS\nHold to send')),
    );
    // Long-press recognizer kicks in ~500ms, countdown is 2.5s.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 2600));
    await gesture.up();
    await tester.pump();

    expect(find.text('SOS queued'), findsOneWidget);
    expect(find.text("I'm safe — reset"), findsOneWidget);

    final entry = (await db.select(db.syncQueueEntries).get()).single;
    expect(entry.entity, 'sos');
    expect(entry.state, SyncState.pending);
    final payload = jsonDecode(entry.payload) as Map<String, Object?>;
    expect(payload['firedAt'], isNotNull);

    await flushTimers(tester);
  });

  testWidgets('releasing early cancels the countdown', (tester) async {
    await tester.pumpWidget(app());

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('SOS\nHold to send')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 800)); // released early
    await gesture.up();
    await tester.pump();

    expect(find.text('SOS queued'), findsNothing);
    expect(await db.select(db.syncQueueEntries).get(), isEmpty);

    await flushTimers(tester);
  });

  /// The hero must stay usable at every size this app targets — including
  /// low-end Android, which CLAUDE.md names explicitly.
  ///
  /// Regression: the SOS disc used to be whatever height was left over after
  /// fixed chrome, wrapped in FittedBox(scaleDown). On a 360×640 phone that
  /// left it **zero** pixels tall, and the FittedBox hid it by scaling the
  /// whole hero away. The app's most important control was, in practice,
  /// invisible on a small screen.
  group('the hold control survives small screens', () {
    for (final device in const {
      'small Android 360×640': Size(360, 640),
      'iPhone 390×844': Size(390, 844),
      'short/wide 800×600': Size(800, 600),
    }.entries) {
      testWidgets(device.key, (tester) async {
        tester.view.physicalSize = device.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(app());
        await tester.pump();

        final disc = tester.getRect(find.byType(CircularProgressIndicator));
        expect(
          disc.height,
          greaterThanOrEqualTo(48),
          reason: 'below the tap-target minimum on ${device.key}',
        );
        expect(disc.width, greaterThanOrEqualTo(48));
        // Square: a squashed ellipse means the parent is clipping it.
        expect(disc.height, closeTo(disc.width, 1));
        // And still reachable, not pushed off the bottom.
        expect(disc.bottom, lessThanOrEqualTo(device.value.height));

        await flushTimers(tester);
      });
    }

    testWidgets('holding still works on a small phone', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('SOS\nHold to send')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 2600));
      await gesture.up();
      await tester.pump();

      expect(find.text('SOS queued'), findsOneWidget);
      await flushTimers(tester);
    });
  });
}
