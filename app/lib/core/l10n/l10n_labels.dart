import '../../l10n/app_localizations.dart';
import '../db/app_database.dart';
import '../domain/freshness.dart';

/// Localized labels for domain enums. The icons/colors live in the
/// presentation `*_visuals.dart` extensions; text always comes from here so
/// status is color + icon + *localized* text (accessibility rule).
extension FacilityTypeL10n on FacilityType {
  String label(AppL10n l10n) => switch (this) {
    FacilityType.water => l10n.typeWater,
    FacilityType.food => l10n.typeFood,
    FacilityType.shelter => l10n.typeShelter,
    FacilityType.medical => l10n.typeMedical,
    FacilityType.toilet => l10n.typeToilet,
    FacilityType.safeArea => l10n.typeSafeArea,
    FacilityType.danger => l10n.typeDanger,
  };
}

extension FacilityStatusL10n on FacilityStatus {
  String label(AppL10n l10n) => switch (this) {
    FacilityStatus.good => l10n.statusGood,
    FacilityStatus.low => l10n.statusLow,
    FacilityStatus.out => l10n.statusOut,
    FacilityStatus.closed => l10n.statusClosed,
  };
}

extension AlertSeverityL10n on AlertSeverity {
  String label(AppL10n l10n) => switch (this) {
    AlertSeverity.info => l10n.alertInfo,
    AlertSeverity.warn => l10n.alertWarning,
    AlertSeverity.critical => l10n.alertCritical,
  };
}

/// Localized relative time ("5 min ago"), shared by badges and alert cards.
String relativeTimeL10n(AppL10n l10n, DateTime at, DateTime now) {
  final age = now.difference(at);
  if (age.inMinutes < 1) return l10n.justNow;
  if (age.inMinutes < 60) return l10n.minAgo(age.inMinutes);
  if (age.inHours < 24) return l10n.hoursAgo(age.inHours);
  return l10n.daysAgo(age.inDays);
}

/// Localized freshness line for a verified timestamp.
String freshnessTextL10n(AppL10n l10n, DateTime verifiedAt, DateTime now) {
  final time = relativeTimeL10n(l10n, verifiedAt, now);
  return switch (freshnessAt(verifiedAt, now)) {
    Freshness.fresh || Freshness.judgment => l10n.verifiedAgo(time),
    Freshness.stale => l10n.verifiedAgoRecheck(time),
  };
}
