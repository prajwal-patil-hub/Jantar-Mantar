import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/status_colors.dart';

/// Icon + label per facility type and status. Status is ALWAYS presented as
/// color + icon + text together (accessibility rule — never color alone).
extension FacilityTypeVisuals on FacilityType {
  IconData get icon => switch (this) {
    FacilityType.water => Icons.water_drop,
    FacilityType.food => Icons.restaurant,
    FacilityType.shelter => Icons.night_shelter,
    FacilityType.medical => Icons.medical_services,
    FacilityType.toilet => Icons.wc,
    FacilityType.safeArea => Icons.shield,
    FacilityType.danger => Icons.warning,
  };

  String get label => switch (this) {
    FacilityType.water => 'Water',
    FacilityType.food => 'Food',
    FacilityType.shelter => 'Shelter',
    FacilityType.medical => 'Medical',
    FacilityType.toilet => 'Toilets',
    FacilityType.safeArea => 'Safe area',
    FacilityType.danger => 'Danger',
  };
}

extension FacilityStatusVisuals on FacilityStatus {
  IconData get icon => switch (this) {
    FacilityStatus.good => Icons.check_circle,
    FacilityStatus.low => Icons.error,
    FacilityStatus.out => Icons.cancel,
    FacilityStatus.closed => Icons.block,
  };

  String get label => switch (this) {
    FacilityStatus.good => 'Good',
    FacilityStatus.low => 'Low',
    FacilityStatus.out => 'Out',
    FacilityStatus.closed => 'Closed',
  };

  Color colorOf(StatusColors colors) => switch (this) {
    FacilityStatus.good => colors.good,
    FacilityStatus.low => colors.low,
    FacilityStatus.out => colors.out,
    FacilityStatus.closed => colors.unverified,
  };
}
