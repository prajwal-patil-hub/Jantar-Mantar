import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme/tokens.dart';

/// "You are seeing saved data" — stated in the app chrome (ADR-33).
///
/// The app has been offline-first since E2, and until now the only place that
/// said so was inside group chat. Everywhere else a stale map and a live map
/// looked identical, which is the worst version of this: freshness badges
/// tell you how old one pin is, nothing told you the whole screen was frozen.
///
/// Deliberately quiet. It is not an error — offline is the expected condition
/// this app is built for — so it is an informational strip, never red, never
/// blocking, and it never covers the critical-alert banner, which outranks it.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isOnlineProvider)) return const SizedBox.shrink();

    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
          border: Border.all(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? AppTokens.hairlineDark
                        : AppTokens.hairline)
                    .withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 17,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                l10n.offlineShowingSaved,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
