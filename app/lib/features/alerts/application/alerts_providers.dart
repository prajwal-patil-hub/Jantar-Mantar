import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';

/// Active (unexpired) alerts, critical first. Cached rows keep showing
/// offline — the feed adds a "may be outdated" note instead of going blank
/// (ui-ux-spec §1.10).
final activeAlertsProvider = StreamProvider<List<Alert>>(
  (ref) => ref.watch(alertRepositoryProvider).watchActive(),
);

/// The newest active critical alert, if any — drives the full-width map
/// banner (shown instantly, no animation: safety-critical info).
final criticalAlertProvider = Provider<Alert?>((ref) {
  final alerts = ref.watch(activeAlertsProvider).asData?.value ?? const [];
  for (final alert in alerts) {
    if (alert.severity == AlertSeverity.critical) return alert;
  }
  return null;
});
