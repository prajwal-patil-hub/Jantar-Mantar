import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/status_colors.dart';

/// Route hazards drawn as lines on the map (ADR-31).
///
/// Below the marker cluster layer on purpose: a blocked road is context for
/// the pins, not a competitor for the tap target. Solid, no animation — same
/// rule as the critical banner, safety information does not wait for
/// decoration.
///
/// Only hazards are drawn. There is no "this road is open" rendering, because
/// crowd data cannot certify that, and a green line over a road someone is
/// deciding whether to drive through would be a life-safety claim the app has
/// no basis for. A [RouteCondition.cleared] report draws faintly and dashed —
/// it says "this was reported blocked and someone has since got through",
/// which is a retraction, not a guarantee.
class RouteLayer extends StatelessWidget {
  const RouteLayer({required this.routes, super.key});

  final List<RouteReport> routes;

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).extension<StatusColors>()!;

    return PolylineLayer(
      polylines: [
        for (final route in routes)
          Polyline(
            points: [
              LatLng(route.startLat, route.startLng),
              LatLng(route.endLat, route.endLng),
            ],
            color: switch (route.condition) {
              RouteCondition.impassable => colors.out,
              RouteCondition.difficult => colors.low,
              RouteCondition.cleared => colors.good,
            },
            strokeWidth: switch (route.condition) {
              RouteCondition.impassable => 6,
              RouteCondition.difficult => 5,
              RouteCondition.cleared => 3,
            },
            // A cleared route is drawn dashed and thin: visually a note that
            // a hazard was lifted, never a "safe route" highlight.
            pattern: route.condition == RouteCondition.cleared
                ? const StrokePattern.dotted()
                : const StrokePattern.solid(),
            borderColor: Colors.white70,
            borderStrokeWidth: 1,
          ),
      ],
    );
  }
}
