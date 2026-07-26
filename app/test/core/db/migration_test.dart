import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;
import 'generated_migrations/schema_v2.dart' as v2;

/// Migrations are the one thing a user cannot retry: get them wrong and an
/// installed app either crashes on launch or silently drops data. These run
/// the real `MigrationStrategy` against real historical schemas.
///
/// Snapshots live in `drift_schemas/`. **Dump a new one before every schema
/// change** (`dart run drift_dev schema dump lib/core/db/app_database.dart
/// drift_schemas/`), then regenerate the helpers here.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('every step upgrades to the current schema', () async {
    // Covers v1→v2, v2→v3 and the full v1→v3 path in one sweep, and asserts
    // the resulting schema matches what the current code expects exactly.
    for (final start in [1, 2]) {
      final connection = await verifier.startAt(start);
      final db = AppDatabase(connection);
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 3);
    }
  });

  test('v1 → v3 keeps the data a real user already had', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());

    // The generated historical schemas expose raw tables, so write through
    // RawValuesInsertable — this is genuinely the old shape, not the new one.
    await old
        .into(old.facilities)
        .insert(
          RawValuesInsertable({
            'id': Variable('f1'),
            'name': Variable('Water point, Gate 2'),
            'type': Variable('water'),
            'status': Variable('good'),
            'lat': Variable(28.627),
            'lng': Variable(77.216),
            'updated_at': Variable(_epoch(DateTime.utc(2026, 7, 20))),
          }),
        );
    await old
        .into(old.submissions)
        .insert(
          RawValuesInsertable({
            'id': Variable('s1'),
            'payload': Variable('{"note":"queued before the upgrade"}'),
            'state': Variable('pending'),
            'created_at': Variable(_epoch(DateTime.utc(2026, 7, 20))),
          }),
        );
    await old.close();

    final migrated = AppDatabase(schema.newConnection());
    addTearDown(migrated.close);

    // A pending submission surviving matters most: it is work the user did
    // offline and has not synced yet.
    final submissions = await migrated.select(migrated.submissions).get();
    expect(submissions.single.payload, contains('queued before the upgrade'));
    final facilities = await migrated.select(migrated.facilities).get();
    expect(facilities.single.name, 'Water point, Gate 2');

    // And the table v2 introduced is now usable.
    await migrated
        .into(migrated.cachedGroupMessages)
        .insert(
          CachedGroupMessagesCompanion.insert(
            id: 'm1',
            groupId: 'g1',
            senderId: 'u1',
            ciphertext: 'CIPHER',
            createdAt: DateTime.utc(2026, 7, 26),
          ),
        );
    expect(await migrated.select(migrated.cachedGroupMessages).get(),
        hasLength(1));
  });

  test('v2 → v3 keeps cached chat and defaults its epoch to 1', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());

    await old
        .into(old.cachedGroupMessages)
        .insert(
          RawValuesInsertable({
            'id': Variable('m1'),
            'group_id': Variable('g1'),
            'sender_id': Variable('u1'),
            'ciphertext': Variable('CIPHER-FROM-V2'),
            'created_at': Variable(_epoch(DateTime.utc(2026, 7, 25))),
          }),
        );
    await old.close();

    final migrated = AppDatabase(schema.newConnection());
    addTearDown(migrated.close);

    // Messages written before rotation existed are epoch 1 by definition —
    // if the default were wrong, existing chat would become undecryptable.
    final row = (await migrated.select(migrated.cachedGroupMessages).get())
        .single;
    expect(row.ciphertext, 'CIPHER-FROM-V2');
    expect(row.keyEpoch, 1);
  });
}

/// Drift stores DateTime columns as unix seconds by default.
int _epoch(DateTime value) => value.millisecondsSinceEpoch ~/ 1000;
