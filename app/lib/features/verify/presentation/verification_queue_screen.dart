import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/demo/demo_mode.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/providers.dart';
import '../../../core/theme/depth.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../alerts/presentation/compose_alert_screen.dart';
import '../../map/presentation/widgets/facility_visuals.dart';
import '../application/verify_providers.dart';
import 'audit_log_screen.dart';
import 'reporter_screen.dart';

/// Admin verification queue (ui-ux-spec §1.14/§1.15, MVP cut): oldest-first
/// pending submissions with approve / reject-with-reason. Decisions call
/// SECURITY DEFINER functions server-side, which also write the audit log.
class VerificationQueueScreen extends ConsumerStatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  ConsumerState<VerificationQueueScreen> createState() =>
      _VerificationQueueScreenState();
}

class _VerificationQueueScreenState
    extends ConsumerState<VerificationQueueScreen> {
  // Bumping the tick re-runs the family future = refresh after decisions.
  int _refreshTick = 0;

  /// Batch mode is opt-in and off by default: approving publishes to the
  /// public map, so the one-tap-per-card path stays the norm and bulk
  /// approval takes a deliberate mode switch plus a counted confirmation.
  bool _selectMode = false;
  final Set<String> _selected = {};

  List<String> _rejectReasons(AppL10n l10n) => [
    l10n.reasonDuplicate,
    l10n.reasonCantVerify,
    l10n.reasonStale,
    l10n.reasonInaccurate,
    l10n.reasonSpam,
  ];

  /// Approves one submission. Returns the failure as a string (null on
  /// success) instead of swallowing it, so the batch path can count what
  /// actually went through rather than assuming.
  Future<String?> _approveOne(String id) async {
    // Demo Mode: resolve locally, no backend call.
    if (ref.read(demoModeProvider)) {
      ref.read(demoPendingQueueProvider.notifier).remove(id);
      return null;
    }
    final client = ref.read(supabaseClientProvider);
    if (client == null) return 'Backend not configured.';
    try {
      await client.rpc<void>(
        'approve_submission',
        params: {'p_submission_id': id},
      );
      return null;
    } on Object catch (e) {
      return '$e';
    }
  }

  Future<void> _approve(String id) async {
    final l10n = AppL10n.of(context);
    final demo = ref.read(demoModeProvider);
    final error = await _approveOne(id);
    if (!mounted) return;
    setState(() => _refreshTick++);
    if (error != null) {
      _showError(l10n.approveFailed(error));
    } else if (demo) {
      _showError('Approved (demo) — it would now publish to the map.');
    }
  }

  /// Bulk approve. Runs sequentially so each RPC gets its own server-side
  /// authz check and one failure can't be mistaken for the rest succeeding;
  /// the result is reported as done/failed counts, never a blanket "done".
  Future<void> _approveSelected() async {
    final l10n = AppL10n.of(context);
    final ids = _selected.toList();
    if (ids.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.approveSelected),
        content: Text(l10n.approveSelectedConfirm(ids.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.approve),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    var done = 0;
    final failures = <String>[];
    for (final id in ids) {
      final error = await _approveOne(id);
      if (error == null) {
        done++;
        _selected.remove(id);
      } else {
        failures.add(error);
      }
    }
    if (!mounted) return;
    setState(() {
      _refreshTick++;
      if (_selected.isEmpty) _selectMode = false;
    });
    _showError(
      failures.isEmpty
          ? l10n.batchApproved(done)
          : l10n.batchPartial(done, failures.length),
    );
  }

  /// Open the submitter's record. Admin-only in the UI, and admin-only on
  /// the server too — `reporter_history` runs as the caller, so a verifier
  /// calling it would simply get nothing back.
  void _openReporter(String userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReporterScreen(userId: userId)),
    );
  }

  void _toggleSelected(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selected.clear();
    });
  }

  Future<void> _reject(String id) async {
    final l10n = AppL10n.of(context);
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.rejectWhy),
        children: [
          for (final reason in _rejectReasons(l10n))
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(reason),
              child: Text(reason),
            ),
        ],
      ),
    );
    if (reason == null) return;

    if (ref.read(demoModeProvider)) {
      ref.read(demoPendingQueueProvider.notifier).remove(id);
      setState(() => _refreshTick++);
      _showError('Rejected (demo): $reason');
      return;
    }
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      await client.rpc<void>(
        'reject_submission',
        params: {'p_submission_id': id, 'p_reason': reason},
      );
      setState(() => _refreshTick++);
    } on Object catch (e) {
      _showError(l10n.rejectFailed('$e'));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final pending = ref.watch(pendingServerSubmissionsProvider(_refreshTick));
    // Demo Mode simulates the full admin view. A promoted verifier gets a
    // strict subset (ADR-25) — mirrored here so the buttons match what the
    // server will actually allow, never as a substitute for the server check.
    final isAdmin =
        ref.watch(demoModeProvider) ||
        isAdminSession(ref.watch(supabaseClientProvider));

    return Scaffold(
      appBar: AppBar(
        leading: _selectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.cancel,
                onPressed: _exitSelectMode,
              )
            : null,
        title: Text(
          _selectMode
              ? l10n.selectedCount(_selected.length)
              : l10n.verificationQueue,
        ),
        actions: _selectMode
            ? [
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: l10n.approveSelected,
                  onPressed: _selected.isEmpty ? null : _approveSelected,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.checklist),
                  tooltip: l10n.selectMode,
                  onPressed: () => setState(() => _selectMode = true),
                ),
                // Public-alert authoring stays an admin power.
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.campaign_outlined),
                    tooltip: l10n.newAlert,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ComposeAlertScreen(),
                      ),
                    ),
                  ),
                // Accountability for everything above it. Admin-only because
                // that is what the audit_log RLS policy allows — showing the
                // entry point to a verifier would only open an empty screen.
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.history),
                    tooltip: l10n.auditLog,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuditLogScreen(),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.refresh,
                  onPressed: () => setState(() => _refreshTick++),
                ),
              ],
      ),
      body: pending.when(
        loading: () => LoadingStateView(semanticLabel: l10n.verificationQueue),
        error: (e, _) => ErrorStateView(
          message: l10n.couldNotLoad,
          details: '$e',
          onRetry: () => setState(() => _refreshTick++),
          retryLabel: l10n.refresh,
        ),
        data: (rows) => rows.isEmpty
            ? EmptyStateView(
                icon: Icons.inbox_outlined,
                title: l10n.queueClear,
                body: l10n.queueClearBody,
              )
            : RefreshIndicator(
                onRefresh: () async => setState(() => _refreshTick++),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final id = rows[i]['id'] as String;
                    return _SubmissionCard(
                      row: rows[i],
                      isAdmin: isAdmin,
                      onOpenReporter: _openReporter,
                      selectMode: _selectMode,
                      selected: _selected.contains(id),
                      onToggleSelected: _toggleSelected,
                      onApprove: _approve,
                      onReject: _reject,
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.row,
    required this.isAdmin,
    required this.onOpenReporter,
    required this.selectMode,
    required this.selected,
    required this.onToggleSelected,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, Object?> row;
  final bool isAdmin;
  final void Function(String userId) onOpenReporter;
  final bool selectMode;

  /// A verifier can only approve a submission that updates a facility which
  /// already exists — `approve_submission` raises otherwise. Mirrored so the
  /// button is disabled with a reason instead of failing after the tap.
  bool get _canApprove => isAdmin || row['facility_ref'] != null;
  final bool selected;
  final void Function(String id) onToggleSelected;
  final Future<void> Function(String id) onApprove;
  final Future<void> Function(String id) onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final id = row['id'] as String;
    final submitterId = row['submitter_id'] as String?;
    final payload = (row['payload'] as Map?)?.cast<String, Object?>() ?? {};
    final categoryName = payload['category'] as String?;
    final category = FacilityType.values.asNameMap()[categoryName];
    final isUpdate = payload['mode'] == 'update';
    final typeLabel = category?.label(l10n) ?? categoryName ?? '?';
    final createdAt = DateTime.tryParse(
      row['created_at'] as String? ?? '',
    )?.toLocal();

    return DepthSurface(
      margin: const EdgeInsets.only(bottom: 12),
      // In select mode the whole card is the target — a bare checkbox is
      // under 48dp and this list gets used one-handed under pressure.
      child: InkWell(
        onTap: selectMode && _canApprove ? () => onToggleSelected(id) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selectMode)
                    Checkbox(
                      value: selected,
                      onChanged: _canApprove
                          ? (_) => onToggleSelected(id)
                          : null,
                    ),
                  Icon(category?.icon ?? Icons.help_outline),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isUpdate
                          ? l10n.queueCardUpdate(typeLabel)
                          : l10n.queueCardNew(typeLabel),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Spacer(),
                  if (createdAt != null)
                    Text(
                      TimeOfDay.fromDateTime(createdAt).format(context),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  // "Who filed this?" is the question that decides a
                  // borderline report, so it is one tap from the card.
                  if (isAdmin && !selectMode && submitterId != null)
                    IconButton(
                      icon: const Icon(Icons.person_search_outlined),
                      tooltip: l10n.reporterHistory,
                      onPressed: () => onOpenReporter(submitterId),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  if (payload['status'] != null)
                    Text(l10n.reviewStatus(_statusLabel(l10n, payload))),
                  if (payload['forPeople'] is int)
                    Text(
                      l10n.reviewCapacityPeople(payload['forPeople'] as int),
                    ),
                  if (row['lat'] != null)
                    Text(
                      '(${(row['lat'] as num).toStringAsFixed(4)}, '
                      '${(row['lng'] as num).toStringAsFixed(4)})',
                    ),
                ],
              ),
              if ((payload['note'] as String?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Text('“${payload['note']}”'),
              ],
              // Per-card decisions are hidden in select mode: mixing a
              // single-tap approve into a multi-select list is how the wrong
              // thing gets published.
              if (!selectMode) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: Theme.of(
                            context,
                          ).extension<StatusColors>()!.good,
                        ),
                        onPressed: _canApprove ? () => onApprove(id) : null,
                        icon: const Icon(Icons.check),
                        label: Text(l10n.approve),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          foregroundColor: Theme.of(
                            context,
                          ).extension<StatusColors>()!.out,
                        ),
                        onPressed: isAdmin ? () => onReject(id) : null,
                        icon: const Icon(Icons.close),
                        label: Text(l10n.reject),
                      ),
                    ),
                  ],
                ),
                // Say WHY a button is dead, rather than leaving a verifier
                // tapping something greyed out with no explanation.
                if (!isAdmin) ...[
                  const SizedBox(height: 6),
                  Text(
                    _canApprove
                        ? l10n.verifierCannotReject
                        : '${l10n.verifierNeedsAdmin} ${l10n.verifierCannotReject}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppL10n l10n, Map<String, Object?> payload) {
    final status = FacilityStatus.values.asNameMap()[payload['status']];
    return status?.label(l10n) ?? '${payload['status']}';
  }
}
