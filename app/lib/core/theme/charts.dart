import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// The five chart forms extracted from the Blush Depth boards (ADR-39).
///
/// Custom painters rather than a chart package: these are five fixed shapes,
/// not a plotting library, and a package would bring its own colour and
/// typography opinions into a palette that was measured rather than chosen.
///
/// One rule they all share, and it is not cosmetic: **a chart that shows a
/// value always renders that value as text.** The reference boards have rings
/// with no numbers in them, which is fine for a poster and useless on a screen
/// someone is reading to decide where to walk. [WaveArea] is the one that shows
/// a *shape* rather than a value, and it is the only one with no number in it —
/// whatever it is trending must be stated next to it, not inside it.
///
/// The second rule is arithmetic, and it is the reason [safeFraction] exists.

/// A fraction that is safe to hand to a painter: finite, and inside 0..1.
///
/// Every number these charts show arrives as a division — people ÷ capacity,
/// working latrines ÷ headcount — so `0/0` is reachable from real data the
/// moment a shelter reports no headcount.
///
/// **`clamp` alone does the worst possible thing here.** `num.clamp` orders
/// its arguments with `compareTo`, which ranks NaN above every number, so
/// `double.nan.clamp(0, 1)` returns **1.0** — not NaN, and not an error. An
/// unknown occupancy would render as a completely full gauge: "we have no
/// idea" displayed as "full, do not come here". That is the same failure the
/// Sphere card already refuses by rendering nothing without a headcount
/// (ADR-30), and it has to be refused here too.
///
/// Public so the coercion can be asserted directly — the painter is private
/// and a widget test cannot read the value it was handed.
double safeFraction(double v) => v.isFinite ? v.clamp(0.0, 1.0) : 0.0;

// ---------------------------------------------------------------- donut

/// A ring with the value in the middle. The reference's most-used form.
class DonutGauge extends StatelessWidget {
  const DonutGauge({
    required this.fraction,
    required this.label,
    this.caption,
    this.size = 106,
    this.color,
    super.key,
  });

  /// 0..1. Clamped — a gauge that overflows its own ring is a lie about the
  /// number, and these numbers are occupancy and capacity.
  final double fraction;

  /// Rendered in the centre. Never omitted.
  final String label;
  final String? caption;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final fill = color ?? (dark ? AppTokens.clayDark : AppTokens.clay);
    final track = dark ? AppTokens.peach2Dark : AppTokens.peach2;

    return Semantics(
      label: caption == null ? label : '$caption: $label',
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _DonutPainter(
            fraction: safeFraction(fraction),
            fill: fill,
            track: track,
            lip: dark ? AppTokens.lipDark : AppTokens.lipLight,
          ),
          // The centre text has to fit INSIDE the ring, and the ring's hole
          // is much smaller than the widget: the stroke is .17 of the width
          // on each side, so the hole is .66 of it, and the usable square
          // inside that circle is .66/sqrt(2) — under half the widget. A
          // plain Center overflows it, which is how "12/20 approved" ended up
          // painting straight across the ring.
          child: Center(
            child: SizedBox.square(
              dimension: size * .66 / math.sqrt2,
              child: FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (caption != null)
                      Text(caption!, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.fraction,
    required this.fill,
    required this.track,
    required this.lip,
  });

  final double fraction;
  final Color fill;
  final Color track;
  final Color lip;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .17;
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    ).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = fill,
    );
    // The extrusion: a thin highlight along the outer edge of the ring, so it
    // reads as a raised band rather than a printed circle.
    canvas.drawArc(
      rect.deflate(-stroke / 2 + 1),
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = lip,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.fraction != fraction ||
      old.fill != fill ||
      old.track != track ||
      old.lip != lip;
}

// ------------------------------------------------------------------ arc

/// The thick open crescent from the boards — a gauge that reads as a dial
/// rather than a completed ring, so it suits "progress toward" better than
/// "proportion of".
class ArcGauge extends StatelessWidget {
  const ArcGauge({
    required this.fraction,
    required this.label,
    this.size = 104,
    this.sweep = 4.2,
    super.key,
  });

  final double fraction;
  final String label;
  final double size;

  /// Radians of the full track. ~4.2 leaves the reference's open bottom.
  final double sweep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ArcPainter(
            fraction: safeFraction(fraction),
            sweep: sweep,
            fill: dark ? AppTokens.peachDark : AppTokens.peach,
            track: dark ? AppTokens.peach3Dark : AppTokens.peach3,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: size * .6 / math.sqrt2,
              child: FittedBox(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.fraction,
    required this.sweep,
    required this.fill,
    required this.track,
  });

  final double fraction;
  final double sweep;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .2;
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    ).deflate(stroke / 2);
    // Centred on the bottom gap, so the open ends sit symmetrically.
    final start = math.pi / 2 + (math.pi * 2 - sweep) / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, p..color = track);
    if (fraction > 0) {
      canvas.drawArc(rect, start, sweep * fraction, false, p..color = fill);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.fraction != fraction ||
      old.sweep != sweep ||
      old.fill != fill ||
      old.track != track;
}

// ----------------------------------------------------------------- bars

class BarDatum {
  const BarDatum(this.label, this.value, {this.color});
  final String label;
  final double value;
  final Color? color;
}

/// Chunky rounded bars, extruded. The reference caps them more on top than on
/// the bottom, which is what stops them reading as pills.
///
/// Two things here are correctness, not styling:
///
///  · **A zero bar paints nothing.** The obvious implementation floors the
///    height factor so short bars stay visible, and that floor turns "no water
///    point reported here" into a visible stub the same size as "one". The
///    floor applies only above zero.
///  · **Every bar prints its number.** Category labels alone leave the value
///    readable only by eye off the bar heights, which is exactly the reading
///    the floor above would have corrupted.
class BarSeries extends StatelessWidget {
  const BarSeries({
    required this.data,
    this.height = 78,
    this.showLabels = true,
    super.key,
  });

