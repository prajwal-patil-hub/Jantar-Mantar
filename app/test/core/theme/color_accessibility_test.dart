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
  // surface that did not exist — found while adopting Soft Geometry
  // (ADR-32). Measure the scaffold, not the card: it is the darker of the two
  // on light and therefore the worst case.
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

    // These must clear the bar on BOTH surfaces, in both themes.
    for (final name in ['good', 'out', 'unverified', 'info']) {
      test('$name is legible on light and dark', () {
        expect(
          _contrast(swatches[name]!, lightSurface),
          greaterThanOrEqualTo(bar),
          reason: 'light: ${_ratio(swatches[name]!, lightSurface)}',
        );
        expect(
          _contrast(swatches[name]!, darkSurface),
          greaterThanOrEqualTo(bar),
          reason: 'dark: ${_ratio(swatches[name]!, darkSurface)}',
        );
      });
    }

    test('low trades light-surface contrast for CVD separability', () {
      // Deliberate: every darker amber that clears 3:1 collapses against the
      // red "Out" under CVD (see the note in StatusColors). Pinned so the
      // trade-off stays visible and cannot drift further.
      //
      // Was 1.92 against a near-white that the app never actually painted.
      // Re-pinned at 1.56 against the real warm scaffold (ADR-32). The number
      // got worse; the reasoning did not change, and the CVD separation this
      // buys is asserted below and still passes. Amber on a warm ground is
      // the weakest point of this palette and the icon + text rule is what
      // carries it.
      expect(_contrast(colors.low, lightSurface), closeTo(1.56, 0.05));
      expect(
        _contrast(colors.low, darkSurface),
        greaterThanOrEqualTo(bar),
        reason: 'it must at least be strong on dark',
      );
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

    test('the card boundary is carried by the hairline, not by tone', () {
      // Soft Geometry is tone-on-tone, and tone-on-tone measures badly: a
      // shell card on the sand scaffold is only 1.15:1 (dark 1.11:1), well
      // under the 3:1 WCAG 1.4.11 asks of a UI component boundary. Pinned so
      // nobody "cleans up" the shadow and hairline as decoration — they are
      // the only thing making a card perceptible as a card.
      expect(
        _contrast(AppTokens.surfaceLight, AppTokens.scaffoldLight),
        closeTo(1.15, 0.03),
        reason: 'tone alone cannot carry this',
      );
      expect(
        _contrast(AppTokens.surfaceDark, AppTokens.scaffoldDark),
        closeTo(1.11, 0.03),
      );

      // So the hairline has to. It must clear 3:1 against BOTH the card it
      // outlines and the ground it sits on, or the edge disappears on one
      // side of itself.
      for (final ground in [AppTokens.surfaceLight, AppTokens.scaffoldLight]) {
        expect(
          _contrast(AppTokens.hairline, ground),
          greaterThanOrEqualTo(3.0),
          reason: _ratio(AppTokens.hairline, ground),
        );
      }
      for (final ground in [AppTokens.surfaceDark, AppTokens.scaffoldDark]) {
        expect(
          _contrast(AppTokens.hairlineDark, ground),
          greaterThanOrEqualTo(3.0),
          reason: _ratio(AppTokens.hairlineDark, ground),
        );
      }
    });

    test('body ink clears 4.5:1 on both grounds', () {
      // The warm palette is only safe if reading text on it is safe.
      expect(_contrast(AppTokens.ink, lightSurface), greaterThanOrEqualTo(4.5));
      expect(
        _contrast(AppTokens.inkMuted, lightSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppTokens.inkDark, darkSurface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('the saffron accent is pinned, not silently redefined', () {
      // ADR-10 is the owner's explicit choice, made aware of the trade-offs.
      // As a foreground on light it measures under 3:1, which is exactly why
      // ADR-10 forbids using the accent to convey status. Re-pinned from 2.75
      // for the warm scaffold (ADR-32) — saffron is not used as a foreground
      // on this ground anyway; filled actions use clay with light-on-dark
      // text, asserted separately below.
      expect(_contrast(saffron, lightSurface), closeTo(2.23, 0.05));
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
