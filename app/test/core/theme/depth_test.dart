import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/theme/depth.dart';
import 'package:jantar_mantar_sahayata/core/theme/extruded_knob.dart';
import 'package:jantar_mantar_sahayata/core/theme/tokens.dart';

import '../../support/l10n_harness.dart';

/// Blush Depth mechanics (ADR-39).
///
/// The first attempt at this direction used one soft shadow per surface and
/// read flat. The reason is measurable and lives in the contrast suite: every
/// adjacent pair on the ramp is ~1.06:1, so light does all the layering work.
/// These tests pin the mechanics that carry it, because "looks flat" is not
/// something a widget test notices on its own.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, {bool dark = false}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: dark ? testAppThemeDark() : testAppTheme(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(body: Center(child: child)),
        ),
      );

  BoxDecoration decorationOf(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .map((d) => d.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);

  group('a raised surface is compound, never a single shadow', () {
    testWidgets('two shadows: contact and cast', (tester) async {
      await pump(tester, const DepthSurface(child: Text('card')));
      final d = decorationOf(tester);

      expect(
        d.boxShadow!.length,
        2,
        reason:
            'one shadow is what made the first pass read flat — contact sells '
            '"resting on", cast sells "how far above"',
      );
      final contact = d.boxShadow!.first;
      final cast = d.boxShadow!.last;
      expect(
        contact.blurRadius,
        lessThan(cast.blurRadius),
        reason: 'the contact shadow is the tight one',
      );
      expect(cast.offset.dy, greaterThan(contact.offset.dy));
    });

    testWidgets('and a top lip, because Flutter has no inset shadow', (
      tester,
    ) async {
      await pump(tester, const DepthSurface(child: Text('card')));
      final d = decorationOf(tester);
      expect(
        d.border,
        isNotNull,
        reason: 'the lip is the edge catching light; without it this is a '
            'coloured rectangle',
      );
    });

    testWidgets('the ground casts nothing — it is what others cast onto', (
      tester,
    ) async {
      await pump(
        tester,
        const DepthSurface(elevation: Elevation.ground, child: Text('page')),
      );
      final withShadow = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.boxShadow?.isNotEmpty ?? false);
      expect(withShadow, isEmpty);
    });

    test('every rung is further from the surface than the last', () {
      double reach(int level) =>
          AppTokens.depth(level, dark: false).last.blurRadius;
      expect(reach(1), lessThan(reach(2)));
      expect(reach(2), lessThan(reach(3)));
      expect(reach(3), lessThan(reach(4)));
    });
  });

  group('glass', () {
    testWidgets('is opaque by default — the fallback IS the design', (
      tester,
    ) async {
      // BackdropFilter is the most expensive widget you can put in a scroll
      // view, and the performance target is a sub-2GB Android. Blur has to be
      // opted into, so the cheap path is what everything is designed against.
      await pump(tester, const GlassPanel(child: Text('panel')));
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(DepthSurface), findsOneWidget);
    });

    testWidgets('blurs when asked', (tester) async {
      await pump(tester, const GlassPanel(blur: true, child: Text('panel')));
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('and drops the blur under reduced motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testAppTheme(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: GlassPanel(blur: true, child: Text('panel')),
            ),
          ),
        ),
      );
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'battery saver and reduced motion both route here',
      );
    });
  });

  group('the extruded knob', () {
    testWidgets('sinks when pressed rather than dimming', (tester) async {
      // Dimming reads as "disabled". Sinking reads as "you are pushing it",
      // and on a control someone hits while moving that difference matters.
      await pump(
        tester,
        ExtrudedKnob(onTap: () {}, semanticLabel: 'Water', child: const Text('W')),
      );

      List<Color> stops() => (tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .decoration! as BoxDecoration)
          .gradient!
          .colors;

      final resting = stops();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ExtrudedKnob)),
      );
      await tester.pump(const Duration(milliseconds: 120));
      final pressed = stops();
      await gesture.up();

      expect(
        pressed.first,
        resting.last,
        reason: 'pressed swaps the lip and the shade — the light source stays '
            'above, so the object appears to go down',
      );
      expect(pressed.last, resting.first);
    });

    testWidgets('never smaller than the tap-target floor', (tester) async {
      expect(KnobSize.small.px, greaterThanOrEqualTo(AppTokens.minTouchTarget));
    });

    testWidgets('announces itself as a button with its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        ExtrudedKnob(onTap: () {}, semanticLabel: 'Water', child: const Text('W')),
      );
      expect(
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .any((s) => s.properties.label == 'Water'),
        isTrue,
      );
      handle.dispose();
    });
  });
}
