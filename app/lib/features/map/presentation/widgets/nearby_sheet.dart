import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/map_providers.dart';
import 'facility_visuals.dart';
import 'freshness_badge.dart';

/// Non-modal "Nearby" sheet (ui-ux-spec §1.4): nearest facilities to the map
/// center as cards. Glass hero surface with the standard fallback.
class NearbySheet extends ConsumerWidget {
  const NearbySheet({required this.onFacilityTap, super.key});

  final void Function(NearbyFacility) onFacilityTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final nearby = ref.watch(nearbyFacilitiesProvider);
    final colors = Theme.of(context).extension<StatusColors>()!;

    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.1,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return GlassSurface(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(l10n.nearby, style: Theme.of(context).textTheme.titleSmall),
              Expanded(
                child: nearby.isEmpty
                    ? ListView(
                        controller: scrollController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.beFirstToReport,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: nearby.length,
                        itemBuilder: (context, i) {
                          final item = nearby[i];
                          final f = item.facility;
                          final statusColor = f.status.colorOf(colors);
                          return ListTile(
                            minTileHeight: 56,
                            onTap: () => onFacilityTap(item),
                            leading: Icon(
                              f.type.icon,
                              color: statusColor,
                              size: 28,
                            ),
                            title: Text(f.name),
                            subtitle: FreshnessBadge(verifiedAt: f.verifiedAt),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      f.status.icon,
                                      size: 16,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      f.status.label(l10n),
                                      style: TextStyle(color: statusColor),
                                    ),
                                  ],
                                ),
                                Text(_distanceText(item.distanceMeters)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _distanceText(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}
