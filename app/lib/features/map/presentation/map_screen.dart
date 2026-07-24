import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart';
import '../../../core/map/map_config.dart';
import '../../../core/map/tile_providers.dart';
import '../application/map_providers.dart';
import 'widgets/facility_marker.dart';
import 'widgets/facility_peek_sheet.dart';
import 'widgets/filter_chip_row.dart';
import 'widgets/nearby_sheet.dart';

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

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facilities =
        ref.watch(facilitiesProvider).asData?.value ?? const <Facility>[];

    final markers = [
      for (final facility in facilities)
        Marker(
          point: LatLng(facility.lat, facility.lng),
          width: 48,
          height: 48,
          child: FacilityMarker(
            facility: facility,
            onTap: () => showFacilityPeekSheet(context, facility),
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
            children: [const SizedBox(height: 4), const FilterChipRow()],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'recenter',
                tooltip: 'Back to Jantar Mantar',
                onPressed: () => _mapController.move(
                  MapConfig.jantarMantar,
                  MapConfig.initialZoom,
                ),
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'report',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('The 5-step submit flow arrives with E4.'),
                  ),
                ),
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Report'),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: 200,
          child: _SosButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The SOS screen arrives with E7.')),
            ),
          ),
        ),
        NearbySheet(
          onFacilityTap: (item) {
            _mapController.move(
              LatLng(item.facility.lat, item.facility.lng),
              MapConfig.initialZoom,
            );
            showFacilityPeekSheet(context, item.facility);
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
