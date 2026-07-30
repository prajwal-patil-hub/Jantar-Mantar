import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../demo/demo_mode.dart';
import '../theme/status_colors.dart';
import '../theme/tokens.dart';

/// "This is sample data" — stated in the app chrome, on every screen (ADR-38).
///
/// Demo Mode defaults ON (ADR-18) so the app is explorable with no backend.
/// That is right for a demo and wrong for a published build: the hosted web
/// version shows fabricated relief camps, capacity counts, alerts and an admin
/// verification queue, and the only thing that said so was a toggle two taps
/// away in Profile.
///
/// For a map people may use to decide where to walk for water, an unlabelled
/// simulation is a safety problem, not a UX one. A screenshot of it is
/// indistinguishable from real reporting, which is exactly the fabricated-data
/// vector the disaster research told us not to create.
///
/// So it is deliberately louder than [OfflineBanner]. Offline is the expected
/// condition this app is built for and gets a quiet informational strip;
/// fabricated data is not expected and gets the warning tone plus an icon and
/// text, never colour alone. It cannot be dismissed — a dismissed warning on a
/// screenshot is no warning at all.
class DemoBanner extends ConsumerWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(demoModeProvider)) return const SizedBox.shrink();

    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.low.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
          border: Border.all(color: colors.low),
        ),
        child: Row(
          children: [
            Icon(Icons.science_outlined, size: 17, color: colors.out),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                l10n.demoBannerSampleData,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
