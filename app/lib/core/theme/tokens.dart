import 'package:flutter/material.dart';

/// Design tokens from DESIGN.md. Change only via an ADR.
abstract final class AppTokens {
  /// Bold accent (locked choice: Saffron). Never used to convey facility
  /// status — status is always [StatusColors] + icon + text, so the accent's
  /// warmth cannot be confused with the amber "Low" state.
  static const Color accent = Color(0xFFFF6D1F);

  // Neutral base.
  static const Color surfaceLight = Color(0xFFFAFAF8);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF111214);

  // Glass surfaces (hero surfaces only — sheets, cards, nav, dialogs).
  static const double glassBlurSigma = 20;
  static const Color glassTintLight = Color(0xA6FFFFFF); // white @ 65%
  static const Color glassTintDark = Color(0x66000000); // black @ 40%
  static const Color glassBorder = Color(0x4DFFFFFF); // white @ 30%

  /// Opaque fallback for weak devices / battery saver / outdoor mode:
  /// same layout, no blur.
  static const Color glassFallbackLight = Color(0xD9FFFFFF); // white @ 85%
  static const Color glassFallbackDark = Color(0xD9111214);

  // Touch targets (emergency UX: generous under stress).
  static const double minTouchTarget = 48;
  static const double primaryTouchTarget = 56;
  static const double sosTouchTarget = 60;
}
