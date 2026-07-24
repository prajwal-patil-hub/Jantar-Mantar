import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/data/submission_repository.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';

void main() {
  late AppDatabase db;
  late SubmissionRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SubmissionRepository(db);
  });

  tearDown(() async => db.close());

  test(
    'submit stores a pending submission and its outbox entry atomically',
    () async {
      final id = await repo.submit(
        payload: {'category': 'water', 'forPeople': 200, 'status': 'good'},
        lat: 28.6270,
        lng: 77.2160,
        now: DateTime(2026, 7, 24, 12),
      );

      final submissions = await db.select(db.submissions).get();
      expect(submissions, hasLength(1));
      expect(submissions.single.id, id);
      expect(submissions.single.state, SubmissionState.pending);

      final queue = await db.select(db.syncQueueEntries).get();
      expect(queue, hasLength(1));
      expect(queue.single.entity, 'submission');
      expect(queue.single.entityId, id);
      expect(queue.single.op, SyncOp.create);
      expect(queue.single.state, SyncState.pending);
      expect(queue.single.attempts, 0);
    },
  );

  test('watchPendingCount reflects pending submissions', () async {
    expect(await repo.watchPendingCount().first, 0);
    await repo.submit(payload: {'category': 'food'});
    await repo.submit(payload: {'category': 'shelter'});
    expect(await repo.watchPendingCount().first, 2);
  });

  test('watchMine returns newest first', () async {
    await repo.submit(
      payload: {'category': 'water'},
      now: DateTime(2026, 7, 24, 10),
    );
    final newest = await repo.submit(
      payload: {'category': 'medical'},
      now: DateTime(2026, 7, 24, 11),
    );

    final mine = await repo.watchMine().first;
    expect(mine.first.id, newest);
  });
}
