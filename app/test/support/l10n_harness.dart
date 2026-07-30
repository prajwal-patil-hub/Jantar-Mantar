import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jantar_mantar_sahayata/core/theme/app_theme.dart';
import 'package:jantar_mantar_sahayata/l10n/app_localizations.dart';

/// Localization delegates for tests that build their own MaterialApp.
/// Defaults to English (test locale) unless a widget overrides it.
const testLocalizationsDelegates = <LocalizationsDelegate<Object?>>[
  AppL10n.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

final testSupportedLocales = AppL10n.supportedLocales;

/// The theme the app actually ships, for tests that build their own
/// MaterialApp.
///
/// Nine test files used to build one with no theme at all, which means they
/// rendered a widget tree that does not exist outside the test: stock Material
/// radii, stock colours, and — the one that actually bit — **no `StatusColors`
/// ThemeExtension**, so any widget reading a status colour from the theme threw
/// a null-check error the moment it stopped hardcoding hexes.
///
/// Pass this wherever a test builds its own app, so the thing under test is
/// the thing that ships.
ThemeData testAppTheme() => AppTheme.light();
