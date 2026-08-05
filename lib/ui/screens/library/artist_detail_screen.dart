import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/artist.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/track.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'album_detail_screen.dart';

final _artistTracksProvider = FutureProvider.family<List<Track>, String>((ref, artistId) {
  return ref.watch(musicRepositoryProvider).getTracksByArtist(artistId);
});

final _artistAlbumsProvider = FutureProvider.family<List<Album>, String>((ref, artistName) async {
  final albums = await ref.watch(musicRepositoryProvider).getAllAlbums();
  return albums.where((a) => a.artistName.toLowerCase() == artistName.toLowerCase()).toList();
});

/// Artist Profile Screen presenting discography albums, popular track lists,
/// and acoustic performance summaries.
class ArtistDetailScreen extends ConsumerWidget {
  final Artist artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(_artistTracksProvider(artist.id));
    final albumsAsync = ref.watch(_artistAlbumsProvider(artist.name));

    return Semantics(
      label: 'Artist Profile Screen for ${artist.name}',
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Artist Header Sliver ────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back to artists',
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  artist.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DesignTokens.primarySeed.withValues(alpha: 0.35),
                            const Color(0xFF0F0D0A),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                          border: Border.all(color: DesignTokens.primarySeed, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            artist.name.isNotEmpty ? artist.name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.primarySeed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Artist Info Strip ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing24),
                child: Row(
                  children: [
                    _buildStatChip(context, '${artist.albumCount} Albums'),
                    const SizedBox(width: 12),
                    _buildStatChip(context, '${artist.trackCount} Tracks'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.favorite_border_rounded, color: DesignTokens.primarySeed),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Followed ${artist.name}')),
                        );
                      },
                      tooltip: 'Follow Artist',
                    ),
                  ],
                ),
              ),
            ),

            // ── Albums Discography Section ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'DISCOGRAPHY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: DesignTokens.primarySeed,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: albumsAsync.when(
                  data: (albums) {
                    if (albums.isEmpty) {
                      return Center(
                        child: Text(
                          'No individual album bundles found',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => AlbumDetailScreen(album: album)),
                          ),
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 16, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: DesignTokens.radius16,
                                      color: DesignTokens.primarySeed.withValues(alpha: 0.15),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.album_rounded, size: 56, color: DesignTokens.primarySeed),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  album.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${album.year > 0 ? album.year : "Album"} · ${album.trackCount} Tracks',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading discography: $e')),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: DesignTokens.spacing16)),

            // ── Tracks Section ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'ALL TRACKS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: DesignTokens.primarySeed,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
            ),
            tracksAsync.when(
              data: (tracks) {
                if (tracks.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No audio tracks listed for this artist.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).disabledColor),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = tracks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: GlassCard(
                          onTap: () => ref.read(playbackOrchestratorProvider).playTrack(track),
                          child: Row(
                            children: [
                              const Icon(Icons.music_note_rounded, color: DesignTokens.primarySeed),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(track.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(track.albumTitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const Icon(Icons.play_arrow_rounded, color: DesignTokens.primarySeed),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: tracks.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DesignTokens.primarySeed.withValues(alpha: 0.15),
        borderRadius: DesignTokens.radius16,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: DesignTokens.primarySeed,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
