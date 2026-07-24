import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/status_colors.dart';

/// Icons + status color per facility type/status. Localized text labels live
/// in core/l10n/l10n_labels.dart; status is ALWAYS color + icon + text
/// together (accessibility rule — never color alone).
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
}

extension FacilityStatusVisuals on FacilityStatus {
  IconData get icon => switch (this) {
    FacilityStatus.good => Icons.check_circle,
    FacilityStatus.low => Icons.error,
    FacilityStatus.out => Icons.cancel,
    FacilityStatus.closed => Icons.block,
  };

  Color colorOf(StatusColors colors) => switch (this) {
    FacilityStatus.good => colors.good,
    FacilityStatus.low => colors.low,
    FacilityStatus.out => colors.out,
    FacilityStatus.closed => colors.unverified,
  };
}
