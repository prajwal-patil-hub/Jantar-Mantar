import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/crypto/device_identity_service.dart';
import '../../../core/crypto/e2e_crypto.dart';
import '../../../core/crypto/key_store.dart';
import '../../../core/demo/demo_mode.dart';
import '../../../core/providers.dart';
import '../data/demo_groups_repository.dart';
import '../data/groups_repo.dart';
import '../data/groups_repository.dart';
import '../domain/group_models.dart';

/// Emits on every Supabase auth change (incl. the background anonymous
/// sign-in), so the groups repository becomes available the moment a session
/// exists — no app restart needed.
final authChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const Stream.empty();
  return client.auth.onAuthStateChange;
});

/// Actively ensures an (anonymous) session for Groups and surfaces the real
/// error if sign-in fails — e.g. "Anonymous sign-ins are disabled", which
/// points straight at the Supabase dashboard toggle. No credentials needed.
final ensureSignedInProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Backend not configured in this build.');
  }
  if (client.auth.currentUser != null) return true;
  await client.auth.signInAnonymously();
  return true;
});

final e2eCryptoProvider = Provider<E2ECrypto>((ref) => E2ECrypto());

final keyStoreProvider = Provider<KeyStore>((ref) => const SecureKeyStore());

final deviceIdentityServiceProvider = Provider<DeviceIdentityService>(
  (ref) => DeviceIdentityService(
    ref.watch(e2eCryptoProvider),
    ref.watch(keyStoreProvider),
  ),
);

/// Null when Supabase isn't configured or the user isn't signed in yet —
/// groups are inherently server-backed, so the UI shows a sign-in/offline
/// notice in that case.
/// Demo repository instance (kept alive so in-session edits persist).
final demoGroupsRepositoryProvider = Provider<DemoGroupsRepository>(
  (ref) => DemoGroupsRepository(),
);

final groupsRepositoryProvider = Provider<GroupsRepo?>((ref) {
  // Demo Mode short-circuits the backend entirely: no auth, no network.
  if (ref.watch(demoModeProvider)) {
    return ref.watch(demoGroupsRepositoryProvider);
  }
  // Rebuild when auth state changes (e.g. anonymous sign-in completes).
  ref.watch(authChangesProvider);
  final client = ref.watch(supabaseClientProvider);
  if (client == null || client.auth.currentUser == null) return null;
  return GroupsRepository(
    client: client,
    crypto: ref.watch(e2eCryptoProvider),
    identity: ref.watch(deviceIdentityServiceProvider),
    keyStore: ref.watch(keyStoreProvider),
  );
});

/// Bumped after a mutation (create/join/approve) to refresh the list.
final groupsRefreshProvider = NotifierProvider<GroupsRefresh, int>(
  GroupsRefresh.new,
);

class GroupsRefresh extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final myGroupsProvider = FutureProvider.autoDispose<List<Group>>((ref) async {
  ref.watch(groupsRefreshProvider);
  final repo = ref.watch(groupsRepositoryProvider);
  if (repo == null) return const [];
  return repo.myGroups();
});
