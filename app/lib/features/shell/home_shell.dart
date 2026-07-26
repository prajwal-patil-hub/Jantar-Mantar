import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/demo/demo_mode.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/providers.dart';
import '../../core/widgets/glass_surface.dart';
import '../../l10n/app_localizations.dart';
import '../alerts/presentation/alerts_screen.dart';
import '../events/presentation/events_screen.dart';
import '../groups/presentation/groups_screen.dart';
import '../map/presentation/map_screen.dart';
import '../profile/presentation/profile_screen.dart';

/// Bottom-navigation shell: Map · Events · Alerts · Profile (ui-ux-spec
/// §Global design shell). Docked M3 bar rendered as a glass hero surface
/// (ADR-13); GlassSurface degrades to the opaque fallback on weak devices
/// and in high-contrast mode.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Background sync loop; a no-op when Supabase isn't configured.
    ref.read(syncServiceProvider).start();
    // Restore the saved language (one-frame flash to system locale on the
    // very first launch only; cached thereafter).
    ref.read(localeProvider.notifier).load();
    // Restore the saved Demo Mode choice.
    ref.read(demoModeProvider.notifier).load();
  }

  static const _screens = [
    MapScreen(),
    EventsScreen(),
    GroupsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      extendBody: true,
      body: _screens[_index],
      bottomNavigationBar: GlassSurface(
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              label: l10n.navMap,
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_outlined),
              label: l10n.navEvents,
            ),
            NavigationDestination(
              icon: const Icon(Icons.groups_outlined),
              label: l10n.navGroups,
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_outlined),
              label: l10n.navAlerts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
