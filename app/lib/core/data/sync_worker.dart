import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'remote_sync_api.dart';

/// Result of one queue-draining pass.
class SyncReport {
  const SyncReport({required this.pushed, required this.failed});

  final int pushed;
  final int failed;
}

/// Drains the outbox oldest-first with exponential backoff
/// (ARCHITECTURE.md sync rule 2). Pure pull-the-queue logic — scheduling
/// (connectivity listeners, periodic timers) attaches on top later.
class SyncWorker {
  SyncWorker(
    this._db,
    this._remote, {
    this.baseDelay = const Duration(seconds: 2),
    this.maxDelay = const Duration(minutes: 10),
    this.maxAttempts = 12,
  });

  final AppDatabase _db;
  final RemoteSyncApi _remote;

  final Duration baseDelay;
  final Duration maxDelay;

  /// After this many failed attempts an entry becomes [SyncState.failed] and
  /// waits for manual retry from the pending-uploads tray.
  final int maxAttempts;

  Duration backoffAfter(int attempts) {
    final millis = baseDelay.inMilliseconds * (1 << (attempts - 1));
    return millis >= maxDelay.inMilliseconds
        ? maxDelay
        : Duration(milliseconds: millis);
  }

  Future<SyncReport> processQueue({DateTime? now}) async {
    final asOf = now ?? DateTime.now();
    final due =
        await (_db.select(_db.syncQueueEntries)
              ..where(
                (e) =>
                    e.state.equalsValue(SyncState.pending) &
                    e.nextAttemptAt.isSmallerOrEqualValue(asOf),
              )
              ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
            .get();

    var pushed = 0;
    var failed = 0;
    for (final entry in due) {
      final update = _db.update(_db.syncQueueEntries)
        ..where((e) => e.localId.equals(entry.localId));
      try {
        await _remote.push(entry);
        await update.write(
          const SyncQueueEntriesCompanion(state: Value(SyncState.done)),
        );
        pushed++;
      } on Exception {
        final attempts = entry.attempts + 1;
        await update.write(
          SyncQueueEntriesCompanion(
            attempts: Value(attempts),
            nextAttemptAt: Value(asOf.add(backoffAfter(attempts))),
            state: Value(
              attempts >= maxAttempts ? SyncState.failed : SyncState.pending,
            ),
          ),
        );
        failed++;
      }
    }
    return SyncReport(pushed: pushed, failed: failed);
  }

  /// Manual retry from the pending-uploads tray: re-arm failed entries.
  Future<void> retryFailed({DateTime? now}) async {
    final asOf = now ?? DateTime.now();
    await (_db.update(
      _db.syncQueueEntries,
    )..where((e) => e.state.equalsValue(SyncState.failed))).write(
      SyncQueueEntriesCompanion(
        state: const Value(SyncState.pending),
        attempts: const Value(0),
        nextAttemptAt: Value(asOf),
      ),
    );
  }
}
