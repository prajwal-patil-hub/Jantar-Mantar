import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/freshness.dart';
import '../../../core/domain/sphere_standards.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/providers.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../l10n/app_localizations.dart';
import '../../submit/presentation/submit_flow_screen.dart';
import '../application/map_providers.dart';
import 'widgets/facility_visuals.dart';
import 'widgets/freshness_badge.dart';

/// Facility detail bottom sheet (ui-ux-spec §1.5): status pill, capacity
/// block with large numerals + TTL degrade, freshness, stale banner, and the
/// Update / Report-closed actions. Photos and offline directions come later.
Future<void> showFacilityDetailSheet(BuildContext context, Facility facility) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _FacilityDetailSheet(facility: facility),
  );
}

class _FacilityDetailSheet extends ConsumerWidget {
  const _FacilityDetailSheet({required this.facility});

  final Facility facility;

  /// The camp's stated headcount comes from its shelter capacity reading.
  /// Null when nobody has reported one — which the card renders as "not
  /// enough information", never as a pass.
  static int? _shelterPopulation(List<CapacityReading> readings) {
    for (final r in readings) {
      if (r.resource == ResourceType.shelter) return r.forPeople;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final statusColor = facility.status.colorOf(colors);
    final readings =
        ref.watch(capacityReadingsProvider(facility.id)).asData?.value ??
        const <CapacityReading>[];
    final now = DateTime.now();
    final verifiedAt = facility.verifiedAt;
    final isStale =
        verifiedAt == null || freshnessAt(verifiedAt, now) == Freshness.stale;

    return GlassSurface(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(facility.type.icon, size: 28, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      facility.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _StatusPill(status: facility.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),
              FreshnessBadge(verifiedAt: facility.verifiedAt),
              if (isStale) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.low.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.low),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: colors.low),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.mayBeOutdated)),
                    ],
                  ),
                ),
              ],
              if (readings.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (final reading in readings)
                      _CapacityTile(reading: reading, now: now),
                  ],
                ),
              ],
              // Relief-camp WASH adequacy (ADR-30). Only appears for a
              // shelter with a stated population — see washAdequacy().
              if (facility.type == FacilityType.shelter)
                _WashAdequacyCard(
                  adequacy: washAdequacy(
                    camp: facility,
                    people: _shelterPopulation(readings),
                    nearby:
                        ref.watch(facilitiesProvider).asData?.value ??
                        const <Facility>[],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SubmitFlowScreen(
                              initialLocation: LatLng(
                                facility.lat,
                                facility.lng,
                              ),
                              prefill: facility,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_location_alt),
                      label: Text(l10n.updateThis),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () => _reportClosed(context, ref),
                      icon: const Icon(Icons.block),
                      label: Text(l10n.reportClosed),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _openDirections(context, facility),
                    icon: const Icon(Icons.directions_walk),
                    label: Text(l10n.directions),
                  ),
                  TextButton.icon(
                    onPressed: () => _share(context, facility, l10n),
                    icon: const Icon(Icons.share),
                    label: Text(l10n.share),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hands the destination to whichever map app the user has chosen, via the
  /// platform `geo:` scheme — deliberately NOT a hardcoded Google Maps link
  /// (ADR-7 keeps Google out of the loop, and the destination is exactly the
  /// kind of thing this app should not route through a third party by
  /// default). Falls back to OpenStreetMap, which is also the web path.
  Future<void> _openDirections(BuildContext context, Facility facility) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final lat = facility.lat;
    final lng = facility.lng;

    final candidates = <Uri>[
      if (!kIsWeb) Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
      Uri.parse(
        'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng',
      ),
    ];

    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      } on Object {
        // Try the next one.
      }
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.directionsFailed('$lat, $lng'))),
    );
  }

  /// Shares public facility info only — name, status and coordinates. Never
  /// anything about who reported it.
  Future<void> _share(
    BuildContext context,
    Facility facility,
    AppL10n l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final text =
        '${facility.name} — ${facility.status.label(l10n)}\n'
        'https://www.openstreetmap.org/?mlat=${facility.lat}'
        '&mlon=${facility.lng}#map=18/${facility.lat}/${facility.lng}';
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } on Object {
      // No share sheet (some desktop/web contexts) — the clipboard always
      // works, and losing the address entirely would be worse.
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
    }
  }

  Future<void> _reportClosed(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reportClosedQuestion(facility.name)),
        content: Text(l10n.reportClosedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.reportClosed),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref
        .read(submissionRepositoryProvider)
        .submit(
          payload: {
            'category': facility.type.name,
            'status': FacilityStatus.closed.name,
            'mode': 'update',
          },
          facilityId: facility.id,
          lat: facility.lat,
          lng: facility.lng,
        );
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.reportedQueued)));
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color});

  final FacilityStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.label(AppL10n.of(context)),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// "💧 Water for ~200" with large numerals; expired readings degrade to grey
