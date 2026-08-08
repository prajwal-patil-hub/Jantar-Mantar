import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/theme/status_colors.dart';
import 'package:jantar_mantar_sahayata/core/theme/tokens.dart';
import 'package:jantar_mantar_sahayata/features/alerts/presentation/widgets/alert_visuals.dart';

/// Automates the colour half of the accessibility audit so a palette change
/// cannot quietly regress it between manual reviews.
///
/// The app never relies on colour alone — every status carries an icon and
/// localised text too, which is the WCAG 1.4.1 mitigation and the reason a few
/// numbers below are allowed to sit under the ideal. Where that happens the
/// measured value is **pinned**, not waived: improve the palette and the test
/// fails, telling you to raise the bar deliberately.
///
/// Not covered here, still manual: TalkBack/VoiceOver traversal on real OEM
/// devices. See `docs/accessibility-audit.md`.
void main() {
  const colors = StatusColors.standard;
  const saffron = AppTokens.accent; // ADR-10
  // The grounds the app ACTUALLY paints. These were previously hardcoded
  // near-white/near-black that no screen used, so the suite was measuring a
  // surface that did not exist — found while adopting Soft Geometry (ADR-32).
  //
  // These two are the scaffolds, kept as named shorthands for the tests that
  // genuinely want one ground per theme. Status colours are measured against
  // all four grounds below — see the note there for why the scaffold alone
  // was never the worst case.
  const lightSurface = AppTokens.scaffoldLight;
  const darkSurface = AppTokens.scaffoldDark;

  final swatches = <String, Color>{
    'good': colors.good,
    'low': colors.low,
    'out': colors.out,
    'unverified': colors.unverified,
    'info': AlertSeverityVisuals.infoBlue,
    'accent': saffron,
  };

  group('contrast on the surfaces we actually paint on', () {
    // WCAG 2.1 AA for meaningful graphics and large/bold text.
    const bar = 3.0;

    // Every ground the app actually paints a status colour onto — not just
    // the scaffold.
    //
    // ALL FIVE painted surfaces, per theme (ADR-39). The Blush Depth ramp
    // separates layers by light, not tone, so there are now five grounds a
    // status colour can land on rather than two — and the worst case is the
    // TOP one in dark mode, because that is the lightest and it is where map
    // markers paint.
    //
    // This is what forced the dark ramp to compress: at a full-height dark
    // ramp `out` measured 2.35:1 on the top surface. Status does not yield to
    // the palette, so the palette yielded.
    const grounds = <String, Color>{
      'light e0 ground': AppTokens.e0Light,
      'light e1 plate': AppTokens.e1Light,
      'light e2 panel': AppTokens.e2Light,
      'light e3 card': AppTokens.e3Light,
      'light e4 floating': AppTokens.e4Light,
      'dark e0 ground': AppTokens.e0Dark,
      'dark e1 plate': AppTokens.e1Dark,
      'dark e2 panel': AppTokens.e2Dark,
      'dark e3 card': AppTokens.e3Dark,
      'dark e4 floating': AppTokens.e4Dark,
    };

    for (final name in ['good', 'out', 'unverified', 'info']) {
      test('$name is legible on every ground it is painted on', () {
        for (final ground in grounds.entries) {
          expect(
            _contrast(swatches[name]!, ground.value),
            greaterThanOrEqualTo(bar),
            reason:
                '$name on ${ground.key}: '
                '${_ratio(swatches[name]!, ground.value)}',
          );
        }
      });
    }

    test('low trades light-surface contrast for CVD separability', () {
      // Deliberate: every darker amber that clears 3:1 collapses against the
      // red "Out" under CVD (see the note in StatusColors). Pinned so the
      // trade-off stays visible and cannot drift further.
      //
      // Re-pinned twice now, for Soft Geometry and again for Blush Depth.
      // Each time the number moved because the ground moved, never because
      // the reasoning changed: amber on a warm ground is the weakest point of
      // this palette, and the icon + text rule is what carries it.
      expect(_contrast(colors.low, AppTokens.e0Light), closeTo(1.49, 0.06));
      expect(_contrast(colors.low, AppTokens.e4Light), closeTo(1.92, 0.06));
      for (final dark in [
        AppTokens.e0Dark,
        AppTokens.e2Dark,
        AppTokens.e4Dark,
      ]) {
        expect(
          _contrast(colors.low, dark),
          greaterThanOrEqualTo(bar),
          reason: 'it must at least be strong on dark: '
              '${_ratio(colors.low, dark)}',
        );
      }
    });

    test('the filled-action tone is readable in both themes', () {
      // Clay is the tone every CTA and filled surface uses (ADR-32), so its
      // label contrast is a real body-text requirement, not a graphics one.
      expect(
        _contrast(AppTokens.onClay, AppTokens.clay),
        greaterThanOrEqualTo(4.5),
        reason: 'light: ${_ratio(AppTokens.onClay, AppTokens.clay)}',
      );
      // Inverted on purpose: in dark mode clay is lighter than the ground,
      // so its label is dark ink. Cream here measures 2.83:1.
      expect(
        _contrast(AppTokens.onClayDark, AppTokens.clayDark),
        greaterThanOrEqualTo(4.5),
        reason: 'dark: ${_ratio(AppTokens.onClayDark, AppTokens.clayDark)}',
      );
    });

    test('the card boundary is carried by light, not by tone', () {
      // The whole premise of ADR-39, as a number. Every adjacent pair on the
      // ramp is ~1.06:1 light / ~1.04:1 dark — far under the 3:1 WCAG 1.4.11
      // wants of a component boundary. Pinned so nobody "fixes" the flat ramp
      // by darkening a layer: the flatness IS the reference, and the compound
      // shadow in AppTokens.depth is the answer.
      const light = [
        AppTokens.e0Light,
        AppTokens.e1Light,
        AppTokens.e2Light,
        AppTokens.e3Light,
        AppTokens.e4Light,
      ];
      const dark = [
        AppTokens.e0Dark,
        AppTokens.e1Dark,
        AppTokens.e2Dark,
        AppTokens.e3Dark,
        AppTokens.e4Dark,
      ];
      for (var i = 0; i < 4; i++) {
        expect(
          _contrast(light[i], light[i + 1]),
          lessThan(1.12),
          reason: 'tone alone cannot carry this — that is the point',
        );
        expect(_contrast(dark[i], dark[i + 1]), lessThan(1.12));
      }

      // So the hairline has to, wherever a shadow is unavailable: outdoor
      // mode, high contrast, direct sunlight. It must clear 3:1 against ALL
      // FIVE surfaces, not just two — the old dark hairline cleared only
      // 2.93 once the ramp changed.
      for (final ground in light) {
        expect(
          _contrast(AppTokens.hairline, ground),
          greaterThanOrEqualTo(3.0),
          reason: _ratio(AppTokens.hairline, ground),
        );
      }
      for (final ground in dark) {
        expect(
          _contrast(AppTokens.hairlineDark, ground),
          greaterThanOrEqualTo(3.0),
          reason: _ratio(AppTokens.hairlineDark, ground),
        );
      }
    });

    test('body ink and the action tone clear 4.5:1 on every surface', () {
      // The action tone is the one that moved: at #A64E34 it measured 4.21 on
      // the deepest light ground — under the bar. Picking a value that only
      // clears the lightest card is how a palette passes review and fails on
      // the screen that matters.
      for (final ground in [
        AppTokens.e0Light,
        AppTokens.e2Light,
        AppTokens.e4Light,
      ]) {
        expect(_contrast(AppTokens.ink, ground), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(AppTokens.inkMuted, ground),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(AppTokens.clay, ground),
          greaterThanOrEqualTo(4.5),
          reason: 'clay on $ground: ${_ratio(AppTokens.clay, ground)}',
        );
      }
      for (final ground in [
        AppTokens.e0Dark,
        AppTokens.e2Dark,
        AppTokens.e4Dark,
      ]) {
        expect(_contrast(AppTokens.inkDark, ground), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(AppTokens.clayDark, ground),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('peach is a fill, and the test says so out loud', () {
      // The reference boards use peach for big numerals. It measures 1.41:1.
      // Pinned as a FAILURE so nobody "reuses the brand colour" for text.
      expect(
        _contrast(AppTokens.peach, AppTokens.e0Light),
        lessThan(2.0),
        reason: 'peach is fill-only — if this ever passes, re-read ADR-39',
      );
    });

    test('the saffron accent is pinned, not silently redefined', () {
      // ADR-10 is the owner's explicit choice, made aware of the trade-offs.
      // As a foreground on light it measures under 3:1, which is exactly why
      // ADR-10 forbids using the accent to convey status. Re-pinned from 2.75
      // for the warm scaffold (ADR-32) — saffron is not used as a foreground
      // on this ground anyway; filled actions use clay with light-on-dark
      // text, asserted separately below.
      expect(_contrast(saffron, lightSurface), closeTo(2.12, 0.05));
      expect(_contrast(saffron, darkSurface), greaterThanOrEqualTo(bar));
    });
  });

  group('colour-vision deficiency', () {
    // 0.20 normalised sRGB distance ≈ "clearly different" after simulation.
    const bar = 0.20;

    // Pairs a user must be able to tell apart at a glance.
    final mustSeparate = {
      'low vs out': [colors.low, colors.out],
      'good vs low': [colors.good, colors.low],
      'info vs low': [AlertSeverityVisuals.infoBlue, colors.low],
      'info vs out': [AlertSeverityVisuals.infoBlue, colors.out],
      'good vs info': [colors.good, AlertSeverityVisuals.infoBlue],
      'unverified vs low': [colors.unverified, colors.low],
    };

    for (final pair in mustSeparate.entries) {
      test('${pair.key} stay distinct under every CVD type', () {
        for (final sim in _simulations.entries) {
          final d = _distance(
            sim.value(pair.value[0]),
            sim.value(pair.value[1]),
          );
          expect(
            d,
            greaterThanOrEqualTo(bar),
            reason:
                '${pair.key} under ${sim.key} is only '
                '${d.toStringAsFixed(3)} apart',
          );
        }
      });
    }

    test('good vs out collapses under protanopia — mitigated, not fixed', () {
      // The classic red/green problem. Separating them properly means making
      // "good" a teal (best in-family candidate scored 0.31 but reads as
      // blue-green, colliding with the info blue), so instead the pair is
      // always accompanied by ✓/✕ icons and localised text.
      final d = _distance(_protanopia(colors.good), _protanopia(colors.out));
      expect(d, closeTo(0.167, 0.02));
      // It must still hold up for the other two types.
      expect(
        _distance(_deuteranopia(colors.good), _deuteranopia(colors.out)),
        greaterThanOrEqualTo(bar),
      );
      expect(
        _distance(_tritanopia(colors.good), _tritanopia(colors.out)),
        greaterThanOrEqualTo(bar),
      );
    });

    test('accent is indistinguishable from status colours under CVD', () {
      // Precisely why ADR-10 bans the accent from carrying status meaning.
      // Asserted so that ban has teeth: if someone ever tints a status with
      // the accent, this documents why it is wrong.
      expect(
        _distance(_deuteranopia(colors.low), _deuteranopia(saffron)),
        lessThan(bar),
      );
      expect(
        _distance(_deuteranopia(colors.out), _deuteranopia(saffron)),
        lessThan(bar),
      );
    });
  });
}

// --- WCAG relative luminance + contrast -------------------------------------

double _channel(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

String _ratio(Color a, Color b) => '${_contrast(a, b).toStringAsFixed(2)}:1';

double _distance(Color a, Color b) {
  final dr = a.r - b.r;
  final dg = a.g - b.g;
  final db = a.b - b.b;
  return math.sqrt((dr * dr + dg * dg + db * db) / 3);
}

// --- CVD simulation (Viénot-style linear approximations) --------------------

Color _apply(Color c, List<double> m) => Color.from(
  alpha: 1,
  red: (m[0] * c.r + m[1] * c.g + m[2] * c.b).clamp(0.0, 1.0),
  green: (m[3] * c.r + m[4] * c.g + m[5] * c.b).clamp(0.0, 1.0),
  blue: (m[6] * c.r + m[7] * c.g + m[8] * c.b).clamp(0.0, 1.0),
);

Color _deuteranopia(Color c) =>
    _apply(c, [0.625, 0.375, 0.0, 0.70, 0.30, 0.0, 0.0, 0.30, 0.70]);

Color _protanopia(Color c) =>
    _apply(c, [0.567, 0.433, 0.0, 0.558, 0.442, 0.0, 0.0, 0.242, 0.758]);

Color _tritanopia(Color c) =>
    _apply(c, [0.95, 0.05, 0.0, 0.0, 0.433, 0.567, 0.0, 0.475, 0.525]);

const _simulations = <String, Color Function(Color)>{
  'deuteranopia': _deuteranopia,
  'protanopia': _protanopia,
  'tritanopia': _tritanopia,
};
