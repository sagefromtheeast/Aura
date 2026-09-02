
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dummy_library_data.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/track_tile.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final DummyArtist artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // For albums we can just reuse the generic album provider, maybe filter, but dummy is fine
    final albumsAsync = ref.watch(dummyAlbumsProvider);
    final topTracksAsync = ref.watch(dummyArtistTopTracksProvider(artist.id));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Parallax Header with Gradient Overlay
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black87,
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for artist image
                  Container(
                    color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 120,
                        color: DesignTokens.primarySeed.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.surface.withValues(alpha: 0.8),
                          theme.colorScheme.surface,
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Artist Name
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artist.name,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${artist.albumCount} Albums • ${artist.trackCount} Tracks',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Shuffle All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.primarySeed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Tracks Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Top Tracks',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Top Tracks List
          topTracksAsync.when(
            data: (tracks) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TrackTile(
                        track: tracks[index],
                        index: index,
                      ),
                    );
                  },
                  childCount: tracks.length,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ),

          // Albums Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
              child: Text(
                'Albums',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Albums Horizontal List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: albumsAsync.when(
                data: (albums) {
                  // In a real app, filter albums by this artist.
                  final artistAlbums = albums.take(5).toList();
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: artistAlbums.length,
                    itemBuilder: (context, index) {
                      final album = artistAlbums[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                color: album.coverColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: album.coverColor.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.album, size: 48, color: Colors.white54),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              album.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              album.year.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Bottom padding
          ),
        ],
      ),
    );
  }
}
