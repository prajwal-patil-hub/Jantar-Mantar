import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/core/theme/depth.dart';
import 'package:jantar_mantar_sahayata/core/theme/tokens.dart';
import 'package:jantar_mantar_sahayata/features/alerts/presentation/alerts_screen.dart';

import '../../support/l10n_harness.dart';

/// The radii scale holds on screens that set their own shape (ADR-35).
///
/// ADR-32 put one radii scale in `AppTokens` and applied it through component
/// themes precisely so no screen would need to name a number. Screens named
/// numbers anyway: alert cards and group broadcast cards passed an explicit
/// `RoundedRectangleBorder` at 12 in order to carry a severity border, and
/// that override silently took the radius with it. They rendered at 12 while
/// every other Card in the app rendered at 22 — a visible inconsistency
/// nothing tested, because each file looked reasonable on its own.
///
/// A Card that opts out of the themed shape has to opt back into the themed
/// radius. This asserts it does.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('a card with a severity border keeps the card radius', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: testAppTheme(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const Scaffold(body: AlertsScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Alert cards are DepthSurface now, not Card (ADR-39), and their
    // severity outline comes through `accentBorder` rather than a shape side.
    // The invariant is unchanged and is the reason this test exists: an
    // explicit shape must still use the radii scale. Alert cards drifted to
    // 12 once already.
    final surfaces = tester.widgetList<DepthSurface>(find.byType(DepthSurface));
    expect(surfaces, isNotEmpty, reason: 'nothing to measure otherwise');

    var sawSeverityBorder = false;
    for (final s in surfaces) {
      final shape = s.borderRadius;
      if (shape != null) {
        expect(
          shape.topLeft.x,
          AppTokens.radiusCard,
          reason: 'an explicit radius must still use the scale',
        );
      } else {
        // No explicit radius: it takes the elevation's default, which for a
        // card IS the scale. Pin that rather than skipping.
        expect(
          s.radius ?? AppTokens.radiusCard,
          AppTokens.radiusCard,
          reason: 'the default for a card rung is the card radius',
        );
      }
      if (s.accentBorder != null) sawSeverityBorder = true;
    }
    expect(
      sawSeverityBorder,
      isTrue,
      reason:
          'the severity outline is the thing under test — if no alert '
          'card carried one, this test stopped covering anything',
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 120));
  });

  test('the bubble radius is deliberately off the card scale', () {
    // Not an accident and not drift: at the card radius a one-word message
    // reads as a lozenge. It gets its own named token so the difference is a
    // decision someone can find, rather than a stray number in a chat file.
    expect(AppTokens.radiusBubble, isNot(AppTokens.radiusCard));
    expect(AppTokens.radiusBubble, lessThan(AppTokens.radiusCard));
    expect(
      AppTokens.radiusBubbleTail,
      lessThan(AppTokens.radiusBubble),
      reason: 'the tail is a squared-off corner, not a second rounding',
    );
  });
}
