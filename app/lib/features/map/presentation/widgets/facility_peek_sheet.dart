import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../core/widgets/glass_surface.dart';
import 'facility_visuals.dart';
import 'freshness_badge.dart';

/// Lightweight pin-tap peek. The full facility detail sheet — capacity
/// numbers, photos, directions, update action — is E4.
Future<void> showFacilityPeekSheet(BuildContext context, Facility facility) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final colors = Theme.of(context).extension<StatusColors>()!;
      final statusColor = facility.status.colorOf(colors);
      return GlassSurface(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(facility.type.icon, size: 28, color: statusColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        facility.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: statusColor, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            facility.status.icon,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            facility.status.label,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(facility.type.label),
                  ],
                ),
                const SizedBox(height: 12),
                FreshnessBadge(verifiedAt: facility.verifiedAt),
                const SizedBox(height: 8),
                Text(
                  'Capacity, photos, directions and updates arrive with the '
                  'facility detail build (E4).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
