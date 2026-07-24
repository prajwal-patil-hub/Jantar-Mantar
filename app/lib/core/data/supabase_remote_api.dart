import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../db/app_database.dart';
import 'remote_sync_api.dart';

/// Pushes outbox entries to Supabase. Row payloads carry the client-local
/// UUID as `client_id`; the server's unique constraint makes retries
/// idempotent, so a duplicate insert after a lost ACK is harmless.
class SupabaseRemoteApi implements RemoteSyncApi {
  SupabaseRemoteApi(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  @override
  Future<void> push(SyncQueueEntry entry) async {
    try {
      switch (entry.entity) {
        case 'submission':
          final row = await submissionRow(entry);
          if (row == null) return; // Local row vanished; nothing to send.
          await _client.from('submissions').insert(row);
        case 'sos':
          await _client.from('sos_signals').insert(sosRow(entry));
        default:
          throw UnsupportedError('Unknown outbox entity: ${entry.entity}');
      }
    } on PostgrestException catch (e) {
      // 23505 = unique_violation on client_id: an earlier attempt landed
      // but the ACK was lost. Already synced — treat as success.
      if (e.code == '23505') return;
      throw RemoteUnavailable('Server rejected push: ${e.message}');
    } on AuthException catch (e) {
      throw RemoteUnavailable('Not signed in: ${e.message}');
    } on UnsupportedError {
      rethrow;
    } on Object catch (e) {
      throw RemoteUnavailable('Network error: $e');
    }
  }

  Future<Map<String, Object?>?> submissionRow(SyncQueueEntry entry) async {
    final submission = await (_db.select(
      _db.submissions,
    )..where((s) => s.id.equals(entry.entityId))).getSingleOrNull();
    if (submission == null) return null;
    return {
      'client_id': submission.id,
      'facility_ref': submission.facilityId,
      'lat': submission.lat,
      'lng': submission.lng,
      'payload': jsonDecode(submission.payload),
    };
  }

  static Map<String, Object?> sosRow(SyncQueueEntry entry) {
    final payload = jsonDecode(entry.payload) as Map<String, Object?>;
    return {'client_id': entry.entityId, 'fired_at': payload['firedAt']};
  }
}
