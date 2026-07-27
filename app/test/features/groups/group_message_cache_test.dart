import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/features/groups/data/group_message_cache.dart';

void main() {
  late AppDatabase db;
  late GroupMessageCache cache;
  final t0 = DateTime.utc(2026, 7, 26, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    cache = GroupMessageCache(db);
  });
  tearDown(() async => db.close());

  CachedGroupMessagesCompanion server(String id, {int minute = 0}) =>
      CachedGroupMessagesCompanion.insert(
        id: id,
        groupId: 'g1',
        senderId: 'u1',
        ciphertext: 'CIPHER-$id',
        createdAt: t0.add(Duration(minutes: minute)),
      );

  test(
    'server messages are upserted, scoped by group, and time-ordered',
    () async {
      await cache.saveServerMessages([
        server('b', minute: 2),
        server('a', minute: 1),
        CachedGroupMessagesCompanion.insert(
          id: 'other',
          groupId: 'g2',
          senderId: 'u9',
          ciphertext: 'CIPHER-other',
          createdAt: t0,
        ),
      ]);

      expect((await cache.load('g1')).map((m) => m.id), ['a', 'b']);
      expect((await cache.load('g2')).map((m) => m.id), ['other']);

      // Re-fetching the same rows must not duplicate them.
      await cache.saveServerMessages([server('a', minute: 1)]);
      expect(await cache.load('g1'), hasLength(2));
    },
  );

  test(
    'only ciphertext is persisted — a dumped DB leaks no plaintext',
    () async {
      await cache.saveServerMessages([server('a')]);
      final row = (await cache.load('g1')).single;
      // The row carries no plaintext column at all; ciphertext is all we keep.
      expect(row.ciphertext, 'CIPHER-a');
      expect(row.toJson().values.join(' '), isNot(contains('hello')));
    },
  );

  test('queued outgoing messages are pending until the server acks', () async {
    await cache.queueOutgoing(
      CachedGroupMessagesCompanion.insert(
        id: 'local:1',
        groupId: 'g1',
        senderId: 'me',
        ciphertext: 'CIPHER-queued',
        createdAt: t0,
        pending: const Value(true),
      ),
    );

    expect((await cache.pendingOutgoing('g1')).map((m) => m.id), ['local:1']);
    // Pending messages still show in the chat while they wait.
    expect((await cache.load('g1')).single.pending, isTrue);

    await cache.replacePending(
      localId: 'local:1',
      server: CachedGroupMessagesCompanion.insert(
        id: 'server-1',
        groupId: 'g1',
        senderId: 'me',
        ciphertext: 'CIPHER-queued',
        createdAt: t0,
      ),
    );

    expect(await cache.pendingOutgoing('g1'), isEmpty);
    final rows = await cache.load('g1');
    expect(rows.single.id, 'server-1');
    expect(rows.single.pending, isFalse);
  });

  test('clearGroup and wipe forget cached chat', () async {
    await cache.saveServerMessages([
      server('a'),
      CachedGroupMessagesCompanion.insert(
        id: 'other',
        groupId: 'g2',
        senderId: 'u9',
        ciphertext: 'C',
        createdAt: t0,
      ),
    ]);

    await cache.clearGroup('g1');
    expect(await cache.load('g1'), isEmpty);
    expect(await cache.load('g2'), hasLength(1));

    await cache.wipe();
    expect(await cache.load('g2'), isEmpty);
  });
}
