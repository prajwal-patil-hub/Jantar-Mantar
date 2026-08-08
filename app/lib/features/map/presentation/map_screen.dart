import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart';
import '../../../core/map/map_config.dart';
import '../../../core/map/tile_providers.dart';
import '../../../core/theme/depth.dart';
import '../../../core/theme/extruded_knob.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../groups/application/groups_providers.dart';
import '../../routes/presentation/report_route_screen.dart';
import '../../sos/presentation/sos_screen.dart';
import '../../submit/presentation/submit_flow_screen.dart';
import '../application/map_providers.dart';
import 'facility_detail_sheet.dart';
import 'widgets/critical_alert_banner.dart';
import 'widgets/facility_marker.dart';
import 'widgets/filter_chip_row.dart';
import 'widgets/nearby_sheet.dart';
import 'widgets/pending_marker.dart';
import 'widgets/route_layer.dart';

/// Home map (ui-ux-spec §1.4): offline-cached OSM tiles, clustered status
/// pins, filter chips, Nearby sheet. Local-first throughout — everything on
/// screen comes from Drift streams and the FMTC tile cache.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  ProtestSite _site = MapConfig.sites.first;

  /// Lets the map reach demo data in other cities. Single-site remains the
  /// product's default; this only moves the camera.
  Future<void> _pickSite() async {
    final l10n = AppL10n.of(context);
    final picked = await showModalBottomSheet<ProtestSite>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                l10n.jumpToSite,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final site in MapConfig.sites)
              ListTile(
                leading: Icon(
                  site.id == _site.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(site.name),
                onTap: () => Navigator.of(context).pop(site),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _site = picked);
    _mapController.move(picked.center, MapConfig.initialZoom);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final facilities =
        ref.watch(facilitiesProvider).asData?.value ?? const <Facility>[];
    final pending =
        ref.watch(pendingSubmissionsProvider).asData?.value ??
        const <Submission>[];
    final showGroupPins = ref.watch(showGroupPinsProvider);
    final groupPins =
        ref.watch(groupPinsForMapProvider).asData?.value ??
        const <GroupPinOnMap>[];

    final markers = [
      for (final facility in facilities)
        Marker(
          point: LatLng(facility.lat, facility.lng),
          width: 48,
          height: 48,
          child: FacilityMarker(
            facility: facility,
            onTap: () => showFacilityDetailSheet(context, facility),
          ),
        ),
      // Optimistic "Pending (yours)" pins for new-facility submissions
      // (updates to existing facilities don't need a second pin).
      for (final submission in pending)
        if (submission.state == SubmissionState.pending &&
            submission.facilityId == null &&
            submission.lat != null &&
            submission.lng != null)
          Marker(
            point: LatLng(submission.lat!, submission.lng!),
            width: 48,
            height: 48,
            child: PendingMarker(submission: submission),
          ),
      // Group amenities layer (opt-in via the layers button).
      for (final gp in groupPins)
        Marker(
          point: LatLng(gp.pin.lat, gp.pin.lng),
          width: 48,
          height: 48,
          child: _GroupPinMarker(
            entry: gp,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.groupPinFrom(gp.groupName, gp.pin.label)),
              ),
            ),
          ),
        ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: MapConfig.jantarMantar,
            initialZoom: MapConfig.initialZoom,
            minZoom: MapConfig.minZoom,
            maxZoom: MapConfig.maxZoom,
            onMapEvent: (event) =>
                ref.read(mapCenterProvider.notifier).set(event.camera.center),
          ),
          children: [
            TileLayer(
              urlTemplate: MapConfig.urlTemplate,
              userAgentPackageName: MapConfig.userAgentPackageName,
              tileProvider: ref.watch(mapTileProviderProvider),
              maxZoom: MapConfig.maxZoom,
            ),
            // Under the pins: a hazard line is context for the markers, not
            // a competitor for the tap target.
            RouteLayer(
              routes:
                  ref.watch(activeRoutesProvider).asData?.value ??
                  const <RouteReport>[],
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: markers,
                maxClusterRadius: 60,
                size: Size(KnobSize.small.px, KnobSize.small.px),
                // The cluster is the one map object that is a control rather
                // than a status, so it takes the extrusion. Status pins never
                // do — they have to interrupt the palette, not join it.
                builder: (context, clustered) => ExtrudedKnob(
                  size: KnobSize.small,
                  selected: true,
                  semanticLabel: l10n.clusterOf(clustered.length),
                  child: Text('${clustered.length}'),
                ),
              ),
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CriticalAlertBanner(),
              const SizedBox(height: 4),
              const FilterChipRow(),
              // Shown only while hazard lines are on the map — which is
              // exactly when someone might read an unmarked road as checked.
              if ((ref.watch(activeRoutesProvider).asData?.value ?? const [])
                  .isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  // Opaque, not translucent. This one says the map does NOT
                  // certify a road is safe, and a caveat you can read map
                  // tiles through is a caveat people skip.
                  child: DepthSurface(
                    elevation: Elevation.floating,
                    radius: AppTokens.radiusChip,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      l10n.routeNoSafeClaim,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // The reference's knob rail. These replaced FABs: a Material
              // FAB is a flat disc with a drop shadow, which on this ramp
              // (adjacent surfaces ~1.06:1) reads as a sticker on the map.
              _MapKnob(
                tooltip: l10n.showGroupPins,
                icon: showGroupPins ? Icons.layers : Icons.layers_outlined,
                selected: showGroupPins,
                onTap: () => ref.read(showGroupPinsProvider.notifier).toggle(),
              ),
              const SizedBox(height: 12),
              _MapKnob(
                tooltip: l10n.recenter,
                icon: Icons.my_location,
                // Recentres on whichever site is currently selected.
                onTap: () =>
                    _mapController.move(_site.center, MapConfig.initialZoom),
              ),
              const SizedBox(height: 12),
              _MapKnob(
                tooltip: l10n.jumpToSite,
                icon: Icons.travel_explore,
                onTap: _pickSite,
              ),
              const SizedBox(height: 12),
              // Reporting a blocked route (ADR-31) is its own action, not a
              // facility category: it places a line, not a pin.
              _MapKnob(
                tooltip: l10n.reportRoute,
                icon: Icons.edit_road,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReportRouteScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ExtrudedPill(
                label: l10n.report,
                icon: Icons.add_location_alt,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SubmitFlowScreen(
                      initialLocation: ref.read(mapCenterProvider),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: 200,
          child: _SosButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const SosScreen())),
          ),
        ),
        NearbySheet(
          onFacilityTap: (item) {
            _mapController.move(
              LatLng(item.facility.lat, item.facility.lng),
              MapConfig.initialZoom,
            );
            showFacilityDetailSheet(context, item.facility);
          },
        ),
      ],
    );
  }
}

