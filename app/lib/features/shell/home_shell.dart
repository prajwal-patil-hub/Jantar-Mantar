import 'package:flutter/material.dart';

import '../alerts/presentation/alerts_screen.dart';
import '../events/presentation/events_screen.dart';
import '../map/presentation/map_screen.dart';
import '../profile/presentation/profile_screen.dart';

/// Bottom-navigation shell: Map · Events · Alerts · Profile (ui-ux-spec §Global
/// design shell). The persistent SOS element and connectivity banner attach
/// here when E7/E2 land. Nav bar glass treatment is an open DESIGN.md choice.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    MapScreen(),
    EventsScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
