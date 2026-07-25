import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/groups_providers.dart';
import '../domain/group_models.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

/// Groups tab: your groups, with create / join actions. Server-backed, so it
/// shows a sign-in notice when the backend isn't reachable yet.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final repo = ref.watch(groupsRepositoryProvider);
    final groups = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupsTitle),
        actions: [
          if (repo != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refresh,
              onPressed: () => ref.read(groupsRefreshProvider.notifier).bump(),
            ),
        ],
      ),
      floatingActionButton: repo == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreateGroupScreen(),
                ),
              ),
              icon: const Icon(Icons.group_add),
              label: Text(l10n.createGroup),
            ),
      body: repo == null
          ? _SignInGate(l10n: l10n)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () => _joinDialog(context, ref),
                    icon: const Icon(Icons.qr_code),
                    label: Text(l10n.joinWithCode),
                  ),
                ),
                Expanded(
                  child: groups.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(l10n.groupActionFailed('$e')),
                      ),
                    ),
                    data: (list) => list.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.noGroupsYet,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, i) =>
                                _GroupTile(group: list[i]),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _joinDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.joinWithCode),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: l10n.inviteCode),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim().toUpperCase()),
            child: Text(l10n.join),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;

    final repo = ref.read(groupsRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.joinByCode(code);
      ref.read(groupsRefreshProvider.notifier).bump();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pendingApproval)));
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupActionFailed('$e'))));
    }
  }
}

class _GroupTile extends ConsumerWidget {
  const _GroupTile({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final pending = group.myState == MemberState.pending;
    return ListTile(
      leading: CircleAvatar(child: Text(group.name.characters.first)),
      title: Text(group.name),
      subtitle: Text(
        pending
            ? l10n.membershipPending
            : (group.isAdmin ? l10n.admin : l10n.member),
      ),
      trailing: pending ? const Icon(Icons.hourglass_top) : null,
      onTap: pending
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GroupDetailScreen(group: group),
              ),
            ),
    );
  }
}

/// Shown while Groups has no session yet. Actively triggers anonymous sign-in
/// (no credentials needed) and surfaces the real error if it fails — most
/// often "Anonymous sign-ins are disabled", which is a Supabase dashboard
/// toggle, not a login problem.
class _SignInGate extends ConsumerWidget {
  const _SignInGate({required this.l10n});

  final AppL10n l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ensureSignedInProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: state.when(
          loading: () => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Signing you in anonymously…', textAlign: TextAlign.center),
            ],
          ),
          data: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.groupsSignInNeeded, textAlign: TextAlign.center),
            ],
          ),
          error: (e, _) {
            final msg = e.toString();
            final isDisabled = msg.toLowerCase().contains('anonymous');
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_person_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  isDisabled
                      ? 'Anonymous sign-in is turned OFF in Supabase.\n\n'
                            'Enable it: Supabase dashboard → Authentication → '
                            'Sign In / Providers → Anonymous sign-ins → ON → '
                            'Save. Then reload this page. No account or '
                            'password is needed.'
                      : 'Could not start a session:\n$msg',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(ensureSignedInProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
