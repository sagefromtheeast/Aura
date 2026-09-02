import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dummy_library_data.dart';
import 'album_detail_screen.dart';

class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(dummyAlbumsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        // ignore: unused_result
        ref.refresh(dummyAlbumsProvider);
        await Future<void>.delayed(const Duration(seconds: 1)); // Wait for refresh
      },
      child: albumsAsync.when(
        data: (albums) {
          if (albums.isEmpty) {
            return _buildEmptyState(theme);
          }

          return CustomScrollView(
            slivers: [
              // Search and Filter Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search Bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.3 : 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(Icons.search, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Text(
                              'Find in Albums',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Recently Added', isSelected: true, theme: theme),
                            const SizedBox(width: 8),
                            _buildFilterChip('Alphabetical', isSelected: false, theme: theme),
                            const SizedBox(width: 8),
                            _buildFilterChip('By Artist', isSelected: false, theme: theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Album Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 0.75, // Adjust for 160px cover + text below
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = albums[index];
                      return _AlbumCard(album: album);
                    },
                    childCount: albums.length,
                  ),
                ),
              ),
              
              // Bottom padding for MiniPlayer
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading albums: $error')),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected, required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
              ? Colors.transparent 
              : (theme.brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.album, size: 80, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Your collection starts here.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final DummyAlbum album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => AlbumDetailScreen(album: album)),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: album.coverColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: album.coverColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.music_note, size: 40, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Album Info
          Text(
            album.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            album.artistName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
