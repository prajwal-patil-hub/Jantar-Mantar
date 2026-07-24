import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/data/remote_sync_api.dart';
import 'package:jantar_mantar_sahayata/core/data/submission_repository.dart';
import 'package:jantar_mantar_sahayata/core/data/sync_worker.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';

class _RecordingRemote implements RemoteSyncApi {
  final pushed = <SyncQueueEntry>[];

  @override
  Future<void> push(SyncQueueEntry entry) async => pushed.add(entry);
}

class _FailingRemote implements RemoteSyncApi {
  @override
  Future<void> push(SyncQueueEntry entry) async {
    throw const RemoteUnavailable();
  }
}

void main() {
  late AppDatabase db;
  late SubmissionRepository repo;
  final t0 = DateTime(2026, 7, 24, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SubmissionRepository(db);
  });

  tearDown(() async => db.close());

  test('successful push marks entries done, oldest first', () async {
    await repo.submit(payload: {'n': 1}, now: t0);
    await repo.submit(
      payload: {'n': 2},
      now: t0.add(const Duration(minutes: 1)),
    );

    final remote = _RecordingRemote();
    final report = await SyncWorker(
      db,
      remote,
    ).processQueue(now: t0.add(const Duration(minutes: 2)));

    expect(report.pushed, 2);
    expect(report.failed, 0);
    expect(remote.pushed, hasLength(2));
    expect(
      remote.pushed.first.createdAt.isBefore(remote.pushed.last.createdAt),
      isTrue,
    );

    final states = (await db.select(db.syncQueueEntries).get())
        .map((e) => e.state)
        .toSet();
    expect(states, {SyncState.done});
  });

  test('failed push backs off exponentially and stays pending', () async {
    await repo.submit(payload: {'n': 1}, now: t0);
    final worker = SyncWorker(db, _FailingRemote());

    final report = await worker.processQueue(now: t0);
    expect(report.failed, 1);

    var entry = (await db.select(db.syncQueueEntries).get()).single;
    expect(entry.state, SyncState.pending);
    expect(entry.attempts, 1);
    expect(entry.nextAttemptAt, t0.add(const Duration(seconds: 2)));

    // Not due yet → skipped.
    final early = await worker.processQueue(
      now: t0.add(const Duration(seconds: 1)),
    );
    expect(early.pushed + early.failed, 0);

    // Due again → second attempt doubles the delay.
    final t1 = t0.add(const Duration(seconds: 2));
    await worker.processQueue(now: t1);
    entry = (await db.select(db.syncQueueEntries).get()).single;
    expect(entry.attempts, 2);
    expect(entry.nextAttemptAt, t1.add(const Duration(seconds: 4)));
  });

  test(
    'entry fails permanently after maxAttempts, retryFailed re-arms it',
    () async {
      await repo.submit(payload: {'n': 1}, now: t0);
      final worker = SyncWorker(db, _FailingRemote(), maxAttempts: 2);

      await worker.processQueue(now: t0);
      await worker.processQueue(now: t0.add(const Duration(minutes: 1)));

      var entry = (await db.select(db.syncQueueEntries).get()).single;
      expect(entry.state, SyncState.failed);

      // Exhausted entries are never retried automatically.
      final after = await worker.processQueue(
        now: t0.add(const Duration(hours: 1)),
      );
      expect(after.pushed + after.failed, 0);

      await worker.retryFailed(now: t0.add(const Duration(hours: 2)));
      entry = (await db.select(db.syncQueueEntries).get()).single;
      expect(entry.state, SyncState.pending);
      expect(entry.attempts, 0);
    },
  );

  test('backoff is capped at maxDelay', () {
    final worker = SyncWorker(db, _FailingRemote());
    expect(worker.backoffAfter(1), const Duration(seconds: 2));
    expect(worker.backoffAfter(5), const Duration(seconds: 32));
    expect(worker.backoffAfter(20), const Duration(minutes: 10));
  });
}
