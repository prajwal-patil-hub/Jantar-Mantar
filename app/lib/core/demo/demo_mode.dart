import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo Mode: runs every screen against local sample data with NO backend and
/// NO login, so the app can be explored end-to-end (groups, chat, admin
/// verification queue, events) before Supabase is configured.
///
/// Defaults ON. Turn it off in Profile → Demo mode once the backend is live;
/// the app then uses the real Supabase-backed repositories.
final demoModeProvider = NotifierProvider<DemoModeNotifier, bool>(
  DemoModeNotifier.new,
);

class DemoModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}
