import 'package:flutter/material.dart';

import '../../../core/db/app_database.dart';
import '../../../core/theme/status_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Icons, colours and localised labels for route hazards (ADR-31).
///
/// Kept separate from the domain enum for the same reason the facility
/// visuals are: `enums.dart` must stay free of Flutter and of language, so
/// the data layer and the tests never depend on either.
///
/// Every condition is icon **and** colour **and** text — a driver glancing at
/// this in the rain does not get to inspect a legend.
extension RouteConditionVisuals on RouteCondition {
  IconData get icon => switch (this) {
    RouteCondition.impassable => Icons.block,
    RouteCondition.difficult => Icons.warning_amber,
    RouteCondition.cleared => Icons.check_circle_outline,
  };

  Color colorOf(StatusColors colors) => switch (this) {
    RouteCondition.impassable => colors.out,
    RouteCondition.difficult => colors.low,
    RouteCondition.cleared => colors.good,
  };

  String label(AppL10n l10n) => switch (this) {
    RouteCondition.impassable => l10n.routeImpassable,
    RouteCondition.difficult => l10n.routeDifficult,
    RouteCondition.cleared => l10n.routeCleared,
  };
}

extension RouteCauseVisuals on RouteCause {
  IconData get icon => switch (this) {
    RouteCause.flood => Icons.water,
    RouteCause.collapse => Icons.foundation,
    RouteCause.debris => Icons.dangerous_outlined,
    RouteCause.blocked => Icons.local_police_outlined,
    RouteCause.other => Icons.help_outline,
  };

  String label(AppL10n l10n) => switch (this) {
    RouteCause.flood => l10n.causeFlood,
    RouteCause.collapse => l10n.causeCollapse,
    RouteCause.debris => l10n.causeDebris,
    RouteCause.blocked => l10n.causeBlocked,
    RouteCause.other => l10n.causeOther,
  };
}
