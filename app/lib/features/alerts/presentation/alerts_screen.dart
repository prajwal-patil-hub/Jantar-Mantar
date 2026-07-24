import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/theme/status_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/alerts_providers.dart';
import 'widgets/alert_visuals.dart';

/// Alerts feed (ui-ux-spec §1.10): severity-banded cards, critical pinned
/// on top (repository ordering), timestamps, verified-by-admin note. Cached
/// alerts stay visible offline with a "may be outdated" footer.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final alerts = ref.watch(activeAlertsProvider).asData?.value ?? const [];

    return SafeArea(
      child: alerts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noActiveAlerts, textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: alerts.length + 1,
              itemBuilder: (context, i) {
                if (i == alerts.length) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.cachedMayBeOutdated,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
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
    final l10n = AppL10n.of(context);
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
                  alert.severity.label(l10n),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  relativeTimeL10n(l10n, alert.createdAt, DateTime.now()),
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
                      label: Text(l10n.areaAlert),
                    ),
                  ),
                const Icon(Icons.verified_user_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  l10n.verifiedByAdmin,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
