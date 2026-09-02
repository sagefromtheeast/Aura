import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dummy_library_data.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/hero_album_art.dart';
import '../../widgets/track_tile.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final DummyAlbum album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tracksAsync = ref.watch(dummyAlbumTracksProvider(album.id));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background Gradient matching coverColor
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    album.coverColor.withValues(alpha: isDark ? 0.4 : 0.2),
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 420.0,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(top: 80.0, bottom: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            HeroAlbumArt(
                              heroTag: 'album_${album.id}',
                              dominantColor: album.coverColor,
                              size: 240, // 280 requested, scaled to fit better
                            ),
                            const SizedBox(height: 24),
                            Text(
                              album.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              album.artistName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Metadata Pills
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMetadataPill('${album.trackCount} Tracks', theme),
                                const SizedBox(width: 8),
                                _buildMetadataPill('${(album.trackCount * 3.5).round()} min', theme), // Mock duration
                                const SizedBox(width: 8),
                                _buildMetadataPill(album.year.toString(), theme),
                                const SizedBox(width: 8),
                                _buildMetadataPill('Pop', theme), // Hardcoded genre for dummy
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Action Buttons Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play'),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Shuffle'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.3),
                            ),
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

              // Track List
              tracksAsync.when(
                data: (tracks) => SliverPadding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 100.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TrackTile(
                            track: tracks[index],
                            index: index,
                            isPlaying: index == 0, // Mock first track as playing
                          ),
                        );
                      },
                      childCount: tracks.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataPill(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
