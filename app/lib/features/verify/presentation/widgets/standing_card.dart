import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/charts.dart';
import '../../../../core/theme/depth.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/verify_providers.dart';
import '../../domain/trust_standing.dart';

/// "Your standing" (Phase 4, ADR-25): where this account sits in the trust
/// ladder and what it takes to move up.
///
/// Shown to everyone, not just verifiers, because the point of the ladder is
/// that the path is visible — verification stops being a closed admin club.
/// Each tier is icon + label + explanatory text, never a colour or a bare
/// number, and the verifier row states plainly what it does NOT grant.
class StandingCard extends ConsumerWidget {
  const StandingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    // A standing that has not loaded (or has no backend) reads as "new"
    // rather than as an error: it is informational, never blocking.
    final standing =
        ref.watch(trustStandingProvider).asData?.value ?? TrustStanding.unknown;

    final (icon, label, body) = switch (standing.tier) {
      TrustTier.newcomer => (
        Icons.person_outline,
        l10n.tierNew,
        l10n.tierNewBody,
      ),
      TrustTier.trusted => (
        Icons.verified_user_outlined,
        l10n.tierTrusted,
        l10n.tierTrustedBody,
      ),
      TrustTier.verifier => (
        Icons.shield_outlined,
        l10n.tierVerifier,
        l10n.tierVerifierBody,
      ),
    };
    final remaining = standing.remaining;

    // The one place in this app where a gauge is honest: the denominator is
    // real and server-supplied (`trust_thresholds()`), not a number invented
    // to make a ring look full. Capacity readings deliberately get no gauge —
    // "water for ~200" has no denominator — and neither does the WASH card,
    // where 2,500 people per latrine and 51 would both clamp to a full ring
    // and erase the only difference that matters.
    //
    // Not a leaderboard: this is your own standing on your own profile, and
    // there is no comparison to anyone else anywhere in the app (the disaster
    // research forbids it — trust tiers are a linkable pseudonym).
    final target = switch (standing.tier) {
      TrustTier.newcomer => standing.trustedAt,
      TrustTier.trusted => standing.verifierAt,
      TrustTier.verifier => null,
    };

    return DepthSurface(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourStanding,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DonutGauge(
                  fraction: standing.progress,
                  size: 88,
                  // The ring is the shape; this is the value. Approved out of
                  // the threshold, so the number is readable without
                  // estimating an arc.
                  label: target == null
                      ? '${standing.approved}'
                      : '${standing.approved}/$target',
                  caption: l10n.standingApprovedCaption,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    standing.approved == 0 && standing.rejected == 0
                        ? (remaining == null
                              ? l10n.standingTop
                              : l10n.standingRemaining(remaining))
                        : '${l10n.standingCounts(standing.approved, standing.rejected)}'
                              '\n'
                              '${remaining == null ? l10n.standingTop : l10n.standingRemaining(remaining)}',
                    style: Theme.of(context).textTheme.bodySmall,
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
