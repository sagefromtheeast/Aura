import 'package:flutter/material.dart';
import '../../widgets/mini_player.dart';
import '../library/library_screen.dart';
import '../stats/stats_dashboard_screen.dart';
import '../settings/equalizer_screen.dart';
import '../settings/settings_main_screen.dart';

/// Main container scaffold managing bottom tab navigation and the floating MiniPlayer.
/// Uses an IndexedStack to retain scroll positions across all four primary views.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LibraryScreen(),
    StatsDashboardScreen(),
    EqualizerScreen(),
    SettingsMainScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content views (with padding at bottom so MiniPlayer never obscures content)
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // Floating MiniPlayer locked above bottom navigation bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.equalizer_outlined),
            selectedIcon: Icon(Icons.equalizer_rounded),
            label: 'Equalizer',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
