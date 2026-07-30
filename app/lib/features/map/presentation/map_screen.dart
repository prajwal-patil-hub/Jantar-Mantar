import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart';
import '../../../core/map/map_config.dart';
import '../../../core/map/tile_providers.dart';
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
                size: const Size(44, 44),
                builder: (context, clustered) => DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Center(
                    child: Text(
                      '${clustered.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        l10n.routeNoSafeClaim,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
              FloatingActionButton.small(
                heroTag: 'grouplayer',
                tooltip: l10n.showGroupPins,
                backgroundColor: showGroupPins
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                onPressed: () =>
                    ref.read(showGroupPinsProvider.notifier).toggle(),
                child: Icon(
                  showGroupPins ? Icons.layers : Icons.layers_outlined,
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.small(
                heroTag: 'recenter',
                tooltip: l10n.recenter,
                // Recentres on whichever site is currently selected.
                onPressed: () =>
                    _mapController.move(_site.center, MapConfig.initialZoom),
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.small(
                heroTag: 'sites',
                tooltip: l10n.jumpToSite,
                onPressed: _pickSite,
                child: const Icon(Icons.travel_explore),
              ),
              const SizedBox(height: 12),
              // Reporting a blocked route (ADR-31) is its own action, not a
              // facility category: it places a line, not a pin.
              FloatingActionButton.small(
                heroTag: 'route',
                tooltip: l10n.reportRoute,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReportRouteScreen(),
                  ),
                ),
                child: const Icon(Icons.edit_road),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'report',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SubmitFlowScreen(
                      initialLocation: ref.read(mapCenterProvider),
                    ),
                  ),
                ),
                icon: const Icon(Icons.add_location_alt),
                label: Text(l10n.report),
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
        color: const Color(0xFFC62828),
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
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
          ),
          child: Icon(icon, size: 22, color: scheme.primary),
        ),
      ),
    );
  }
}
