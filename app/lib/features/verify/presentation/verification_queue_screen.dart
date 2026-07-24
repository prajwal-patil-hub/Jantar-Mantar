import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../map/presentation/widgets/facility_visuals.dart';
import '../application/verify_providers.dart';

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

  static const _rejectReasons = [
    'Duplicate',
    "Can't verify",
    'Stale',
    'Inaccurate',
    'Spam',
  ];

  Future<void> _approve(String id) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      await client.rpc<void>(
        'approve_submission',
        params: {'p_submission_id': id},
      );
      setState(() => _refreshTick++);
    } on Object catch (e) {
      _showError('Approve failed: $e');
    }
  }

  Future<void> _reject(String id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Reject — why?'),
        children: [
          for (final reason in _rejectReasons)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(reason),
              child: Text(reason),
            ),
        ],
      ),
    );
    if (reason == null) return;

    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      await client.rpc<void>(
        'reject_submission',
        params: {'p_submission_id': id, 'p_reason': reason},
      );
      setState(() => _refreshTick++);
    } on Object catch (e) {
      _showError('Reject failed: $e');
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
    final pending = ref.watch(pendingServerSubmissionsProvider(_refreshTick));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() => _refreshTick++),
          ),
        ],
      ),
      body: pending.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load the queue: $e'),
          ),
        ),
        data: (rows) => rows.isEmpty
            ? const Center(child: Text('Queue is clear — nothing pending.'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: rows.length,
                itemBuilder: (context, i) => _SubmissionCard(
                  row: rows[i],
                  onApprove: _approve,
                  onReject: _reject,
                ),
              ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.row,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, Object?> row;
  final Future<void> Function(String id) onApprove;
  final Future<void> Function(String id) onReject;

  @override
  Widget build(BuildContext context) {
    final id = row['id'] as String;
    final payload = (row['payload'] as Map?)?.cast<String, Object?>() ?? {};
    final categoryName = payload['category'] as String?;
    final category = FacilityType.values.asNameMap()[categoryName];
    final isUpdate = payload['mode'] == 'update';
    final createdAt = DateTime.tryParse(
      row['created_at'] as String? ?? '',
    )?.toLocal();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category?.icon ?? Icons.help_outline),
                const SizedBox(width: 8),
                Text(
                  '${category?.label ?? categoryName ?? 'Unknown'} — '
                  '${isUpdate ? 'update' : 'new facility'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (createdAt != null)
                  Text(
                    TimeOfDay.fromDateTime(createdAt).format(context),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                if (payload['status'] != null)
                  Text('Status: ${payload['status']}'),
                if (payload['forPeople'] != null)
                  Text('Capacity: ~${payload['forPeople']}'),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    onPressed: () => onApprove(id),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      foregroundColor: const Color(0xFFC62828),
                    ),
                    onPressed: () => onReject(id),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
