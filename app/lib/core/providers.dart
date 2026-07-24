import 'dart:async';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/alert_repository.dart';
import 'data/facility_repository.dart';
import 'data/remote_sync_api.dart';
import 'data/submission_repository.dart';
import 'data/sync_worker.dart';
import 'db/app_database.dart';
import 'db/dev_seed.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'commonground'));
  if (kDebugMode) {
    // Sample pins for development only; streams refresh when it lands.
    unawaited(seedDebugFacilities(db));
  }
  ref.onDispose(db.close);
  return db;
});

final facilityRepositoryProvider = Provider<FacilityRepository>(
  (ref) => FacilityRepository(ref.watch(appDatabaseProvider)),
);

final submissionRepositoryProvider = Provider<SubmissionRepository>(
  (ref) => SubmissionRepository(ref.watch(appDatabaseProvider)),
);

final alertRepositoryProvider = Provider<AlertRepository>(
  (ref) => AlertRepository(ref.watch(appDatabaseProvider)),
);

/// Swaps to the Supabase-backed implementation when E5/E8 land.
final remoteSyncApiProvider = Provider<RemoteSyncApi>(
  (ref) => const UnconfiguredRemoteApi(),
);

final syncWorkerProvider = Provider<SyncWorker>(
  (ref) => SyncWorker(
    ref.watch(appDatabaseProvider),
    ref.watch(remoteSyncApiProvider),
  ),
);
