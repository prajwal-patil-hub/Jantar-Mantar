import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/map/map_config.dart';
import '../../../../core/theme/depth.dart';
import '../../../../core/theme/extruded_knob.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/map_providers.dart';

/// Says so when the camera is outside every site's mapped box.
///
/// Whatever ends up serving the tiles, coverage is finite: a self-hosted
/// pyramid covers the boxes it was cut for and nothing else, and a hosted
/// service can fail or be rate-limited. In all of those cases flutter_map
/// renders the same thing — flat empty ground.
///
/// That is the problem this widget exists for. On a map whose entire purpose
/// is "where is there water, a toilet, a medic", empty ground is not a
/// missing basemap to a person reading it, it is **an area with nothing in
/// it**. The app already refuses to let absence look like data everywhere
/// else: no headcount renders no WASH card rather than "adequate", and an
/// unmapped road is captioned as unchecked rather than safe. The basemap was
/// the one place left where blank still read as information.
class CoverageNotice extends ConsumerWidget {
  const CoverageNotice({required this.onReturn, super.key});

  /// Moves the camera back to a site that has map detail.
  final void Function(ProtestSite) onReturn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centre = ref.watch(mapCenterProvider);
    if (MapConfig.isMapped(centre)) return const SizedBox.shrink();

    final l10n = AppL10n.of(context);
    final nearest = _nearest(centre);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      // Opaque, like the route caveat: a notice you can read the (absent)
      // map through is a notice people skip.
      child: DepthSurface(
        elevation: Elevation.floating,
        radius: AppTokens.radiusChip,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.layers_clear_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.outsideCoverage,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.outsideCoverageBody,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ExtrudedPill(
                label: l10n.backToSite(nearest.name),
                icon: Icons.my_location,
                tone: PillTone.quiet,
                onTap: () => onReturn(nearest),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Great-circle nearest, not nearest-by-degrees: at these latitudes a
  /// degree of longitude is between 0.62 and 0.97 of a degree of latitude, so
  /// comparing raw coordinate deltas picks the wrong site often enough to
  /// matter for London.
  ProtestSite _nearest(LatLng from) {
    const distance = Distance();
    var best = MapConfig.sites.first;
    var bestMeters = double.infinity;
    for (final site in MapConfig.sites) {
      final m = distance.as(LengthUnit.Meter, from, site.center);
      if (m < bestMeters) {
        bestMeters = m;
        best = site;
      }
    }
    return best;
  }
}
