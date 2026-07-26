import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/demo/demo_mode.dart';
import '../../../core/providers.dart';

/// Sample pending submissions so the verification queue is explorable in
/// Demo Mode (no backend, no admin login).
final demoPendingQueueProvider =
    NotifierProvider<DemoPendingQueue, List<Map<String, Object?>>>(
      DemoPendingQueue.new,
    );

class DemoPendingQueue extends Notifier<List<Map<String, Object?>>> {
  @override
  List<Map<String, Object?>> build() {
    final now = DateTime.now();
    String at(int minutesAgo) =>
        now.subtract(Duration(minutes: minutesAgo)).toIso8601String();
    return [
      {
        'id': 'demo-sub-1',
        'created_at': at(4),
        'lat': 28.6281,
        'lng': 77.2163,
        'payload': {
          'category': 'water',
          'status': 'good',
          'forPeople': 200,
          'mode': 'new',
          'note': 'New tanker just arrived at Gate 1',
        },
      },
      {
        'id': 'demo-sub-2',
        'created_at': at(11),
        'lat': 28.6249,
        'lng': 77.2175,
        'payload': {
          'category': 'food',
          'status': 'low',
          'forPeople': 50,
          'mode': 'update',
          'note': 'Langar running low, ~30 min left',
        },
      },
      {
        'id': 'demo-sub-3',
        'created_at': at(23),
        'lat': 28.6302,
        'lng': 77.2188,
        'payload': {
          'category': 'medical',
          'status': 'good',
          'mode': 'new',
          'note': 'Volunteer doctor set up a second first-aid point',
        },
      },
      {
        'id': 'demo-sub-4',
        'created_at': at(38),
        'lat': 28.6260,
        'lng': 77.2140,
        'payload': {
          'category': 'toilet',
          'status': 'out',
          'mode': 'update',
          'note': 'Portable toilets locked',
        },
      },
    ];
  }

  void remove(String id) => state = [...state.where((row) => row['id'] != id)];
}

/// Server-side pending submissions for the admin queue (server-only data —
/// this is the one screen that legitimately needs to be online; RLS lets
/// only admins read other users' submissions).
final pendingServerSubmissionsProvider = FutureProvider.autoDispose
    .family<List<Map<String, Object?>>, int>((ref, refreshTick) async {
      // Demo Mode: local sample queue, no backend or admin login required.
      if (ref.watch(demoModeProvider)) {
        return ref.watch(demoPendingQueueProvider);
      }
      final client = ref.watch(supabaseClientProvider);
      if (client == null) return const [];
      final rows = await client
          .from('submissions')
          .select()
          .eq('state', 'pending')
          .order('created_at', ascending: true);
      return List<Map<String, Object?>>.from(rows);
    });

/// True when the signed-in session carries the server-set admin role.
/// Display gating only — the backend re-checks on every call.
bool isAdminSession(SupabaseClient? client) {
  final metadata = client?.auth.currentUser?.appMetadata;
  return metadata != null && metadata['role'] == 'admin';
}

/// Whether the app should show admin/verifier screens: real admin session, or
/// Demo Mode (which grants a simulated admin view with sample data).
final canVerifyProvider = Provider<bool>((ref) {
  if (ref.watch(demoModeProvider)) return true;
  ref.watch(authChangesForVerifyProvider);
  return isAdminSession(ref.watch(supabaseClientProvider));
});

/// Rebuilds [canVerifyProvider] when the session changes.
final authChangesForVerifyProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const Stream.empty();
  return client.auth.onAuthStateChange;
});
