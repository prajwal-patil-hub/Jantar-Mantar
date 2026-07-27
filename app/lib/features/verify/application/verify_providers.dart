import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/demo/demo_mode.dart';
import '../../../core/providers.dart';
import '../domain/trust_standing.dart';

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

/// Whether the app should show admin/verifier screens: a real admin session, a
/// trust-promoted verifier (ADR-25), or Demo Mode (which grants a simulated
/// admin view with sample data).
///
/// Display gating only. Every decision is re-checked server-side, and a
/// verifier's powers are a strict subset of an admin's — see
/// [isAdminSession] and `supabase/migrations/20260727000003_trust.sql`.
final canVerifyProvider = Provider<bool>((ref) {
  if (ref.watch(demoModeProvider)) return true;
  ref.watch(authChangesForVerifyProvider);
  if (isAdminSession(ref.watch(supabaseClientProvider))) return true;
  final standing = ref.watch(trustStandingProvider).asData?.value;
  return standing?.tier == TrustTier.verifier;
});

/// The signed-in user's verification standing (Phase 4). Demo Mode returns a
/// mid-progress "trusted" standing so the card is explorable with no backend.
final trustStandingProvider = FutureProvider<TrustStanding>((ref) async {
  if (ref.watch(demoModeProvider)) {
    return const TrustStanding(
      tier: TrustTier.trusted,
      approved: 12,
      rejected: 1,
      trustedAt: 5,
      verifierAt: 20,
    );
  }
  ref.watch(authChangesForVerifyProvider);
  final client = ref.watch(supabaseClientProvider);
  if (client == null || client.auth.currentUser == null) {
    return TrustStanding.unknown;
  }
  final result = await client.rpc<Object?>('my_trust');
  if (result is! Map) return TrustStanding.unknown;
  return TrustStanding.fromJson(result.cast<String, Object?>());
});

/// Rebuilds [canVerifyProvider] when the session changes.
final authChangesForVerifyProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const Stream.empty();
  return client.auth.onAuthStateChange;
});

/// Append-only audit trail (E5). `audit_log` is admin-read-only by RLS and is
/// written by the SECURITY DEFINER decision functions, so this is a read-only
/// window onto what admins actually did — the accountability half of
/// verify-before-display.
final auditLogProvider = FutureProvider.autoDispose
    .family<List<Map<String, Object?>>, int>((ref, refreshTick) async {
      if (ref.watch(demoModeProvider)) {
        return ref.watch(demoAuditLogProvider);
      }
      final client = ref.watch(supabaseClientProvider);
      if (client == null) throw StateError('Backend not configured.');
      final rows = await client
          .from('audit_log')
          .select('id, actor_id, action, entity, entity_id, ts')
          .order('ts', ascending: false)
          .limit(100);
      return List<Map<String, Object?>>.from(rows);
    });

/// Sample audit entries so the viewer is explorable in Demo Mode.
final demoAuditLogProvider = Provider<List<Map<String, Object?>>>((ref) {
  final now = DateTime.now();
  String at(int m) => now.subtract(Duration(minutes: m)).toIso8601String();
  return [
    {
      'id': 5,
      'actor_id': 'admin-meera',
      'action': 'approve_submission',
      'entity': 'submission',
      'entity_id': 'demo-sub-9',
      'ts': at(3),
    },
    {
      'id': 4,
      'actor_id': 'admin-meera',
      'action': 'reject_submission',
      'entity': 'submission',
      'entity_id': 'demo-sub-8',
      'ts': at(14),
    },
    {
      'id': 3,
      'actor_id': 'admin-vikram',
      'action': 'publish_alert',
      'entity': 'alert',
      'entity_id': 'seed-alert-critical',
      'ts': at(27),
    },
    {
      'id': 2,
      'actor_id': 'admin-vikram',
      'action': 'approve_submission',
      'entity': 'submission',
      'entity_id': 'demo-sub-7',
      'ts': at(52),
    },
    {
      'id': 1,
      'actor_id': 'admin-meera',
      'action': 'approve_submission',
      'entity': 'submission',
      'entity_id': 'demo-sub-6',
      'ts': at(96),
    },
  ];
});