/// (TTL rule — ARCHITECTURE.md verification pipeline).
class _CapacityTile extends StatelessWidget {
  const _CapacityTile({required this.reading, required this.now});

  final CapacityReading reading;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<StatusColors>()!;
    final expired = reading.expiresAt.isBefore(now);
    final color = expired ? colors.unverified : null;

    final icon = switch (reading.resource) {
      ResourceType.water => Icons.water_drop,
      ResourceType.food => Icons.restaurant,
      ResourceType.shelter => Icons.night_shelter,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              AppL10n.of(context).capacityFor(reading.forPeople),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: color),
            ),
          ],
        ),
        if (expired)
          Text(
            AppL10n.of(context).expiredRecheck,
            style: TextStyle(color: colors.unverified, fontSize: 12),
          ),
      ],
    );
  }
}

/// Relief-camp WASH adequacy against the published humanitarian minimums
/// (ADR-30). This is the number the Assam 2026 reporting shows nobody had:
/// 15,000 people sharing six latrines is 2,500 per latrine against a
/// first-phase maximum of 50.
///
/// Reads as an *indicator*, never a verdict — it names the standard, shows
/// how many mapped facilities it counted, and says outright that partial map
/// coverage means it is not a survey.
class _WashAdequacyCard extends StatelessWidget {
  const _WashAdequacyCard({required this.adequacy});

  final WashAdequacy adequacy;

  @override
  Widget build(BuildContext context) {
    if (!adequacy.hasAnything) return const SizedBox.shrink();
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rule, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.washTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _WashRow(
              ratio: adequacy.latrines,
              label: l10n.washLatrines,
              standard: l10n.washLatrineStandard(latrineEmergencyMax),
              value: (n) => l10n.washPerLatrine(n),
              none: l10n.washNoLatrines,
              colors: colors,
            ),
            const SizedBox(height: 6),
            _WashRow(
              ratio: adequacy.water,
              label: l10n.washWater,
              standard: l10n.washWaterStandard(
                waterPointTapStandard,
                waterPointPumpStandard,
              ),
              value: (n) => l10n.washPerWaterPoint(n),
              none: l10n.washNoWater,
              colors: colors,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.washCoverage(
                adequacy.latrines.points + adequacy.water.points,
                adequacy.radiusMeters.round(),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WashRow extends StatelessWidget {
  const _WashRow({
    required this.ratio,
    required this.label,
    required this.standard,
    required this.value,
    required this.none,
    required this.colors,
  });

  final WashRatio ratio;
  final String label;
  final String standard;
  final String Function(int) value;
  final String none;
  final StatusColors colors;

  @override
  Widget build(BuildContext context) {
    if (ratio.band == WashBand.unknown) return const SizedBox.shrink();

    // Band is conveyed by icon + text as well as colour (accessibility rule);
    // the colours reuse the status extension rather than the seed scheme.
    final (icon, color) = switch (ratio.band) {
      WashBand.meetsStandard => (Icons.check_circle_outline, colors.good),
      WashBand.emergencyOnly => (Icons.error_outline, colors.low),
      WashBand.belowStandard => (Icons.report_gmailerrorred, colors.out),
      WashBand.unknown => (Icons.help_outline, colors.unverified),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label — '
                '${ratio.peoplePerPoint == null ? none : value(ratio.peoplePerPoint!)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: color),
              ),
              Text(standard, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
