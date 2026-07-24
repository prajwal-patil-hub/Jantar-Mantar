import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/status_colors.dart';
import 'facility_visuals.dart';

/// Map pin: type icon in a circle whose border carries the status color,
/// plus a small status-glyph badge — shape + icon + color, never color
/// alone. Grey dashed-feel (reduced opacity) for closed facilities.
class FacilityMarker extends StatelessWidget {
  const FacilityMarker({required this.facility, this.onTap, super.key});

  final Facility facility;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<StatusColors>()!;
    final statusColor = facility.status.colorOf(colors);
    final surface = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label:
            '${facility.name}, ${facility.type.label}, '
            '${facility.status.label}',
        button: true,
        child: Opacity(
          opacity: facility.status == FacilityStatus.closed ? 0.6 : 1,
          child: Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 3),
                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Colors.black26),
                  ],
                ),
                child: Icon(facility.type.icon, size: 22, color: statusColor),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    facility.status.icon,
                    size: 16,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
