import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/glass_surface.dart';
import '../alerts/presentation/alerts_screen.dart';
import '../events/presentation/events_screen.dart';
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
  }

  static const _screens = [
    MapScreen(),
    EventsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_index],
      bottomNavigationBar: GlassSurface(
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