/// A knob on the map's control rail: the extrusion plus the tooltip and the
/// screen-reader label that [ExtrudedKnob] leaves to its caller.
class _MapKnob extends StatelessWidget {
  const _MapKnob({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ExtrudedKnob(
        size: KnobSize.small,
        selected: selected,
        semanticLabel: tooltip,
        onTap: onTap,
        child: Icon(icon),
      ),
    );
  }
}

/// Dedicated SOS element — 60dp, deliberately NOT the FAB (ui-ux-spec:
/// long-press-to-fire lands with the real SOS screen in E7).
class _SosButton extends StatelessWidget {
  const _SosButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SOS emergency',
      button: true,
      child: Material(
        color: Theme.of(context).extension<StatusColors>()!.out,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Group amenity pin — deliberately distinct from public facility pins
/// (square badge, group colour) so a private group pin is never mistaken for
/// a verified public facility.
class _GroupPinMarker extends StatelessWidget {
  const _GroupPinMarker({required this.entry, required this.onTap});

  final GroupPinOnMap entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (entry.pin.type) {
      'medical' => Icons.medical_services,
      'water' => Icons.water_drop,
      'food' => Icons.restaurant,
      'supply' => Icons.inventory_2,
      'meeting' => Icons.groups,
      _ => Icons.place,
    };
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: '${entry.groupName}, ${entry.pin.label}',
        button: true,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.primary, width: 3),
            // The ramp's warm cast, not a generic black26 — a neutral shadow
            // on a warm ground is the tell that something was pasted in.
            boxShadow: AppTokens.depth(
              2,
              dark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
          child: Icon(icon, size: 22, color: scheme.primary),
        ),
      ),
    );
  }
}
