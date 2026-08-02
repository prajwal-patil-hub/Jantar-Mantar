import 'package:latlong2/latlong.dart';

/// Map constants (ADR-7: flutter_map + OSM + FMTC; ADR-13: standard OSM
/// style for MVP). The public OSM tile server's usage policy forbids heavy
/// production traffic — swap to a tile provider (Stadia/Thunderforest/
/// self-hosted Protomaps) before real deployment.
abstract final class MapConfig {
  static const tileStore = 'mapStore';
  static const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const attribution = '© OpenStreetMap contributors';

  /// Sent as the User-Agent package per OSM's tile usage policy, which
  /// requires a User-Agent that identifies the app well enough to contact its
  /// author. This tracked the Flutter template's `com.example.…` long after
  /// the real applicationId was set — and `com.example.*` is exactly the
  /// shape OSM blocks, so the tiles would have stopped without warning.
  ///
  /// Must stay equal to the Android applicationId / iOS bundle id; a test
  /// asserts it is not a placeholder.
  static const userAgentPackageName = 'io.github.prajwalpatilhub.commonground';

  /// Jantar Mantar, New Delhi — the default site the map opens on.
  static final LatLng jantarMantar = LatLng(28.62710, 77.21660);

  static const initialZoom = 16.0;
  static const minZoom = 3.0;
  static const maxZoom = 19.0;

  /// Sites the map can jump to. The app is still single-site by design for the
  /// MVP (CONTEXT.md), but the demo data covers more than one city, and pins
  /// thousands of kilometres away are unreachable without a way to move the
  /// camera there. Nothing here changes what syncs — it only moves the view.
  static final List<ProtestSite> sites = [
    ProtestSite(
      id: 'delhi',
      name: 'Jantar Mantar, New Delhi',
      center: jantarMantar,
    ),
    ProtestSite(
      id: 'london',
      name: 'Parliament Square, London',
      center: LatLng(51.50072, -0.12762),
    ),
    ProtestSite(
      id: 'bengaluru',
      name: 'Town Hall, Bengaluru',
      center: LatLng(12.96606, 77.58549),
    ),
    // A flood-response site, not a protest one: the same facility model
    // covers a relief camp (docs/research/disaster-response-adaptation.md).
    ProtestSite(
      id: 'guwahati',
      name: 'Flood relief camps, Guwahati',
      center: LatLng(26.14450, 91.73620),
    ),
  ];
}

/// A named location the map can centre on.
class ProtestSite {
  const ProtestSite({
    required this.id,
    required this.name,
    required this.center,
  });

  final String id;
  final String name;
  final LatLng center;
}
