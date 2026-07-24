import 'package:flutter/material.dart';

import 'status_colors.dart';
import 'tokens.dart';

/// Material 3 themes seeded from the saffron accent over the neutral base.
/// Noto Sans / Noto Sans Devanagari get bundled with the i18n task (E9).
abstract final class AppTheme {
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
      extensions: const [StatusColors.standard],
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
