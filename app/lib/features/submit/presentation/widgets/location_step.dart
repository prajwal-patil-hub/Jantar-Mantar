import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/map/map_config.dart';
import '../../../../core/map/tile_providers.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../map/application/map_providers.dart';
import '../../../map/presentation/widgets/facility_visuals.dart';
import '../../domain/submission_draft.dart';

/// Step 2: drag the mini-map to place the pin (starts at the main map's
/// center — no GPS or permission involved; precise GPS is a later, per-action
/// opt-in). Suggests updating a nearby same-type facility instead of creating
/// a duplicate (ui-ux-spec §1.8).
class LocationStep extends ConsumerStatefulWidget {
  const LocationStep({required this.draft, required this.onChanged, super.key});

  final SubmissionDraft draft;
  final VoidCallback onChanged;

  @override
  ConsumerState<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<LocationStep> {
  static const _duplicateRadiusMeters = 60.0;

  NearbyFacility? _duplicateCandidate() {
    final draft = widget.draft;
    final location = draft.location;
    if (location == null || draft.isUpdate) return null;

    final facilities = ref.watch(facilitiesProvider).asData?.value ?? const [];
    const distance = Distance();
    NearbyFacility? nearest;
    for (final f in facilities) {
      if (f.type != draft.category) continue;
      final meters = distance.as(
        LengthUnit.Meter,
        location,
        LatLng(f.lat, f.lng),
      );
      if (meters <= _duplicateRadiusMeters &&
          (nearest == null || meters < nearest.distanceMeters)) {
        nearest = NearbyFacility(f, meters);
      }
    }
    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final draft = widget.draft;

    if (draft.isUpdate) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.updatingExisting,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(draft.category?.icon),
              title: Text(draft.existingFacilityName ?? ''),
              subtitle: Text(l10n.locationStaysMapped),
            ),
          ],
        ),
      );
    }

    final duplicate = _duplicateCandidate();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.stepLocationQuestion,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(l10n.stepLocationHint),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: draft.location ?? MapConfig.jantarMantar,
                    initialZoom: 17,
                    minZoom: MapConfig.minZoom,
                    maxZoom: MapConfig.maxZoom,
                    onPositionChanged: (camera, _) {
                      draft.location = camera.center;
                      widget.onChanged();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConfig.urlTemplate,
                      userAgentPackageName: MapConfig.userAgentPackageName,
                      tileProvider: ref.watch(mapTileProviderProvider),
                      maxZoom: MapConfig.maxZoom,
                    ),
                  ],
                ),
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      // Anchor the pin tip to the map center.
                      padding: EdgeInsets.only(bottom: 36),
                      child: Icon(Icons.location_on, size: 44),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (duplicate != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.duplicateHint(
                      duplicate.facility.type.label(l10n).toLowerCase(),
                      duplicate.distanceMeters.round(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton.tonal(
                        onPressed: () {
                          final f = duplicate.facility;
                          draft
                            ..existingFacilityId = f.id
                            ..existingFacilityName = f.name
                            ..location = LatLng(f.lat, f.lng);
                          widget.onChanged();
                        },
                        child: Text(l10n.updateNamed(duplicate.facility.name)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
