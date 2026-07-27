import 'package:flutter/material.dart';

import 'status_colors.dart';
import 'tokens.dart';

/// Material 3 themes seeded from the saffron accent over the neutral base.
/// Base font is Noto Sans with Noto Sans Devanagari as automatic fallback,
/// so Hindi renders with correct matras/conjuncts (DESIGN.md typography).
abstract final class AppTheme {
  static const _fontFamily = 'Noto Sans';
  static const _fontFallback = ['Noto Sans Devanagari'];

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.accent,
    ).copyWith(surface: AppTokens.surfaceLight, onSurface: AppTokens.ink);
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppTokens.accent,
      brightness: Brightness.dark,
    ).copyWith(surface: AppTokens.surfaceDark);
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
      extensions: const [StatusColors.standard],
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
