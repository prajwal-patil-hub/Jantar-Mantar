import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_mode.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../map/application/map_providers.dart';
import '../../verify/application/verify_providers.dart';
import '../../verify/presentation/admin_login_screen.dart';
import '../../verify/presentation/verification_queue_screen.dart';

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
              title: const Text('Demo mode'),
              subtitle: const Text(
                'Explore every screen with sample data — no backend or login '
                'needed. Turn off to use the live Supabase backend.',
              ),
              value: ref.watch(demoModeProvider),
              onChanged: (v) => ref.read(demoModeProvider.notifier).set(v),
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
            child: ListTile(
              enabled: false,
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settingsComingLater),
            ),
          ),
        ],
      ),
    );
  }
}
