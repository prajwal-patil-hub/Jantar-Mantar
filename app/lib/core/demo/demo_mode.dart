import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Demo Mode: runs every screen against local sample data with NO backend and
/// NO login, so the app can be explored end-to-end (groups, chat, admin
/// verification queue, events) before Supabase is configured.
///
/// Defaults ON and persists across launches. Turn it off in Profile → Demo
/// mode once the backend is live; the app then uses the real Supabase-backed
/// repositories.
final demoModeProvider = NotifierProvider<DemoModeNotifier, bool>(
  DemoModeNotifier.new,
);

class DemoModeNotifier extends Notifier<bool> {
  static const _prefsKey = 'demo_mode';

  @override
  bool build() => true;

  /// Restore the saved choice. A preferences failure must never break
  /// startup — we simply keep the default.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefsKey);
      if (saved != null) state = saved;
    } on Object {
      // Keep the default.
    }
  }

  Future<void> set(bool value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } on Object {
      // The in-memory choice still applies for this session.
    }
  }
}
