import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/remote_pull_service.dart';
import '../data/sync_worker.dart';

/// Background sync orchestration: anonymous sign-in (ADR-4) → drain the
/// outbox → pull fresh verified data, then repeat on a timer. Every step
/// tolerates being offline — failures just wait for the next cycle, and the
/// UI never depends on any of this having run.
class SyncService {
  SyncService({
    required this._client,
    required this._worker,
    required this._puller,
    this.interval = const Duration(seconds: 60),
  });

  final SupabaseClient? _client;
  final SyncWorker _worker;
  final RemotePullService? _puller;
  final Duration interval;

  Timer? _timer;
  bool _cycleRunning = false;

  /// Whether the last sync cycle reached the backend (ADR-33).
  ///
  /// Derived from what actually happened rather than from a connectivity
  /// plugin, on purpose: "the radio says Wi-Fi" and "our backend answered"
  /// are different facts, and during an internet shutdown they disagree in
  /// exactly the way that matters. It also avoids a new Android permission.
  ///
  /// Starts null — unknown, not offline — so nothing claims to be stale
  /// before the first cycle has had a chance to run.
  final ValueNotifier<bool?> reachable = ValueNotifier<bool?>(null);

  /// No-op when Supabase isn't configured/initialised (tests, web fallback).
  void start() {
    if (_client == null || _timer != null) return;
    _timer = Timer.periodic(interval, (_) => unawaited(runCycle()));
    unawaited(runCycle());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> runCycle() async {
    final client = _client;
    if (client == null || _cycleRunning) return;
    _cycleRunning = true;
    try {
      await _ensureSignedIn(client);
      await _worker.processQueue();
      await _puller?.pullAll();
      reachable.value = true;
    } on Object catch (e) {
      // Offline or backend not ready — queued writes stay queued.
      reachable.value = false;
      debugPrint('sync cycle skipped: $e');
    } finally {
      _cycleRunning = false;
    }
  }

  Future<void> _ensureSignedIn(SupabaseClient client) async {
    if (client.auth.currentSession != null) return;
    // Anonymous-by-default (ADR-4). Requires "Anonymous sign-ins" enabled
    // in the Supabase dashboard.
    await client.auth.signInAnonymously();
  }
}
