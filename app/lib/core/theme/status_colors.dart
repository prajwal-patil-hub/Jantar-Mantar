import 'package:flutter/material.dart';

/// Semantic facility-status colors. These are NEVER derived from the theme
/// seed and never change between themes (SECURITY/DESIGN rule) — status is
/// always conveyed as color + icon + text, never color alone.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.good,
    required this.low,
    required this.out,
    required this.unverified,
  });

  final Color good;
  final Color low;
  final Color out;
  final Color unverified;

  static const StatusColors standard = StatusColors(
    good: Color(0xFF2E7D32), // ✓
    low: Color(0xFFF9A825), // !
    out: Color(0xFFC62828), // ✕
    unverified: Color(0xFF9E9E9E), // ?
  );

  @override
  StatusColors copyWith({
    Color? good,
    Color? low,
    Color? out,
    Color? unverified,
  }) {
    return StatusColors(
      good: good ?? this.good,
      low: low ?? this.low,
      out: out ?? this.out,
      unverified: unverified ?? this.unverified,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      good: Color.lerp(good, other.good, t)!,
      low: Color.lerp(low, other.low, t)!,
      out: Color.lerp(out, other.out, t)!,
      unverified: Color.lerp(unverified, other.unverified, t)!,
    );
  }
}
