/// A user's verification standing (Phase 4, ADR-25).
///
/// Mirrors the `my_trust()` RPC. The thresholds come **from the server** with
/// the counts, deliberately: a hardcoded client copy would drift from the
/// rules people are actually judged by, and the progress bar would then lie.
enum TrustTier { newcomer, trusted, verifier }

class TrustStanding {
  const TrustStanding({
    required this.tier,
    required this.approved,
    required this.rejected,
    required this.trustedAt,
    required this.verifierAt,
  });

  /// What a user with no server row (or no backend at all) sees.
  static const unknown = TrustStanding(
    tier: TrustTier.newcomer,
    approved: 0,
    rejected: 0,
    trustedAt: 5,
    verifierAt: 20,
  );

  final TrustTier tier;
  final int approved;
  final int rejected;

  /// Approved-submission counts required for the next two tiers.
  final int trustedAt;
  final int verifierAt;

  /// Approvals still needed for the next tier, or null at the top.
  int? get remaining => switch (tier) {
    TrustTier.newcomer => (trustedAt - approved).clamp(0, trustedAt),
    TrustTier.trusted => (verifierAt - approved).clamp(0, verifierAt),
    TrustTier.verifier => null,
  };

  /// 0…1 progress towards the next tier; 1 at the top tier.
  double get progress => switch (tier) {
    TrustTier.newcomer =>
      trustedAt == 0 ? 1 : (approved / trustedAt).clamp(0.0, 1.0),
    TrustTier.trusted =>
      verifierAt == 0 ? 1 : (approved / verifierAt).clamp(0.0, 1.0),
    TrustTier.verifier => 1,
  };

  static TrustStanding fromJson(Map<String, Object?> json) {
    final thresholds =
        (json['thresholds'] as Map?)?.cast<String, Object?>() ?? const {};
    int intOf(Object? v, int fallback) => switch (v) {
      final int i => i,
      final num n => n.toInt(),
      final String s => int.tryParse(s) ?? fallback,
      _ => fallback,
    };
    return TrustStanding(
      tier: switch (json['tier']) {
        'verifier' => TrustTier.verifier,
        'trusted' => TrustTier.trusted,
        _ => TrustTier.newcomer,
      },
      approved: intOf(json['approved'], 0),
      rejected: intOf(json['rejected'], 0),
      trustedAt: intOf(thresholds['trusted_approved'], 5),
      verifierAt: intOf(thresholds['verifier_approved'], 20),
    );
  }
}
