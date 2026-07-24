import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
