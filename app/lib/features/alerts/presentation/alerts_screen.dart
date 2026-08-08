import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/theme/depth.dart';
import '../../../core/theme/status_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../groups/application/groups_providers.dart';
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
    final broadcasts =
        ref.watch(groupBroadcastsProvider).asData?.value ?? const [];

    if (alerts.isEmpty && broadcasts.isEmpty) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.noActiveAlerts, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // Public verified alerts first — they are the canonical layer.
          for (final alert in alerts) _AlertCard(alert: alert),
          if (broadcasts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text(
                l10n.groupBroadcasts,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final b in broadcasts) _GroupBroadcastCard(broadcast: b),
          ],
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              l10n.cachedMayBeOutdated,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// A group broadcast in the Alerts feed. Deliberately distinguishable from a
/// verified public alert: it is member-only, unverified group content, and the
/// footer says so instead of the "Verified by admin" line.
class _GroupBroadcastCard extends StatelessWidget {
  const _GroupBroadcastCard({required this.broadcast});

  final GroupBroadcast broadcast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final severity = broadcast.message.broadcastSeverity!;
    final color = severity.colorOf(colors);

    return DepthSurface(
      margin: const EdgeInsets.only(bottom: 12),
      accentBorder: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(severity.icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${broadcast.groupName} · ${severity.label(l10n)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  relativeTimeL10n(
                    l10n,
                    broadcast.message.createdAt,
                    DateTime.now(),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              broadcast.message.decrypted!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 16),
                const SizedBox(width: 4),
                Text(
                  l10n.groupBroadcastNote,
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

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final color = alert.severity.colorOf(colors);

    return DepthSurface(
      margin: const EdgeInsets.only(bottom: 12),
      accentBorder: color,
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
