import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/map/map_config.dart';
import 'package:latlong2/latlong.dart';

/// Tile coverage (see MapConfig).
///
/// Whatever serves the tiles, coverage is finite, and flutter_map renders
/// "outside the extract" exactly like "nothing is here": flat empty ground.
/// On a map whose whole job is to say where water and toilets are, those two
/// must never look the same, so the app has to know where its own edge is.
void main() {
  const d = Distance();

  test('a site centre is covered', () {
    for (final site in MapConfig.sites) {
      expect(
        MapConfig.isMapped(site.center),
        isTrue,
        reason: '${site.name} does not cover its own centre',
      );
      expect(MapConfig.siteAt(site.center)?.id, site.id);
    }
  });

  test('somewhere with no site is not covered', () {
    // Mid-Atlantic, and a point between Delhi and Bengaluru — the second one
    // matters more: it is the case where "near India" must not mean "mapped".
    expect(MapConfig.isMapped(const LatLng(0, -30)), isFalse);
    expect(MapConfig.isMapped(const LatLng(20.5, 78.0)), isFalse);
    expect(MapConfig.siteAt(const LatLng(20.5, 78.0)), isNull);
  });

  test('the edge is where it claims to be, north-south', () {
    final delhi = MapConfig.sites.firstWhere((s) => s.id == 'delhi');
    final inside = d.offset(delhi.center, MapConfig.siteRadiusMeters * .9, 0);
    final outside = d.offset(delhi.center, MapConfig.siteRadiusMeters * 1.2, 0);
    expect(MapConfig.isMapped(inside), isTrue);
    expect(MapConfig.isMapped(outside), isFalse);
  });

  group('longitude is scaled by latitude, and it is not a rounding detail', () {
    // A degree of longitude is 111 km at the equator and 69 km at London.
    // Convert with a constant and the box silently grows east-west by
    // 1/cos(lat) — at London that is 1.6x, so the app would promise map
    // detail across 4.8 km of a 3 km extract and render blank ground.
    test('the error a constant conversion would introduce is large', () {
      final london = MapConfig.sites.firstWhere((s) => s.id == 'london');
      final scale = math.cos(london.center.latitude * math.pi / 180);
      expect(
        1 / scale,
        greaterThan(1.5),
        reason: 'if this were near 1.0 the test below would prove nothing',
      );
    });

    for (final id in ['delhi', 'london', 'bengaluru', 'guwahati']) {
      test('east-west edge holds at $id', () {
        final site = MapConfig.sites.firstWhere((s) => s.id == id);
        // Due east, in real metres.
        final inside = d.offset(
          site.center,
          MapConfig.siteRadiusMeters * .9,
          90,
        );
        final outside = d.offset(
          site.center,
          MapConfig.siteRadiusMeters * 1.3,
          90,
        );
        expect(
          MapConfig.isMapped(inside),
          isTrue,
          reason: '900m short of the edge must be inside it',
        );
        expect(
          MapConfig.isMapped(outside),
          isFalse,
          reason: 'a constant degrees-to-metres conversion passes this at the '
              'equator and fails at London — which is exactly the bug',
        );
      });
    }
  });

  test('the box is square, so a corner is not covered by a radius test', () {
    // The distinction is real: an extract is cut to a bounding box, and the
    // corner of that box is radius*sqrt(2) from the centre. A circular test
    // would refuse coverage the tiles actually have; a naive square test
    // would claim coverage past it. This pins the square.
    final site = MapConfig.sites.firstWhere((s) => s.id == 'delhi');
    final corner = d.offset(
      site.center,
      MapConfig.siteRadiusMeters * 1.35, // inside the corner, outside a circle
      45,
    );
    expect(
      d.as(LengthUnit.Meter, site.center, corner),
      greaterThan(MapConfig.siteRadiusMeters),
      reason: 'a circle of that radius would exclude this point',
    );
    expect(
      MapConfig.isMapped(corner),
      isTrue,
      reason: 'but the bounding box the tiles were cut to includes it',
    );
  });
}
