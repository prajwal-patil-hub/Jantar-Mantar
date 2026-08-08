import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/demo/demo_mode.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/providers.dart';
import '../../../core/theme/depth.dart';
import '../../../core/theme/status_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/alert_visuals.dart';

/// Admin authoring for **public** alerts (E6) — the counterpart to the
/// verification queue.
///
/// Unlike a group broadcast (ADR-21), this is deliberately server-readable
/// public data: it goes on the canonical map for everyone, verified or not
/// signed in. That asymmetry is the point, so the screen says so plainly
/// before you post.
///
/// Local-first: the alert lands in Drift immediately, so the feed and the map
/// banner update at once, and is then pushed to Supabase. RLS lets only admins
/// insert into `public.alerts` — the negative tests already assert that a
/// non-admin cannot.
///
/// Honest limit: there is no outbox retry for alerts yet (submissions and SOS
/// have one). If the push fails the alert stays on this device and the UI says
/// so, rather than pretending it reached anyone.
class ComposeAlertScreen extends ConsumerStatefulWidget {
  const ComposeAlertScreen({super.key});

  @override
  ConsumerState<ComposeAlertScreen> createState() => _ComposeAlertScreenState();
}

class _ComposeAlertScreenState extends ConsumerState<ComposeAlertScreen> {
  final _controller = TextEditingController();
  AlertSeverity _severity = AlertSeverity.warn;
  Duration _ttl = const Duration(hours: 2);
  bool _sending = false;

  static const _ttlChoices = [
    Duration(minutes: 30),
    Duration(hours: 2),
    Duration(hours: 6),
    Duration(hours: 24),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _ttlLabel(AppL10n l10n, Duration d) => d.inHours >= 1
      ? l10n.alertExpiresHours(d.inHours)
      : l10n.alertExpiresMinutes(d.inMinutes);

  Future<void> _publish() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;

    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Critical alerts take over the map for everyone, so they get a second
    // confirmation. The other severities do not — friction on a warning is
    // friction on getting information out.
    if (_severity == AlertSeverity.critical) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.crisis_alert),
          title: Text(l10n.alertConfirmCriticalTitle),
          content: Text(l10n.alertConfirmCriticalBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.alertPublish),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _sending = true);
    try {
      final now = DateTime.now();
      // Client-generated id, idempotent on retry (ADR-14).
      final id = 'local-alert-${now.microsecondsSinceEpoch}';
      await ref.read(alertRepositoryProvider).upsertAlerts([
        AlertsCompanion.insert(
          id: id,
          severity: _severity,
          body: body,
          createdBy: const Value('admin'),
          createdAt: now,
          expiresAt: now.add(_ttl),
        ),
      ]);
      // Demo Mode stops at the local write by design — nothing leaves the
      // device. Otherwise push it, and be explicit if that fails.
      if (!ref.read(demoModeProvider)) {
        final client = ref.read(supabaseClientProvider);
        if (client == null) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.alertLocalOnly)));
          navigator.pop();
          return;
        }
        try {
          await client.from('alerts').insert({
            'id': id,
            'severity': _severity.name,
            'body': body,
            'created_at': now.toUtc().toIso8601String(),
            'expires_at': now.add(_ttl).toUtc().toIso8601String(),
          });
        } on Object {
          messenger.showSnackBar(SnackBar(content: Text(l10n.alertLocalOnly)));
          navigator.pop();
          return;
        }
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.alertPublished)));
      navigator.pop();
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.groupActionFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final isDemo = ref.watch(demoModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertComposeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Public alerts are the opposite of group chat. Say it before they
          // type, not after they post.
          DepthSurface(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.public, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.alertPublicWarning)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(l10n.broadcastSeverity, style: _label(context)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final s in AlertSeverity.values)
                ChoiceChip(
                  selected: _severity == s,
                  onSelected: (_) => setState(() => _severity = s),
                  avatar: Icon(s.icon, size: 18, color: s.colorOf(colors)),
                  label: Text(s.label(l10n)),
                ),
            ],
          ),
          const SizedBox(height: 20),

          Text(l10n.alertBody, style: _label(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            maxLength: 280,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.alertBodyHint,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          Text(l10n.alertExpiry, style: _label(context)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final d in _ttlChoices)
                ChoiceChip(
                  selected: _ttl == d,
                  onSelected: (_) => setState(() => _ttl = d),
                  label: Text(_ttlLabel(l10n, d)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.alertExpiryWhy,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              backgroundColor: _severity == AlertSeverity.critical
                  ? colors.out
                  : null,
            ),
            onPressed: _controller.text.trim().isEmpty || _sending
                ? null
                : _publish,
            icon: const Icon(Icons.campaign),
            label: Text(l10n.alertPublish),
          ),
          if (isDemo) ...[
            const SizedBox(height: 12),
            Text(
              l10n.alertDemoNote,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  TextStyle? _label(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall;
}
