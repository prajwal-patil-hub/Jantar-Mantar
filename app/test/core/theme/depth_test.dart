import 'dart:math' as math;

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
        reason:
            'the lip is the edge catching light; without it this is a '
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

  group('a surface hosts Material children', () {
    testWidgets('so a ListTile inside one still gets its ink', (tester) async {
      // The old GlassSurface wrapped its child in a transparency Material.
      // DepthSurface at first only did that when it was itself tappable, so
      // every list row inside a card lost its splash — and Flutter asserts on
      // it, which is how this was caught rather than shipped.
      await pump(
        tester,
        DepthSurface(
          child: ListTile(title: const Text('row'), onTap: () {}),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('a surface can clip its own children', () {
    testWidgets('so a pinned header does not punch through a rounded top', (
      tester,
    ) async {
      await pump(
        tester,
        const DepthSurface(
          clip: true,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          child: SizedBox(
            width: 200,
            height: 100,
            child: ColoredBox(color: Color(0xFF123456)),
          ),
        ),
      );
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('and does not pay for a clip it was not asked for', (
      tester,
    ) async {
      await pump(tester, const DepthSurface(child: Text('card')));
      expect(find.byType(ClipRRect), findsNothing);
    });
  });

  group('an extruded control paints a legible glyph', () {
    // The contrast suite pins TOKEN PAIRS. That is necessary and it is not
    // sufficient: it passes while the widget hands the glyph a different
    // token entirely, which is exactly what happened — the quiet knob used
    // inkDark, the light-on-dark TEXT tone, on a body lighter than the
    // ground, and measured 2.36:1 on every map control in dark mode. These
    // read the colour the widget actually renders.
    Color glyphColourOf(WidgetTester tester) =>
        tester.widgetList<IconTheme>(find.byType(IconTheme)).last.data.color!;

    BoxDecoration decoOf(WidgetTester tester, Type of) =>
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: find.byType(of),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration;

    for (final (themeName, isDark) in [('light', false), ('dark', true)]) {
      for (final (stateName, selected) in [
        ('quiet', false),
        ('selected', true),
      ]) {
        testWidgets('$themeName $stateName knob clears 4.5:1', (tester) async {
          await pump(
            tester,
            ExtrudedKnob(
              selected: selected,
              onTap: () {},
              semanticLabel: 'Water',
              child: const Icon(Icons.water_drop),
            ),
            dark: isDark,
          );
          final glyph = glyphColourOf(tester);
          final body = decoOf(tester, ExtrudedKnob).color!;
          expect(
            _contrast(glyph, body),
            greaterThanOrEqualTo(4.5),
            reason:
                'glyph ${_hex(glyph)} on body ${_hex(body)} = '
                '${_contrast(glyph, body).toStringAsFixed(2)}:1',
          );
        });
      }
    }

    testWidgets('and the extrusion stays off the face', (tester) async {
      // The measurement above is only honest while the middle of the face is
      // the body tone. Run the lip/shade ramp edge to edge again and the
      // glyph sits on a highlight the body figure does not describe.
      await pump(
        tester,
        ExtrudedKnob(
          onTap: () {},
          semanticLabel: 'W',
          child: const Icon(Icons.abc),
        ),
      );
      final g = decoOf(tester, ExtrudedKnob).gradient! as LinearGradient;
      final stops = g.stops!;

      expect(g.colors[1], g.colors[2], reason: 'the face is one flat tone');
      // The glyph is sized at .38 of the knob, so it spans .31 to .69.
      expect(
        stops[1],
        lessThanOrEqualTo(0.31),
        reason: 'the lip must have finished before the glyph starts',
      );
      expect(
        stops[2],
        greaterThanOrEqualTo(0.69),
        reason: 'and the shade must not start until after it ends',
      );
    });
  });

  group('the extruded pill', () {
    testWidgets('sinks when pressed, same inversion as the knob', (
      tester,
    ) async {
      await pump(tester, ExtrudedPill(label: 'Report', onTap: () {}));

      List<Color> stops() =>
          (tester
                      .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                      .decoration!
                  as BoxDecoration)
              .gradient!
              .colors;

      final resting = stops();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ExtrudedPill)),
      );
      await tester.pump(const Duration(milliseconds: 120));
      final pressed = stops();
      await gesture.up();

      expect(pressed.first, resting.last);
      expect(pressed.last, resting.first);
    });

    testWidgets('clears the emergency touch target, not Material\'s 40', (
      tester,
    ) async {
      await pump(tester, ExtrudedPill(label: 'Report', onTap: () {}));
      expect(
        tester.getSize(find.byType(ExtrudedPill)).height,
        greaterThanOrEqualTo(AppTokens.primaryTouchTarget),
      );
    });

    testWidgets('carries its label as text, not only as a semantic', (
      tester,
    ) async {
      // An icon-only primary action on a map is a guess.
      await pump(
        tester,
        ExtrudedPill(label: 'Report', icon: Icons.add, onTap: () {}),
      );
      expect(find.text('Report'), findsOneWidget);
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
            child: Scaffold(body: GlassPanel(blur: true, child: Text('panel'))),
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
        ExtrudedKnob(
          onTap: () {},
          semanticLabel: 'Water',
          child: const Text('W'),
        ),
      );

      List<Color> stops() =>
          (tester
                      .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                      .decoration!
                  as BoxDecoration)
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
        reason:
            'pressed swaps the lip and the shade — the light source stays '
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
        ExtrudedKnob(
          onTap: () {},
          semanticLabel: 'Water',
          child: const Text('W'),
        ),
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

double _luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

String _hex(Color c) =>
    '#${((c.a * 255).round() << 24 | (c.r * 255).round() << 16 | (c.g * 255).round() << 8 | (c.b * 255).round()).toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
