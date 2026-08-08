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
      surfaceContainerHighest: AppTokens.e2Light,
      surfaceContainerHigh: AppTokens.e2Light,
      surfaceContainerLow: AppTokens.e4Light,
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
          surfaceContainerHighest: AppTokens.e2Dark,
          surfaceContainerHigh: AppTokens.e2Dark,
          surfaceContainerLow: AppTokens.e4Dark,
          primary: AppTokens.clayDark,
          onPrimary: AppTokens.onClayDark,
        );
    return _base(scheme, AppTokens.scaffoldDark);
  }

  /// A saffron ring on focus and nothing otherwise, so keyboard and
  /// switch-control users can see where they are (ADR-34). Resolved per
  /// state rather than set flat, because a permanent ring reads as an error.
  static WidgetStateProperty<BorderSide?> _focusSide({BorderSide? rest}) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return const BorderSide(
          color: AppTokens.focusRing,
          width: AppTokens.focusRingWidth,
        );
      }
      return rest;
    });
  }

  /// Soft Geometry (ADR-32): one radii scale applied through component
  /// themes, so every card, sheet, chip and button picks it up without a
  /// single screen restating it.
  static ThemeData _base(ColorScheme scheme, Color scaffold) {
    final dark = scheme.brightness == Brightness.dark;
    final hairline = dark ? AppTokens.hairlineDark : AppTokens.hairline;
    final shadow = dark ? AppTokens.shadowTintDark : AppTokens.shadowTint;
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
      // Depth carries the card boundary, which measures 1.15:1 on tone alone.
      // Shadow AND hairline: the hairline is what survives direct sunlight
      // and the no-blur outdoor path.
      cardTheme: CardThemeData(
        shape: card.copyWith(
          side: BorderSide(color: hairline.withValues(alpha: 0.34)),
        ),
        color: scheme.surface,
        shadowColor: shadow,
        elevation: 2,
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(
          side: BorderSide(color: hairline.withValues(alpha: 0.34)),
        ),
        side: BorderSide.none,
        backgroundColor: scheme.surface,
      ),
      // Snackbars are this app's main feedback channel — every approve,
      // reject, save and share ends in one — so they get the same shape
      // language rather than a stock Material rectangle.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppTokens.surfaceDark : AppTokens.ink,
        contentTextStyle: TextStyle(
          color: dark ? AppTokens.inkDark : AppTokens.onClay,
          fontFamily: _fontFamily,
          fontFamilyFallback: _fontFallback,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
        ),
        insetPadding: const EdgeInsets.all(14),
      ),
      dividerTheme: DividerThemeData(
        color: hairline.withValues(alpha: 0.28),
        space: 1,
        thickness: 1,
      ),
      // Stadium CTAs, at the emergency touch target rather than Material's
      // default 40 — this app is operated under stress, one-handed.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(0, AppTokens.primaryTouchTarget),
        ).copyWith(side: _focusSide()),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              minimumSize: const Size(0, AppTokens.primaryTouchTarget),
            ).copyWith(
              side: _focusSide(rest: BorderSide(color: hairline)),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(0, AppTokens.minTouchTarget),
        ).copyWith(side: _focusSide()),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppTokens.minTouchTarget),
        ).copyWith(side: _focusSide()),
      ),
      // The ring itself, for anything that paints its own focus (ink wells,
      // list tiles). WCAG 2.4.7 — this app had no visible focus state at all.
      focusColor: AppTokens.focusRing.withValues(alpha: 0.16),
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
