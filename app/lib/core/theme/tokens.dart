import 'package:flutter/material.dart';

/// Design tokens from DESIGN.md. Change only via an ADR.
abstract final class AppTokens {
  /// Bold accent (locked choice: Saffron). Never used to convey facility
  /// status — status is always [StatusColors] + icon + text, so the accent's
  /// warmth cannot be confused with the amber "Low" state.
  static const Color accent = Color(0xFFFF6D1F);

  // Warm neutral base (ADR-32, "Soft Geometry"). Every value below was
  // chosen by measuring status contrast against it, not by eye — see
  // `test/core/theme/color_accessibility_test.dart`, which now reads these
  // tokens rather than a hardcoded near-white the app never painted.
  //
  // Light: sand is the scaffold, shell is the raised card/sheet.
  static const Color surfaceLight = Color(0xFFFAF3EA); // shell
  static const Color scaffoldLight = Color(0xFFEFE3D4); // sand
  static const Color ink = Color(0xFF3B2A1E); // cocoa
  static const Color inkMuted = Color(0xFF6E5744); // umber

  // Dark: deliberately deeper than the old #111214. The warm ground actually
  // *raises* the weakest status contrast (3.00 → 3.06) rather than costing it.
  static const Color surfaceDark = Color(0xFF241A13);
  static const Color scaffoldDark = Color(0xFF160F0A);
  static const Color inkDark = Color(0xFFF5EADC);
  static const Color inkMutedDark = Color(0xFFB39A83);

  /// Filled-action tone. A desaturated member of the [accent] hue family, so
  /// large filled surfaces read as warm rather than as six saffron blocks.
  /// Never used for status.
  /// #A5713F matched the reference more closely but put cream label text at
  /// only 3.93:1 — under the 4.5 body bar, caught by the contrast test.
  /// Darkened until the label reads properly; the hue is unchanged.
  static const Color clay = Color(0xFF8C5A29);
  static const Color clayDark = Color(0xFFC08A52);
  static const Color onClay = Color(0xFFFFF7EE);

  /// In dark mode the action tone is *lighter* than the ground, so its label
  /// has to invert too. Using [onClay] on [clayDark] measures 2.83:1 — the
  /// contrast test catches it, which is why this token exists.
  static const Color onClayDark = Color(0xFF1A120C);

  // Glass surfaces (hero surfaces only — sheets, cards, nav, dialogs).
  static const double glassBlurSigma = 20;
  static const Color glassTintLight = Color(0xA6FFFFFF); // white @ 65%
  static const Color glassTintDark = Color(0x66000000); // black @ 40%
  static const Color glassBorder = Color(0x4DFFFFFF); // white @ 30%

  /// Opaque fallback for weak devices / battery saver / outdoor mode:
  /// same layout, no blur.
  static const Color glassFallbackLight = Color(0xD9FFFFFF); // white @ 85%
  static const Color glassFallbackDark = Color(0xD9111214);

  // Radii scale (ADR-32). One scale, applied through the theme, so the shape
  // language holds by construction instead of by per-screen discipline.
  static const double radiusChip = 14;
  static const double radiusCard = 22;
  static const double radiusPanel = 28;
  static const double radiusPill = 999;

  // Touch targets (emergency UX: generous under stress).
  static const double minTouchTarget = 48;
  static const double primaryTouchTarget = 56;
  static const double sosTouchTarget = 60;
}
