import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers.dart';

/// Server-side pending submissions for the admin queue (server-only data —
/// this is the one screen that legitimately needs to be online; RLS lets
/// only admins read other users' submissions).
final pendingServerSubmissionsProvider = FutureProvider.autoDispose
    .family<List<Map<String, Object?>>, int>((ref, refreshTick) async {
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
