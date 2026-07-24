import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/theme/status_colors.dart';

/// Severity is always icon + label + color together (never color alone).
/// Warn/critical reuse the semantic amber/red; info gets a fixed blue that
/// cannot be confused with any facility status or the saffron accent.
extension AlertSeverityVisuals on AlertSeverity {
  static const infoBlue = Color(0xFF1976D2);

  IconData get icon => switch (this) {
    AlertSeverity.info => Icons.info_outline,
    AlertSeverity.warn => Icons.warning_amber,
    AlertSeverity.critical => Icons.crisis_alert,
  };

  Color colorOf(StatusColors colors) => switch (this) {
    AlertSeverity.info => infoBlue,
    AlertSeverity.warn => colors.low,
    AlertSeverity.critical => colors.out,
  };
}
