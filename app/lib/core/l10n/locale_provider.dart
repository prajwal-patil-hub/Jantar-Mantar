import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selected app locale. Persists across launches via SharedPreferences
/// (a non-sensitive UI preference — keys/tokens still go in secure storage).
/// Defaults to the device locale; the language toggle in Profile overrides it
/// and takes effect instantly (ui-ux-spec §1.12).
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  static const _prefsKey = 'app_locale';
  static const supported = [Locale('en'), Locale('hi')];

  @override
  Locale? build() => null; // null = follow the system locale.

  Future<void> load() async {
    // A preferences failure must never crash startup — fall back to the
    // system locale (offline-first: nothing blocks on infrastructure).
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null) state = Locale(code);
    } on Object {
      // Keep the system default.
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, locale.languageCode);
      }
    } on Object {
      // The in-memory choice still applies for this session.
    }
  }
}