  final List<BarDatum> data;
  final double height;

  /// Hides the category names. The **values** are printed either way — that is
  /// the rule at the top of this file, not a display option.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final max = data.fold<double>(
      0,
      (m, d) => d.value.isFinite ? math.max(m, d.value) : m,
    );
    final peak = max <= 0 ? 1.0 : max;

    // Indexed rather than `d != data.last`: BarDatum has no `==`, so identity
    // decides, and two equal const data points canonicalise to one instance —
    // a middle bar equal to the last would silently lose its gap.
    List<Widget> spaced(Widget Function(int, BarDatum) build) => [
      for (var i = 0; i < data.length; i++) ...[
        Expanded(child: build(i, data[i])),
        if (i != data.length - 1) const SizedBox(width: 7),
      ],
    ];

    return Semantics(
      label: data.map((d) => '${d.label} ${d.value.round()}').join(', '),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: spaced(
                (_, d) => FractionallySizedBox(
                  heightFactor: d.value.isFinite && d.value > 0
                      ? (d.value / peak).clamp(0.06, 1.0)
                      : 0.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                        bottom: Radius.circular(4),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          dark ? AppTokens.lipDark : AppTokens.lipLight,
                          d.color ??
                              (dark ? AppTokens.peachDark : AppTokens.peach),
                          dark ? AppTokens.shadeDark : AppTokens.shadeLight,
                        ],
                        stops: const [0, .35, 1],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: spaced(
              (_, d) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.value.isFinite ? '${d.value.round()}' : '—',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (showLabels)
                    Text(
                      d.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- wave

/// A filled area with a smooth top edge, sitting in an inset well. The well is
/// how the reference distinguishes a container from a card: shadow pointing
/// in, not out.
///
/// This is the one form here that carries a **shape, not a value** — there is
/// no number in it and there should not be, because a 24-point trend has no
/// single number. Whatever it is trending has to be printed beside it by the
/// caller; [semanticLabel] is required so the shape is at least never the only
/// thing a screen reader gets.
class WaveArea extends StatelessWidget {
  const WaveArea({
    required this.values,
    required this.semanticLabel,
    this.height = 66,
    super.key,
  });

  final List<double> values;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _WavePainter(
              values: values,
              fill: (dark ? AppTokens.peachDark : AppTokens.peach).withValues(
                alpha: .8,
              ),
              line: dark ? AppTokens.clayDark : AppTokens.clay,
              well: dark ? AppTokens.e2Dark : AppTokens.e2Light,
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.values,
    required this.fill,
    required this.line,
    required this.well,
  });

  final List<double> values;
  final Color fill;
  final Color line;
  final Color well;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = well);
    // A single NaN would poison min/max and produce a path of NaN coordinates,
    // which Skia draws as nothing at all — the well would silently render
    // empty. Drop the bad points instead and draw the trend that is real.
    final values = [...this.values.where((v) => v.isFinite)];
    if (values.length < 2) return;

    final max = values.reduce(math.max);
    final min = values.reduce(math.min);
    final span = (max - min).abs() < 1e-9 ? 1.0 : max - min;
    final dx = size.width / (values.length - 1);
    // Inset the top so the peak is not clipped by the well's own edge.
    double y(double v) =>
        size.height - 6 - ((v - min) / span) * (size.height - 16);

    final path = Path()..moveTo(0, y(values.first));
    for (var i = 0; i < values.length - 1; i++) {
      final x1 = dx * i;
      final x2 = dx * (i + 1);
      // Horizontal control points give the reference's soft S-curves without
      // overshooting past the data, which a Catmull-Rom spline would.
      path.cubicTo(
        x1 + dx / 2,
        y(values[i]),
        x2 - dx / 2,
        y(values[i + 1]),
        x2,
        y(values[i + 1]),
      );
    }

    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..color = line,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.values != values;
}

// -------------------------------------------------------------- concentric

/// Stepped rings with the value in a dished centre. The reference's most
/// tactile object — three elevations in one control.
class ConcentricDial extends StatelessWidget {
  const ConcentricDial({
    required this.label,
    this.caption,
    this.size = 130,
    super.key,
  });

  final String label;
  final String? caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final lip = dark ? AppTokens.lipDark : AppTokens.lipLight;
    final shade = dark ? AppTokens.shadeDark : AppTokens.shadeLight;

    BoxDecoration ring(Color body) => BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lip, body, shade],
        stops: const [0, .45, 1],
      ),
    );

    return Semantics(
      label: caption == null ? label : '$caption: $label',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        decoration: ring(
          dark ? AppTokens.peach2Dark : AppTokens.peach2,
        ).copyWith(boxShadow: AppTokens.depth(3, dark: dark)),
        child: Center(
          child: Container(
            width: size * .75,
            height: size * .75,
            decoration: ring(dark ? AppTokens.peachDark : AppTokens.peach),
            child: Center(
              child: Container(
                width: size * .49,
                height: size * .49,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // The centre is DISHED — gradient inverted, so it reads as a
                  // well rather than another raised disc. That inversion is
                  // what makes the whole thing look machined.
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      shade,
                      dark ? AppTokens.e4Dark : AppTokens.e4Light,
                    ],
                    stops: const [0, .55],
                  ),
                ),
                child: Center(
                  child: SizedBox.square(
                    dimension: size * .49 / math.sqrt2,
                    child: FittedBox(
                      child: Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
