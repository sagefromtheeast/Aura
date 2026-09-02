import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'navigation_state.dart';
import 'mini_player.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationStateProvider);
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true, // Required for frosted glass nav bar
      body: Stack(
        children: [
          child,
          // Floating MiniPlayer
          Positioned(
            left: 0,
            right: 0,
            bottom: 80 + bottomPadding + 8, // NavigationBar height (80) + safe area + 8px spacing
            child: const MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: theme.colorScheme.primaryContainer,
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  ref.read(navigationStateProvider.notifier).state = index;
                  // Handle routing
                  switch (index) {
                    case 0:
                      context.go('/library');
                      break;
                    case 1:
                      context.go('/playlists');
                      break;
                    case 2:
                      context.go('/stats');
                      break;
                    case 3:
                      context.go('/settings');
                      break;
                  }
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.library_music_outlined),
                    selectedIcon: Icon(Icons.library_music),
                    label: 'Library',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.queue_music_outlined),
                    selectedIcon: Icon(Icons.queue_music),
                    label: 'Playlists',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: 'Stats',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
