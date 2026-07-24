import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// Queues an SOS signal through the same outbox as everything else, so it
/// syncs the moment any connection returns. Direct emergency calls never
/// depend on this — the SOS screen always offers dialing regardless.
/// No location is attached yet: coarse/opt-in location is a later,
/// per-action decision (privacy rules).
class SosRepository {
  SosRepository(this._db, {this._uuid = const Uuid()});

  final AppDatabase _db;
  final Uuid _uuid;

  Future<void> fireSos({DateTime? now}) async {
    final at = now ?? DateTime.now();
    await _db
        .into(_db.syncQueueEntries)
        .insert(
          SyncQueueEntriesCompanion.insert(
            op: SyncOp.create,
            entity: 'sos',
            entityId: _uuid.v4(),
            payload: jsonEncode({'firedAt': at.toIso8601String()}),
            nextAttemptAt: at,
            createdAt: at,
          ),
        );
  }
}
