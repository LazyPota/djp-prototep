import 'package:flutter/material.dart';

import '../../l10n/l10n_extensions.dart';
import 'activity_screen.dart';
import 'home_screen.dart';
import 'setup_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = <String>[l10n.homeTitle, l10n.activityTab, l10n.settingsTitle];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const ActivityScreen(),
          SettingsScreen(isVisible: _index == 2),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.shield_outlined), selectedIcon: const Icon(Icons.shield), label: l10n.homeTab),
          NavigationDestination(icon: const Icon(Icons.radar_outlined), selectedIcon: const Icon(Icons.radar), label: l10n.activityTab),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l10n.settingsTab),
        ],
      ),
    );
  }
}
