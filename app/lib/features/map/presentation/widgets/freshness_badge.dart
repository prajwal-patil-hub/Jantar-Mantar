import 'package:flutter/material.dart';

import '../../../../core/domain/freshness.dart';
import '../../../../core/theme/status_colors.dart';

/// "Verified 8 min ago" with the freshness band as color + icon + text.
/// Unverified facilities get the grey `?` treatment.
class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({required this.verifiedAt, this.now, super.key});

  final DateTime? verifiedAt;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<StatusColors>()!;
    final at = verifiedAt;
    if (at == null) {
      return _chip(colors.unverified, Icons.help_outline, 'Not yet verified');
    }

    final asOf = now ?? DateTime.now();
    final band = freshnessAt(at, asOf);
    final age = asOf.difference(at);
    final ageText = age.inMinutes < 1
        ? 'just now'
        : age.inMinutes < 60
        ? '${age.inMinutes} min ago'
        : '${age.inHours} h ago';

    return switch (band) {
      Freshness.fresh => _chip(
        colors.good,
        Icons.verified,
        'Verified $ageText',
      ),
      Freshness.judgment => _chip(
        colors.low,
        Icons.schedule,
        'Verified $ageText',
      ),
      Freshness.stale => _chip(
        colors.out,
        Icons.history,
        'Verified $ageText — needs re-check',
      ),
    };
  }

  Widget _chip(Color color, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
