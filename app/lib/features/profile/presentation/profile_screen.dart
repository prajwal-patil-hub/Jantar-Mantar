import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/build_info.dart';
import '../../../core/demo/demo_mode.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/providers.dart';
import '../../../core/security/panic_wipe_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../alerts/application/critical_alert_signal.dart';
import '../../map/application/map_providers.dart';
import '../../verify/application/verify_providers.dart';
import '../../verify/presentation/admin_login_screen.dart';
import '../../verify/presentation/verification_queue_screen.dart';
import '../../verify/presentation/widgets/standing_card.dart';

/// Early Profile screen: pending-uploads tray, instant language toggle, and
/// the volunteer/admin entry (ui-ux-spec §1.12). Appearance and privacy
/// (panic-wipe) sections land with their own epics.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final pendingCount = ref.watch(pendingCountProvider).asData?.value ?? 0;
    final currentLocale = ref.watch(localeProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.profile, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          // On web there is no OS keystore: flutter_secure_storage falls back
          // to localStorage, which Safari evicts after ~7 idle days — that
          // would destroy the device identity and make cached group chat
          // permanently undecryptable. Say so where someone might otherwise
          // turn Demo Mode off and start using real E2E chat here.
          if (kIsWeb) ...[
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.public_off, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.webLimitedTitle,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.webLimitedBody,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Card(
            child: ListTile(
              leading: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.cloud_upload_outlined),
              ),
              title: Text(l10n.pendingUploads),
              subtitle: Text(
                pendingCount == 0
                    ? l10n.nothingWaiting
                    : l10n.pendingCount(pendingCount),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const StandingCard(),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language),
                      const SizedBox(width: 12),
                      Text(
                        l10n.language,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('English')),
                      ButtonSegment(value: 'hi', label: Text('हिन्दी')),
                    ],
                    selected: {currentLocale?.languageCode ?? 'en'},
                    onSelectionChanged: (selection) {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(selection.single));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.science_outlined),
              title: Text(l10n.demoMode),
              subtitle: Text(l10n.demoModeSubtitle),
              value: ref.watch(demoModeProvider),
              onChanged: (v) async {
                await ref.read(demoModeProvider.notifier).set(v);
                // Add or remove the sample map pins and alerts to match, so
                // demo data can never linger and be mistaken for real data.
                await applyDemoSeed(ref.read(appDatabaseProvider), on: v);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.crisis_alert),
                  title: Text(l10n.alertSignals),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration),
                  title: Text(l10n.alertVibrate),
                  subtitle: Text(l10n.alertVibrateSubtitle),
                  value: ref.watch(alertHapticsProvider),
                  onChanged: (v) =>
                      ref.read(alertHapticsProvider.notifier).set(v),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: Text(l10n.alertSound),
                  subtitle: Text(l10n.alertSoundSubtitle),
                  value: ref.watch(alertSoundProvider),
                  onChanged: (v) =>
                      ref.read(alertSoundProvider.notifier).set(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(l10n.volunteerAdmin),
              subtitle: Text(
                ref.watch(canVerifyProvider)
                    ? l10n.signedInAsAdmin
                    : l10n.verifiersSignIn,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ref.read(canVerifyProvider)
                      ? const VerificationQueueScreen()
                      : const AdminLoginScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              title: Text(l10n.panicWipe),
              subtitle: Text(l10n.panicWipeSubtitle),
              onTap: () => _confirmPanicWipe(context, ref),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              enabled: false,
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settingsComingLater),
            ),
          ),
          const SizedBox(height: 8),
          // Which build is this? The hosted app redeploys to the same URL, so
          // a stale phone and an up-to-date one look identical. Compare this
          // against the commit on GitHub to know for certain.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              BuildInfo.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Irreversible, so the dialog spells out exactly what goes and — just as
  /// importantly — what this cannot reach.
  Future<void> _confirmPanicWipe(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber),
        title: Text(l10n.panicWipeConfirmTitle),
        content: SingleChildScrollView(child: Text(l10n.panicWipeConfirmBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.panicWipeConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(panicWipeProvider).run();
      messenger.showSnackBar(SnackBar(content: Text(l10n.panicWipeDone)));
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.panicWipeFailed('$e'))),
      );
    }
  }
}
