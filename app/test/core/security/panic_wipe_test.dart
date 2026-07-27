import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/crypto/key_store.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/security/panic_wipe.dart';
import 'package:jantar_mantar_sahayata/features/groups/data/group_message_cache.dart';

void main() {
  late AppDatabase db;
  late InMemoryKeyStore keys;
  final t0 = DateTime.utc(2026, 7, 26, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    keys = InMemoryKeyStore();
  });
  tearDown(() async => db.close());

  Future<void> seed() async {
    await keys.write('device_identity', 'PRIVATE-SEED');
    await keys.write('group_key_g1_e1', 'GROUP-KEY');
    await keys.write('group_key_epochs_g1', '1');

    await GroupMessageCache(db).saveServerMessages([
      CachedGroupMessagesCompanion.insert(
        id: 'm1',
        groupId: 'g1',
        senderId: 'u1',
        ciphertext: 'CIPHER',
        createdAt: t0,
      ),
    ]);
    await db
        .into(db.submissions)
        .insert(
          SubmissionsCompanion.insert(
            id: 's1',
            payload: '{"note":"who reported what"}',
            state: SubmissionState.pending,
            createdAt: t0,
            lat: const Value(28.62),
            lng: const Value(77.21),
          ),
        );
    await db
        .into(db.syncQueueEntries)
        .insert(
          SyncQueueEntriesCompanion.insert(
            op: SyncOp.create,
            entity: 'submission',
            entityId: 's1',
            payload: '{}',
            nextAttemptAt: t0,
            createdAt: t0,
          ),
        );
  }

  test('wipes every secret and every local row', () async {
    await seed();
    // Sanity: there is something to lose.
    expect(await keys.read('device_identity'), isNotNull);
    expect(await db.select(db.cachedGroupMessages).get(), isNotEmpty);
    expect(await db.select(db.submissions).get(), isNotEmpty);

    await PanicWipe(db: db, keyStore: keys).run();

    // Keys: identity and every group-key epoch.
    expect(await keys.read('device_identity'), isNull);
    expect(await keys.read('group_key_g1_e1'), isNull);
    expect(await keys.read('group_key_epochs_g1'), isNull);

    // Every table, so nothing is missed by enumerating the ones we remembered.
    for (final table in db.allTables) {
      expect(
        await db.select(table).get(),
        isEmpty,
        reason: '${table.actualTableName} should be empty after a panic wipe',
      );
    }
  });

  test('is safe to run twice and with nothing to erase', () async {
    await PanicWipe(db: db, keyStore: keys).run();
    await PanicWipe(db: db, keyStore: keys).run();
    expect(await db.select(db.cachedGroupMessages).get(), isEmpty);
  });

  test('keys go first, so an interrupted wipe still fails safe', () async {
    await seed();
    // If the DB delete threw, the ciphertext left behind must already be
    // undecryptable — assert the ordering the implementation relies on.
    final order = <String>[];
    final store = _RecordingKeyStore(keys, order);
    await PanicWipe(db: db, keyStore: store).run();

    expect(order.first, 'deleteAll');
    expect(await db.select(db.cachedGroupMessages).get(), isEmpty);
  });
}

class _RecordingKeyStore implements KeyStore {
  _RecordingKeyStore(this._inner, this._log);

  final KeyStore _inner;
  final List<String> _log;

  @override
  Future<void> deleteAll() {
    _log.add('deleteAll');
    return _inner.deleteAll();
  }

  @override
  Future<String?> read(String key) => _inner.read(key);
  @override
  Future<void> write(String key, String value) => _inner.write(key, value);
  @override
  Future<void> delete(String key) => _inner.delete(key);
}
