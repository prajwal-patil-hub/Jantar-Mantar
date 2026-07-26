import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/map/map_config.dart';
import '../../../core/map/tile_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Drag-the-map picker for placing a group amenity. Starts at the site centre
/// and returns the chosen [LatLng] (no GPS permission involved — same
/// privacy-first approach as the submit flow).
class PickLocationScreen extends ConsumerStatefulWidget {
  const PickLocationScreen({this.initial, super.key});

  final LatLng? initial;

  @override
  ConsumerState<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends ConsumerState<PickLocationScreen> {
  late LatLng _center = widget.initial ?? MapConfig.jantarMantar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickOnMap)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(l10n.pickAmenityHint),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 17,
                    minZoom: MapConfig.minZoom,
                    maxZoom: MapConfig.maxZoom,
                    onPositionChanged: (camera, _) => _center = camera.center,
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
                      // Anchor the pin tip to the map centre.
                      padding: EdgeInsets.only(bottom: 36),
                      child: Icon(Icons.location_on, size: 44),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => Navigator.of(context).pop(_center),
                icon: const Icon(Icons.check),
                label: Text(l10n.confirmLocation),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
