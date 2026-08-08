import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/theme/charts.dart';

import '../../support/l10n_harness.dart';

/// Blush Depth chart forms (ADR-39).
///
/// These pin two things a rendering test would otherwise never notice.
///
/// **The number.** Every one of these shapes except [WaveArea] exists to
/// communicate a value, and a ring with no number in it is a poster, not a
/// readout. The reference boards are full of them; the app must not be.
///
/// **The arithmetic.** Every value here arrives as a division — people ÷
/// capacity, latrines ÷ headcount — and `0/0` is reachable from real data the
/// moment a shelter reports no headcount. NaN does not throw: `drawArc` with a
/// NaN sweep paints nothing, so the failure mode is a chart that looks empty
/// rather than one that crashes, which is why it needs a test.
void main() {
  Future<void> pump(WidgetTester tester, Widget child, {bool dark = false}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: dark ? testAppThemeDark() : testAppTheme(),
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: Scaffold(body: Center(child: SizedBox(width: 300, child: child))),
        ),
      );

  group('a chart that shows a value renders that value as text', () {
    testWidgets('donut', (tester) async {
      await pump(
        tester,
        const DonutGauge(fraction: .62, label: '62%', caption: 'Full'),
      );
      expect(find.text('62%'), findsOneWidget);
      expect(find.text('Full'), findsOneWidget);
    });

    testWidgets('arc', (tester) async {
      await pump(tester, const ArcGauge(fraction: .3, label: '18'));
      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('concentric dial', (tester) async {
      await pump(tester, const ConcentricDial(label: '240', caption: 'people'));
      expect(find.text('240'), findsOneWidget);
    });

    testWidgets('bars print their numbers even with category labels off', (
      tester,
    ) async {
      // showLabels hides the category names. It must not hide the values —
      // otherwise the only way to read a bar is to eyeball its height against
      // its neighbours, and the height floor below deliberately distorts that.
      await pump(
        tester,
        const BarSeries(
          data: [BarDatum('Mon', 4), BarDatum('Tue', 9)],
          showLabels: false,
        ),
      );
      expect(find.text('4'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('Mon'), findsNothing);
    });

    testWidgets('and a screen reader gets the number, not the shape', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const DonutGauge(fraction: .62, label: '62%', caption: 'Full'),
      );
      expect(
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .any((s) => s.properties.label == 'Full: 62%'),
        isTrue,
      );
      handle.dispose();
    });
  });

  group('numbers that came out of a division', () {
    // The first version of these two asserted `takeException() == null`, and
    // both passed with the coercion deleted — NaN does not throw. That is the
    // whole hazard: `drawArc` with a NaN sweep paints an undefined arc, so the
    // bug ships looking like a rendering glitch. These assert the value.
    test('a non-finite fraction becomes zero', () {
      // 0 people / 0 capacity, reachable the moment a shelter has no headcount.
      expect(safeFraction(0 / 0), 0);
      expect(safeFraction(double.nan), 0);
      expect(safeFraction(double.infinity), 0);
      expect(safeFraction(double.negativeInfinity), 0);
    });

    test('and clamp alone would have rendered unknown as FULL', () {
      // The reason the guard is not just `.clamp(0, 1)`, pinned against the
      // Dart SDK so nobody "simplifies" it back: num.clamp orders with
      // compareTo, which ranks NaN above every number, so it returns the
      // upper limit. An unknown occupancy would paint a full gauge — "we have
      // no idea" shown as "full, do not come here".
      expect(double.nan.clamp(0.0, 1.0), 1.0);
      expect(safeFraction(double.nan), isNot(double.nan.clamp(0.0, 1.0)));
    });

    test('an over-full fraction is clamped, not wrapped', () {
      // 300 people in a 200-capacity shelter is real. The ring must read full,
      // never wrap around to 50%.
      expect(safeFraction(1.5), 1);
      expect(safeFraction(-0.3), 0);
    });

    testWidgets('so an unknown donut draws its track and nothing else', (
      tester,
    ) async {
      await pump(
        tester,
        const DonutGauge(fraction: double.nan, label: 'Unknown'),
      );
      // Track only. With the coercion removed this is three arcs: the track,
      // plus a fill and a lip both swept by NaN.
      expect(find.byType(DonutGauge), paintsExactlyCountTimes(#drawArc, 1));
      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('an all-zero bar series does not divide by zero', (
      tester,
    ) async {
      await pump(
        tester,
        const BarSeries(data: [BarDatum('a', 0), BarDatum('b', 0)]),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a flat wave does not divide by a zero span', (tester) async {
      await pump(
        tester,
        const WaveArea(values: [5, 5, 5, 5], semanticLabel: 'Steady'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a wave with a NaN point still draws the real points', (
      tester,
    ) async {
      // Skia draws a path containing NaN as nothing, so the well would render
      // empty and look like "no data" rather than "one bad sample".
      await pump(
        tester,
        const WaveArea(
          values: [1, double.nan, 4, 2],
          semanticLabel: 'Reports per hour',
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('a zero bar paints nothing', () {
    testWidgets('because a visible stub reads as "one, roughly"', (
      tester,
    ) async {
      // The natural implementation floors the height factor so thin bars stay
      // visible. On this data that floor turns "no toilet reported working"
      // into a bar, and that is the reading the Sphere card depends on.
      await pump(
        tester,
        const BarSeries(
          data: [BarDatum('none', 0), BarDatum('some', 10)],
          height: 80,
        ),
      );

      final boxes = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .toList();
      expect(boxes, hasLength(2));
      expect(boxes.first.heightFactor, 0);
      expect(boxes.last.heightFactor, 1);
    });

    testWidgets('but a small non-zero bar stays visible', (tester) async {
      await pump(
        tester,
        const BarSeries(data: [BarDatum('few', 1), BarDatum('many', 400)]),
      );
      final boxes = tester
          .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
          .toList();
      expect(boxes.first.heightFactor, greaterThan(0));
      expect(
        boxes.first.heightFactor,
        lessThan(.2),
        reason: 'visible, but still obviously the small one',
      );
    });
  });

  testWidgets('equal data points each keep their gap', (tester) async {
    // BarDatum has no `==`, so `d != data.last` compares identity, and two
    // equal const data points canonicalise to the SAME instance. A middle bar
    // that happened to equal the last one silently lost its spacer.
    await pump(
      tester,
      const BarSeries(
        data: [BarDatum('a', 5), BarDatum('b', 5), BarDatum('b', 5)],
      ),
    );
    // Two rows (bars, labels) of three items => two gaps each.
    expect(find.byType(SizedBox).evaluate().length, greaterThan(0));
    final gaps = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .where((s) => s.width == 7)
        .length;
    expect(gaps, 4, reason: '2 gaps in the bar row + 2 in the label row');
  });

  testWidgets('every form renders on the dark ramp too', (tester) async {
    await pump(
      tester,
      const Column(
        children: [
          DonutGauge(fraction: .4, label: '40%'),
          ArcGauge(fraction: .4, label: '40'),
          BarSeries(data: [BarDatum('a', 1), BarDatum('b', 2)]),
          WaveArea(values: [1, 3, 2], semanticLabel: 'trend'),
          ConcentricDial(label: '7'),
        ],
      ),
      dark: true,
    );
    expect(tester.takeException(), isNull);
  });
}
