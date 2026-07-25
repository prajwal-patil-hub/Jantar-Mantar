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
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.groupsSignInNeeded,
                  textAlign: TextAlign.center,
                ),
              ),
            )
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
