import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_mode.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/verify_providers.dart';

/// Moderator view of one reporter (Phase 4, ADR-27).
///
/// Automatic promotion needs a manual brake: the counters only demote an
/// account that gets things *wrong*, and say nothing about one that is
/// accurate and hostile. Revoking holds the account at "New" — without the
/// hold, the next approved report would simply hand the badge back.
class ReporterScreen extends ConsumerStatefulWidget {
  const ReporterScreen({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<ReporterScreen> createState() => _ReporterScreenState();
}

class _ReporterScreenState extends ConsumerState<ReporterScreen> {
  int _tick = 0;
  bool _busy = false;

  Future<void> _call(String rpc, Map<String, Object?> params) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      if (!ref.read(demoModeProvider)) {
        final client = ref.read(supabaseClientProvider);
        if (client == null) throw StateError('Backend not configured.');
        await client.rpc<void>(rpc, params: params);
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _tick++;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            rpc == 'revoke_verifier' ? l10n.revokeDone : l10n.restoreDone,
          ),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.moderationFailed('$e'))),
      );
    }
  }

  Future<void> _revoke() async {
    final l10n = AppL10n.of(context);
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.revokeVerifier),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.revokeConfirmBody),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: l10n.revokeReasonPrompt,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            // A reason is mandatory server-side too; requiring it here just
            // avoids a round trip that fails.
            onPressed: () => Navigator.of(context).pop(
              controller.text.trim().isEmpty ? null : controller.text.trim(),
            ),
            child: Text(l10n.revokeVerifier),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    await _call('revoke_verifier', {
      'p_user': widget.userId,
      'p_reason': reason,
    });
  }

  Future<void> _restore() async {
    final l10n = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreTrust),
        content: Text(l10n.restoreConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.restoreTrust),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _call('restore_trust', {'p_user': widget.userId});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final record = ref.watch(
      reporterHistoryProvider((userId: widget.userId, tick: _tick)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reporterHistory)),
      body: record.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.queueLoadFailed('$e')),
          ),
        ),
        data: (data) {
          final held = data['held'] == true;
          final tier = data['tier'] as String? ?? 'new';
          final recent = (data['recent'] as List?) ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    held ? Icons.pause_circle_outline : Icons.shield_outlined,
                  ),
                  title: Text(_tierLabel(l10n, tier)),
                  subtitle: Text(
                    '${l10n.standingCounts((data['approved'] as num?)?.toInt() ?? 0, (data['rejected'] as num?)?.toInt() ?? 0)}'
                    '\n${widget.userId}',
                  ),
                  isThreeLine: true,
                ),
              ),
              if (held) ...[
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    leading: const Icon(Icons.gpp_bad_outlined),
                    title: Text(l10n.reporterOnHold),
                    subtitle: Text(data['hold_reason'] as String? ?? ''),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: _busy ? null : (held ? _restore : _revoke),
                icon: Icon(held ? Icons.lock_open : Icons.gpp_maybe_outlined),
                label: Text(held ? l10n.restoreTrust : l10n.revokeVerifier),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.reporterRecent,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                Text(l10n.reporterNone)
              else
                for (final row in recent.cast<Map<String, Object?>>())
                  _HistoryTile(row: row),
            ],
          );
        },
      ),
    );
  }

  String _tierLabel(AppL10n l10n, String tier) => switch (tier) {
    'verifier' => l10n.tierVerifier,
    'trusted' => l10n.tierTrusted,
    _ => l10n.tierNew,
  };
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.row});

  final Map<String, Object?> row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = row['state'] as String? ?? '';
    // Outcome is icon + text, never colour alone.
    final (icon, label) = switch (state) {
      'approved' => (Icons.check_circle_outline, l10n.auditApproved),
      'rejected' => (Icons.cancel_outlined, l10n.auditRejected),
      _ => (Icons.hourglass_empty, l10n.pendingUploads),
    };
    final at = DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal();

    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text('${row['category'] ?? ''} · ${row['status'] ?? ''}'),
      subtitle: Text(
        [label, if (row['reason'] != null) '${row['reason']}'].join(' · '),
      ),
      trailing: Text(
        at == null ? '' : relativeTimeL10n(l10n, at, DateTime.now()),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
