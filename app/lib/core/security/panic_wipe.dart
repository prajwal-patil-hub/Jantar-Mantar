import 'package:supabase_flutter/supabase_flutter.dart';

import '../crypto/key_store.dart';
import '../db/app_database.dart';

/// Panic action (SECURITY.md, device-seizure row): erase everything on this
/// device that could identify the user or their groups, in the order that
/// leaves the smallest window if the process is killed mid-way.
///
/// **What it does:** drops every secret in the OS keystore (device identity +
/// all group-key epochs), clears the local database (cached chat ciphertext,
/// submissions, the outbox, alerts and cached facilities), and ends the
/// session.
///
/// **What it cannot do**, and the UI must say so: it cannot reach the server
/// or other members' devices. Messages already delivered stay delivered, and
/// server-side membership rows are unaffected. This makes *this handset*
/// uninformative — nothing more.
class PanicWipe {
  // Private fields behind named public params, as elsewhere in the codebase.
  // ignore_for_file: prefer_initializing_formals
  const PanicWipe({
    required AppDatabase db,
    required KeyStore keyStore,
    SupabaseClient? client,
  }) : _db = db,
       _keyStore = keyStore,
       _client = client;

  final AppDatabase _db;
  final KeyStore _keyStore;
  final SupabaseClient? _client;

  Future<void> run() async {
    // Keys first. Without them the cached ciphertext is already unreadable,
    // so an interrupted wipe still fails safe.
    await _keyStore.deleteAll();

    await _db.transaction(() async {
      for (final table in _db.allTables) {
        await _db.delete(table).go();
      }
    });

    // Local scope: clear the session on this device without a network round
    // trip, which may not be available and must not block the wipe.
    try {
      await _client?.auth.signOut(scope: SignOutScope.local);
    } on Object {
      // Already signed out, or no backend configured.
    }
  }
}
