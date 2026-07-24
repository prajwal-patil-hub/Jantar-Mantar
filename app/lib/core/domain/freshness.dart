/// Freshness banding (CONTEXT.md locked decision 6, ARCHITECTURE.md sync
/// rule 4): fresh <5 min · judgment 5–30 min · stale >30 min. Drives UI
/// treatment everywhere a verified timestamp is shown.
library;

enum Freshness { fresh, judgment, stale }

Freshness freshnessAt(DateTime verifiedAt, DateTime now) {
  final age = now.difference(verifiedAt);
  if (age < const Duration(minutes: 5)) return Freshness.fresh;
  if (age <= const Duration(minutes: 30)) return Freshness.judgment;
  return Freshness.stale;
}
