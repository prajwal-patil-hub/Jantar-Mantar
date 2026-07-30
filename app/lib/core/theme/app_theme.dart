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
    final scheme = ColorScheme.fromSeed(seedColor: AppTokens.accent).copyWith(
      surface: AppTokens.surfaceLight,
      onSurface: AppTokens.ink,
      onSurfaceVariant: AppTokens.inkMuted,
      surfaceContainerHighest: AppTokens.scaffoldLight,
      primary: AppTokens.clay,
      onPrimary: AppTokens.onClay,
    );
    return _base(scheme, AppTokens.scaffoldLight);
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppTokens.accent,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppTokens.surfaceDark,
          onSurface: AppTokens.inkDark,
          onSurfaceVariant: AppTokens.inkMutedDark,
          surfaceContainerHighest: AppTokens.scaffoldDark,
          primary: AppTokens.clayDark,
          onPrimary: AppTokens.onClay,
        );
    return _base(scheme, AppTokens.scaffoldDark);
  }

  /// Soft Geometry (ADR-32): one radii scale applied through component
  /// themes, so every card, sheet, chip and button picks it up without a
  /// single screen restating it.
  static ThemeData _base(ColorScheme scheme, Color scaffold) {
    final card = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: _fontFamily,
      fontFamilyFallback: _fontFallback,
      extensions: const [StatusColors.standard],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      cardTheme: CardThemeData(
        shape: card,
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: scheme.surface,
      ),
      // Stadium CTAs, at the emergency touch target rather than Material's
      // default 40 — this app is operated under stress, one-handed.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(0, AppTokens.primaryTouchTarget),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(0, AppTokens.primaryTouchTarget),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusPanel),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(shape: card),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      listTileTheme: ListTileThemeData(shape: card),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
