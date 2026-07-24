import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/application/map_providers.dart';

/// Early Profile screen: for now just the pending-uploads tray counter
/// (ui-ux-spec §1.12). Account, language, appearance, privacy and panic-wipe
/// sections land with their own epics.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingCountProvider).asData?.value ?? 0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.cloud_upload_outlined),
              ),
              title: const Text('Pending uploads'),
              subtitle: Text(
                pendingCount == 0
                    ? 'Nothing waiting to send.'
                    : '$pendingCount submission(s) will be sent for '
                          'verification when connection returns.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              enabled: false,
              leading: Icon(Icons.settings_outlined),
              title: Text('Account, language, appearance, privacy'),
              subtitle: Text('Coming with later builds (E8, E9).'),
            ),
          ),
        ],
      ),
    );
  }
}
