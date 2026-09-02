import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'albums_screen.dart';
import 'artists_screen.dart';
import 'playlists_screen.dart';
import 'folder_screen.dart';

class LibraryTabsScreen extends ConsumerStatefulWidget {
  const LibraryTabsScreen({super.key});

  @override
  ConsumerState<LibraryTabsScreen> createState() => _LibraryTabsScreenState();
}

class _LibraryTabsScreenState extends ConsumerState<LibraryTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false, // AppShell handles bottom nav bar safe area
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56.0),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.4 : 0.7),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: false, // 4 tabs fit well usually
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: theme.colorScheme.onPrimaryContainer,
                          unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: theme.colorScheme.primaryContainer,
                          ),
                          indicatorPadding: const EdgeInsets.all(4),
                          tabs: const [
                            Tab(text: 'Albums'),
                            Tab(text: 'Artists'),
                            Tab(text: 'Playlists'),
                            Tab(text: 'Folders'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              AlbumsScreen(),
              ArtistsScreen(),
              PlaylistsScreen(),
              FolderScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
