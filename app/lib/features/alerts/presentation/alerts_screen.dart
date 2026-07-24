import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/status_colors.dart';
import '../application/alerts_providers.dart';
import 'widgets/alert_visuals.dart';

/// Alerts feed (ui-ux-spec §1.10): severity-banded cards, critical pinned
/// on top (repository ordering), timestamps, verified-by-admin note. Cached
/// alerts stay visible offline with a "may be outdated" footer.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(activeAlertsProvider).asData?.value ?? const [];

    return SafeArea(
      child: alerts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No active alerts.\nCritical alerts appear here and on the '
                  'map instantly.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: alerts.length + 1,
              itemBuilder: (context, i) {
                if (i == alerts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Shown from local cache — may be outdated while '
                      'offline.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }
                return _AlertCard(alert: alerts[i]);
              },
            ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<StatusColors>()!;
    final color = alert.severity.colorOf(colors);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(alert.severity.icon, color: color),
                const SizedBox(width: 8),
                Text(
                  alert.severity.label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  relativeTime(alert.createdAt, DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(alert.body, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                if (alert.lat != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.place_outlined, size: 16),
                      label: const Text('Area alert'),
                    ),
                  ),
                const Icon(Icons.verified_user_outlined, size: 16),
                const SizedBox(width: 4),
                const Text('Verified by admin', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
