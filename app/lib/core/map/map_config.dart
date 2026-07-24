import 'package:latlong2/latlong.dart';

/// Map constants (ADR-7: flutter_map + OSM + FMTC; ADR-13: standard OSM
/// style for MVP). The public OSM tile server's usage policy forbids heavy
/// production traffic — swap to a tile provider (Stadia/Thunderforest/
/// self-hosted Protomaps) before real deployment.
abstract final class MapConfig {
  static const tileStore = 'mapStore';
  static const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const attribution = '© OpenStreetMap contributors';

  /// Sent as the User-Agent package per OSM tile policy. Tracks the Android
  /// applicationId, which is still to be finalized before release.
  static const userAgentPackageName = 'com.example.jantar_mantar_sahayata';

  /// Jantar Mantar, New Delhi.
  static final LatLng jantarMantar = LatLng(28.62710, 77.21660);

  static const initialZoom = 16.0;
  static const minZoom = 3.0;
  static const maxZoom = 19.0;
}
