import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/home_shell.dart';

/// Root widget. Theme follows the system light/dark setting (locked choice);
/// a manual Light / Dark / High-contrast Outdoor override lands with the
/// Profile/Settings feature.
class SahayataApp extends StatelessWidget {
  const SahayataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommonGround',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
