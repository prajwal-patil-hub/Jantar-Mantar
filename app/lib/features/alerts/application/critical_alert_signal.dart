import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alerts_providers.dart';

/// Sound + vibration when a new CRITICAL alert arrives (E6, ui-ux-spec §1.10:
/// "optional sound/vibration").
///
/// Defaults are deliberately asymmetric. Vibration is **on**: a pocketed
/// phone can buzz without telling anyone nearby that you are getting protest
/// alerts. Sound is **off**: a phone that suddenly chimes in a kettle or a
/// police line identifies its owner, and that risk belongs to the user to
/// accept, not to us to impose. Both are togglable in Profile.
///
/// Uses only `flutter/services` — `HapticFeedback` and `SystemSound` need no
/// plugin, no permission and no notification channel, so this adds nothing to
/// the app's attack surface or its permission manifest.

/// Persisted boolean setting backed by SharedPreferences. Settings only —
/// never keys or tokens (those live in the OS keystore).
abstract class _PersistedFlag extends Notifier<bool> {
  String get prefsKey;
  bool get defaultValue;

  @override
  bool build() => defaultValue;

  /// A preferences failure must never break startup: keep the default.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(prefsKey);
      if (saved != null) state = saved;
    } on Object {
      // Keep the default.
    }
  }

  Future<void> set(bool value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefsKey, value);
    } on Object {
      // The in-memory choice still applies for this session.
    }
  }
}

class AlertHapticsNotifier extends _PersistedFlag {
  @override
  String get prefsKey => 'alert_haptics';
  @override
  bool get defaultValue => true;
}

class AlertSoundNotifier extends _PersistedFlag {
  @override
  String get prefsKey => 'alert_sound';
  @override
  bool get defaultValue => false;
}

final alertHapticsProvider = NotifierProvider<AlertHapticsNotifier, bool>(
  AlertHapticsNotifier.new,
);

final alertSoundProvider = NotifierProvider<AlertSoundNotifier, bool>(
  AlertSoundNotifier.new,
);

/// The actual platform effect, behind a seam so tests can observe it without
/// a platform channel.
typedef AlertSignalSink =
    Future<void> Function({required bool haptics, required bool sound});

Future<void> defaultAlertSignal({
  required bool haptics,
  required bool sound,
}) async {
  if (haptics) {
    // Two spaced heavy taps: distinguishable from an ordinary notification
    // buzz through a jacket, without being a long alarm.
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    await HapticFeedback.heavyImpact();
  }
  if (sound) {
    await SystemSound.play(SystemSoundType.alert);
  }
}

final alertSignalSinkProvider = Provider<AlertSignalSink>(
  (ref) => defaultAlertSignal,
);

/// Fires the signal once per critical alert id. Watch this anywhere the
/// critical banner is mounted; state is the id already signalled, so a
/// rebuild, a re-render or a re-read of the same alert stays silent.
final criticalAlertSignalProvider =
    NotifierProvider<CriticalAlertSignaller, String?>(
      CriticalAlertSignaller.new,
    );

class CriticalAlertSignaller extends Notifier<String?> {
  // Survives `build` re-runs (the notifier instance is retained), which is
  // what makes "once per alert" hold across dependency changes.
  String? _signalled;

  @override
  String? build() {
    final alert = ref.watch(criticalAlertProvider);
    if (alert == null) return null;
    if (alert.id == _signalled) return alert.id;
    _signalled = alert.id;

    // Read, not watch: turning the setting on later must not retroactively
    // buzz for an alert that is already on screen.
    final haptics = ref.read(alertHapticsProvider);
    final sound = ref.read(alertSoundProvider);
    if (haptics || sound) {
      final sink = ref.read(alertSignalSinkProvider);
      // Off the build turn — a provider build must not await a platform call.
      Future<void>.microtask(() => sink(haptics: haptics, sound: sound));
    }
    return alert.id;
  }
}
