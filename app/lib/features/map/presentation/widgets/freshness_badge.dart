import 'package:flutter/material.dart';

import '../../../../core/domain/freshness.dart';
import '../../../../core/l10n/l10n_labels.dart';
import '../../../../core/theme/status_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// "Verified 8 min ago" with the freshness band as color + icon + text.
/// Unverified facilities get the grey `?` treatment.
class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({required this.verifiedAt, this.now, super.key});

  final DateTime? verifiedAt;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final at = verifiedAt;
    if (at == null) {
      return _chip(colors.unverified, Icons.help_outline, l10n.notYetVerified);
    }

    final asOf = now ?? DateTime.now();
    final text = freshnessTextL10n(l10n, at, asOf);

    return switch (freshnessAt(at, asOf)) {
      Freshness.fresh => _chip(colors.good, Icons.verified, text),
      Freshness.judgment => _chip(colors.low, Icons.schedule, text),
      Freshness.stale => _chip(colors.out, Icons.history, text),
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
