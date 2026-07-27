import 'dart:async';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/alert_repository.dart';
import 'data/facility_repository.dart';
import 'data/remote_pull_service.dart';
import 'data/remote_sync_api.dart';
import 'data/sos_repository.dart';
import 'data/submission_repository.dart';
import 'data/supabase_remote_api.dart';
import 'data/sync_worker.dart';
import 'db/app_database.dart';
import 'db/demo_seed.dart';
import 'sync/sync_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(
    driftDatabase(
      name: 'commonground',
      // Web needs the sqlite3 WebAssembly module + drift worker, shipped in
      // web/. Native (Android/iOS/desktop) ignores this.
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
  ref.onDispose(db.close);
  return db;
});

/// Applies or removes the Demo Mode sample data (map pins, capacity readings,
/// public alerts) to match [on].
///
/// Deliberately NOT wired into [appDatabaseProvider]: making the database
/// depend on the demo flag would tear down and recreate the whole DB every
/// time the toggle flips. Called from the shell once the saved choice loads,
/// and again whenever the user changes it.
Future<void> applyDemoSeed(AppDatabase db, {required bool on}) async {
  if (on) {
    await seedDemoFacilities(db);
  } else {
    await removeDemoSeed(db);
  }
}

final facilityRepositoryProvider = Provider<FacilityRepository>(
  (ref) => FacilityRepository(ref.watch(appDatabaseProvider)),
);

final submissionRepositoryProvider = Provider<SubmissionRepository>(
  (ref) => SubmissionRepository(ref.watch(appDatabaseProvider)),
);

final alertRepositoryProvider = Provider<AlertRepository>(
  (ref) => AlertRepository(ref.watch(appDatabaseProvider)),
);

final sosRepositoryProvider = Provider<SosRepository>(
  (ref) => SosRepository(ref.watch(appDatabaseProvider)),
);

/// Null until `main()` initialises Supabase and overrides this — tests and
/// unsupported platforms keep null, and everything downstream degrades to
/// offline-only queueing.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);

final remoteSyncApiProvider = Provider<RemoteSyncApi>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const UnconfiguredRemoteApi();
  return SupabaseRemoteApi(ref.watch(appDatabaseProvider), client);
});

final syncWorkerProvider = Provider<SyncWorker>(
  (ref) => SyncWorker(
    ref.watch(appDatabaseProvider),
    ref.watch(remoteSyncApiProvider),
  ),
);

final syncServiceProvider = Provider<SyncService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final service = SyncService(
    client: client,
    worker: ref.watch(syncWorkerProvider),
    puller: client == null
        ? null
        : RemotePullService(ref.watch(appDatabaseProvider), client),
  );
  ref.onDispose(service.stop);
  return service;
});
