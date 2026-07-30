import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_labels.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../application/verify_providers.dart';

/// Read-only view of the append-only audit trail (E5).
///
/// Verify-before-display concentrates real power in a handful of admins, so
/// the log is the accountability half of it: every approve, reject and alert
/// is attributable. Deliberately read-only — `audit_log` has no update or
/// delete policy at all, and adding edit affordances here would imply
/// otherwise.
class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  int _refreshTick = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final entries = ref.watch(auditLogProvider(_refreshTick));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.auditLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: () => setState(() => _refreshTick++),
          ),
        ],
      ),
      body: entries.when(
        loading: () => LoadingStateView(semanticLabel: l10n.auditLog),
        error: (e, _) => ErrorStateView(
          message: l10n.couldNotLoad,
          // The raw exception is folded away, not thrown at the user: it
          // tells a volunteer nothing and leaks backend shape to anyone
          // reading over their shoulder.
          details: '$e',
          onRetry: () => setState(() => _refreshTick++),
          retryLabel: l10n.refresh,
        ),
        data: (rows) => rows.isEmpty
            ? EmptyStateView(
                icon: Icons.history_toggle_off,
                title: l10n.auditLogEmpty,
                body: l10n.auditLogAppendOnly,
              )
            // Pull-to-refresh: the gesture people already try. The AppBar
            // button stays for anyone using a screen reader or a keyboard,
            // for whom a pull gesture is not reachable.
            : RefreshIndicator(
                onRefresh: () async => setState(() => _refreshTick++),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: rows.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i == rows.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.auditLogAppendOnly,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    return _AuditTile(row: rows[i]);
                  },
                ),
              ),
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.row});

  final Map<String, Object?> row;

  /// Approvals and rejections read very differently at a glance, so they get
  /// distinct icons — never colour alone.
  (IconData, String) _action(AppL10n l10n) {
    return switch (row['action'] as String? ?? '') {
      'approve_submission' => (Icons.check_circle_outline, l10n.auditApproved),
      'reject_submission' => (Icons.cancel_outlined, l10n.auditRejected),
      'publish_alert' => (Icons.campaign_outlined, l10n.auditAlert),
      // No human decided these — the actor column is null (ADR-25/26).
      'corroborate_submission' => (
        Icons.groups_outlined,
        l10n.auditCorroborated,
      ),
      'promote_user' => (Icons.arrow_upward, l10n.auditPromoted),
      'demote_user' => (Icons.arrow_downward, l10n.auditDemoted),
      final other => (Icons.history, other),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final (icon, label) = _action(l10n);
    final ts = DateTime.tryParse(row['ts'] as String? ?? '')?.toLocal();
    // A null actor is meaningful, not missing data: the system decided.
    final actor = row['actor_id'] as String?;

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        '${row['entity'] ?? ''} ${row['entity_id'] ?? ''}\n'
        '${actor == null ? l10n.auditAutomatic : l10n.auditBy(actor)}',
      ),
      isThreeLine: true,
      trailing: Text(
        ts == null ? '' : relativeTimeL10n(l10n, ts, DateTime.now()),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
