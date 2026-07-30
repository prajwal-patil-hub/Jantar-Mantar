import 'package:flutter/material.dart';

/// Semantic facility-status colors. These are NEVER derived from the theme
/// seed and never change between themes (SECURITY/DESIGN rule) — status is
/// always conveyed as color + icon + text, never color alone.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.good,
    required this.low,
    required this.out,
    required this.unverified,
  });

  final Color good;
  final Color low;
  final Color out;
  final Color unverified;

  /// Measured in `test/core/theme/color_accessibility_test.dart`, which is the
  /// gate — change a value here and that test tells you what it cost.
  static const StatusColors standard = StatusColors(
    good: Color(0xFF2E7D32), // ✓  5.00:1 light · 3.63:1 dark
    low: Color(0xFFF9A825), // !  see the note below
    out: Color(0xFFC62828), // ✕  5.48:1 light · 3.31:1 dark
    // Was #9E9E9E (2.43:1 on the light card — under the 3:1 bar for
    // graphics), then #616161, which fixed light and quietly failed dark:
    // 3.06:1 on the dark *scaffold* but only **2.75:1 on the dark card**,
    // and a map pin paints its glyph on the card. The old test measured the
    // scaffold only, calling it "the worst case" — true on light, where the
    // scaffold is the darker ground, and false on dark, where the card is
    // the lighter one. Both grounds are measured now.
    //
    // #767472 is the one value that clears 3:1 on all four painted grounds
    // (worst 3.66:1) while *improving* CVD separation from the other
    // statuses, 0.183 → 0.248. Warm-biased rather than pure grey so it sits
    // in the Soft Geometry ramp instead of on top of it.
    unverified: Color(0xFF767472), // ?  3.68:1 light card · 3.66:1 dark card
  );

  // Why `low` stays a bright amber despite measuring only 1.92:1 on the light
  // surface: every darker amber that clears 3:1 collapses against the red
  // "Out" under all three CVD simulations (#C07000 scores 0.036 separation,
  // versus 0.26 today). "Low" versus "Out" is the most consequential
  // distinction on the map — is there water left or not — so separability wins
  // over fill contrast, and the shortfall is covered by the rule that status
  // is always icon + text as well, never colour alone. Revisit only with a
  // palette that satisfies both.

  @override
  StatusColors copyWith({
    Color? good,
    Color? low,
    Color? out,
    Color? unverified,
  }) {
    return StatusColors(
      good: good ?? this.good,
      low: low ?? this.low,
      out: out ?? this.out,
      unverified: unverified ?? this.unverified,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      good: Color.lerp(good, other.good, t)!,
      low: Color.lerp(low, other.low, t)!,
      out: Color.lerp(out, other.out, t)!,
      unverified: Color.lerp(unverified, other.unverified, t)!,
    );
  }
}
