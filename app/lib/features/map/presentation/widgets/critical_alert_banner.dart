import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../alerts/application/alerts_providers.dart';
import '../../../alerts/application/critical_alert_signal.dart';

/// Full-width critical-alert banner on the map (ui-ux-spec §1.10). Appears
/// instantly with NO animation — safety-critical info never waits for
/// decoration (DESIGN.md motion rules). Solid color, never glass.
class CriticalAlertBanner extends ConsumerWidget {
  const CriticalAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(criticalAlertProvider);
    // Buzz/chime once per new critical alert. Watched here because this is
    // the one widget that is mounted exactly when a critical alert is live.
    ref.watch(criticalAlertSignalProvider);
    if (alert == null) return const SizedBox.shrink();

    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    return Container(
      width: double.infinity,
      color: colors.out,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.crisis_alert, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alert.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            relativeTimeL10n(l10n, alert.createdAt, DateTime.now()),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
