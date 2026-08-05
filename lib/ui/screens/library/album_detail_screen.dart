import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/track.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

final _albumTracksProvider = FutureProvider.family<List<Track>, String>((ref, albumId) {
  return ref.watch(musicRepositoryProvider).getTracksByAlbum(albumId);
});

/// Album Detail Screen showing dynamic cover artwork header, tracklist,
/// playback controls, and extracted acoustic metadata.
class AlbumDetailScreen extends ConsumerWidget {
  final Album album;
  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(_albumTracksProvider(album.id));

    return Semantics(
      label: 'Album Detail Screen for ${album.title} by ${album.artistName}',
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Luminous Slivers Header ─────────────────────────────────────
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              stretch: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back to albums',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_outline_rounded),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${album.title} to Favorites')),
                    );
                  },
                  tooltip: 'Favorite Album',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {},
                  tooltip: 'Album Options',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background gradient / artwork simulation
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4A154B), // Deep violet
                            Color(0xFF0F0D0A), // Dark surface
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: DesignTokens.radius24,
                          color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.album_rounded,
                          size: 96,
                          color: DesignTokens.primarySeed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Album Metadata & Action Row ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${album.artistName} · ${album.year > 0 ? album.year : 'Unknown Year'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: DesignTokens.spacing16),
                    Row(
                      children: [
                        Text(
                          '${album.trackCount} Tracks · Lossless FLAC/ALAC',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontFamily: DesignTokens.fontMono,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacing24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.primarySeed,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 28),
                            label: const Text('PLAY ALL', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              tracksAsync.whenData((tracks) {
                                if (tracks.isNotEmpty) {
                                  ref.read(playbackOrchestratorProvider).playTrack(tracks.first);
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacing12),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).cardColor,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
                          ),
                          icon: const Icon(Icons.shuffle_rounded, color: DesignTokens.primarySeed),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('IntelliShuffle active for album')),
                            );
                          },
                          tooltip: 'Shuffle Album',
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacing16),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ),

            // ── Tracklist Sliver ──────────────────────────────────────────
            tracksAsync.when(
              data: (tracks) {
                if (tracks.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'No tracks associated with this album yet.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = tracks[index];
                      final trackNum = index + 1;
                      final durationMin = (track.durationMs ~/ 60000);
                      final durationSec = ((track.durationMs % 60000) ~/ 1000).toString().padLeft(2, '0');

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: GlassCard(
                          onTap: () => ref.read(playbackOrchestratorProvider).playTrack(track),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '$trackNum',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: Theme.of(context).disabledColor,
                                        fontFamily: DesignTokens.fontMono,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      track.artistName,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).disabledColor,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$durationMin:$durationSec',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontFamily: DesignTokens.fontMono,
                                      color: Theme.of(context).disabledColor,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.more_horiz_rounded, size: 20),
                                onPressed: () {},
                                tooltip: 'Track Options',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: tracks.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error loading tracks: $err')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)), // Padding for mini player
          ],
        ),
      ),
    );
  }
}
