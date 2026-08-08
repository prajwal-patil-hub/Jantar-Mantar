import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Map constants (ADR-7: flutter_map + OSM + FMTC; ADR-13: standard OSM
/// style for MVP).
///
/// **The tile source is a launch blocker, not a preference.** OSM's usage
/// policy does not permit an app with a real user base, and the arithmetic
/// says the same thing: this app is site-scoped, so a user session touches
/// on the order of 120–250 tiles, which at 1,000 users is 240k–1M requests a
/// month. Every free hosted tier is 100k–200k. There is no free tier that
/// holds this, so the endpoint has to become one we serve.
///
/// The flip side of being site-scoped is that self-serving is small: the
/// ENTIRE tile pyramid this app can ever display — z12–18 over a 3 km box at
/// all four sites — is about 3,400 tiles, roughly 72 MB. That is a static
/// directory, not a service.
///
/// Second reason, and the one that outranks cost: a tile request tells
/// whoever serves it which patch of ground a user is looking at, tied to
/// their IP. This project refuses to store precise user location on its own
/// server; routing the same signal to a third party by default is the same
/// leak with extra steps.
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

  /// Half-width of a site's mapped box, in metres.
  ///
  /// Whatever serves the tiles, coverage is finite — a self-hosted pyramid
  /// covers the boxes it was cut for, and nothing else. The app has to know
  /// where that edge is so it can say so, because a map that renders blank
  /// ground outside its coverage is indistinguishable from a map that is
  /// telling you the area is empty.
  static const siteRadiusMeters = 1500.0;

  /// Whether [point] falls inside any site's mapped box.
  ///
  /// Deliberately not "the nearest site is within X" — the boxes are what a
  /// tile extract is cut to, so this is a coverage question, not a proximity
  /// one.
  static bool isMapped(LatLng point) =>
      sites.any((s) => s.covers(point, siteRadiusMeters));

  /// The site whose box contains [point], or null outside coverage.
  static ProtestSite? siteAt(LatLng point) {
    for (final s in sites) {
      if (s.covers(point, siteRadiusMeters)) return s;
    }
    return null;
  }

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

  /// A square box, not a circle: tile extracts are cut to bounding boxes, so
  /// a radius test would claim coverage at the corners it does not have.
  bool covers(LatLng point, double halfWidthMeters) {
    const metresPerDegreeLat = 111320.0;
    final dLat = (point.latitude - center.latitude).abs() * metresPerDegreeLat;
    if (dLat > halfWidthMeters) return false;

    // Longitude degrees shrink with latitude. Using the point's own latitude
    // rather than a constant matters here: at London the factor is 0.62, so a
    // fixed conversion would over-claim coverage by more than a third.
    final scale = math.cos(point.latitude * math.pi / 180).abs();
    final dLng =
        (point.longitude - center.longitude).abs() * metresPerDegreeLat * scale;
    return dLng <= halfWidthMeters;
  }
}
