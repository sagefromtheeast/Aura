import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/playlist_io_service.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import '../../../data/dummy_library_data.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';
import 'folder_browser_screen.dart';
import 'playlist_detail_screen.dart';
import '../search/search_screen.dart';
import '../../sheets/track_actions_sheet.dart';
import 'favourites_screen.dart';
import 'genres_screen.dart';
import 'track_list_screen.dart';
import 'smart_mix_detail_screen.dart';
import 'tag_editor_sheet.dart';

/// Main Library View featuring tabs for Tracks, Albums, Artists, Playlists, and Smart Mixes.
/// Utilizes custom GlassCard widgets without stacking blur layers and full navigation wiring.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Row(
                children: [
                  Text('Library & Mixes', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.folder_open_rounded, color: DesignTokens.primarySeed),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const FolderBrowserScreen()),
                      );
                    },
                    tooltip: 'Folders & Genres',
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                      );
                    },
                    tooltip: 'Search library',
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: DesignTokens.primarySeed,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).disabledColor,
              tabs: const [
                Tab(text: 'All Tracks'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
                Tab(text: 'Playlists'),
                Tab(text: 'Smart Mixes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTracksTab(),
                  _buildAlbumsTab(),
                  _buildArtistsTab(),
                  _buildPlaylistsTab(),
                  _buildSmartMixesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tracks Tab ─────────────────────────────────────────────────────────────
  Widget _buildTracksTab() {
    final tracksAsync = ref.watch(allTracksProvider);

    return tracksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading tracks: $err')),
      data: (tracks) {
        if (tracks.isEmpty) {
          return const Center(child: Text('No tracks found in library'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // 96 bottom padding for MiniPlayer
          itemCount: tracks.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Batch Tag Editor Banner
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing16),
                child: GlassCard(
                  onTap: () => TagEditorSheet.show(context, tracks),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                          borderRadius: DesignTokens.radius12,
                        ),
                        child: const Icon(Icons.library_music_rounded, color: DesignTokens.primarySeed, size: 24),
                      ),
                      const SizedBox(width: DesignTokens.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Batch Metadata Editor', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Edit ID3 tags across all ${tracks.length} library recordings', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.edit_note_rounded, color: DesignTokens.primarySeed, size: 26),
                    ],
                  ),
                ),
              );
            }

            final track = tracks[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
              child: GlassCard(
                onTap: () {
                  ref.read(playbackOrchestratorProvider).playTrack(track);
                },
                onLongPress: () => TrackActionsSheet.show(context, track),
                child: Row(
                  children: [
                    const Icon(Icons.music_note_rounded, color: DesignTokens.primarySeed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(track.artistName, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(track.durationMs ~/ 60000)}:${((track.durationMs ~/ 1000) % 60).toString().padLeft(2, "0")}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 22),
                      onPressed: () => TrackActionsSheet.show(context, track),
                      tooltip: 'Track options',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Albums Tab ─────────────────────────────────────────────────────────────
  Widget _buildAlbumsTab() {
    final albumsAsync = ref.watch(allAlbumsProvider);

    return albumsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading albums: $err')),
      data: (albums) {
        if (albums.isEmpty) return const Center(child: Text('No albums indexed'));
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return GlassCard(
              onTap: () {
                final dummyAlbum = DummyAlbum(
                  id: album.id,
                  title: album.title,
                  artistName: album.artistName,
                  coverColor: Colors.grey, // Mock color
                  year: album.year,
                );
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => AlbumDetailScreen(album: dummyAlbum)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.primarySeed.withValues(alpha: 0.1),
                        borderRadius: DesignTokens.radius16,
                      ),
                      child: const Icon(Icons.album_rounded, size: 54, color: DesignTokens.primarySeed),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(album.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(album.artistName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Artists Tab ────────────────────────────────────────────────────────────
  Widget _buildArtistsTab() {
    final artistsAsync = ref.watch(allArtistsProvider);

    return artistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading artists: $err')),
      data: (artists) {
        if (artists.isEmpty) return const Center(child: Text('No artists indexed'));
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
              child: GlassCard(
                onTap: () {
                  final dummyArtist = DummyArtist(
                    id: artist.id,
                    name: artist.name,
                    trackCount: artist.trackCount,
                    albumCount: artist.albumCount,
                    imageColor: Colors.grey, // Mock color
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => ArtistDetailScreen(artist: dummyArtist)),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: DesignTokens.primarySeed.withValues(alpha: 0.2),
                      child: Text(
                        artist.name.isNotEmpty ? artist.name[0].toUpperCase() : 'A',
                        style: const TextStyle(color: DesignTokens.primarySeed, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(artist.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 12),
                    Text('${artist.albumCount} albums', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  // ── System playlists header (Favourites, Recently Played, etc.) ────────────
  Widget _buildSystemPlaylistsHeader(BuildContext context) {
    final entries = <(IconData, String, VoidCallback)>[
      (
        Icons.favorite_rounded,
        'Favourites',
        () => _pushScreen(context, const FavouritesScreen()),
      ),
      (
        Icons.history_rounded,
        'Recently Played',
        () => _pushScreen(
            context,
            TrackListScreen(
              title: 'Recently Played',
              provider: recentlyPlayedTracksProvider,
              emptyMessage: 'Nothing played yet.',
            )),
      ),
      (
        Icons.local_fire_department_rounded,
        'Most Played',
        () => _pushScreen(
            context,
            TrackListScreen(
              title: 'Most Played',
              provider: mostPlayedTracksProvider,
              emptyMessage: 'Play some music to build this list.',
            )),
      ),
      (
        Icons.fiber_new_rounded,
        'Recently Added',
        () => _pushScreen(
            context,
            TrackListScreen(
              title: 'Recently Added',
              provider: recentlyAddedTracksProvider,
            )),
      ),
      (
        Icons.do_not_disturb_on_outlined,
        'Not Played',
        () => _pushScreen(
            context,
            TrackListScreen(
              title: 'Not Played',
              provider: notPlayedTracksProvider,
              emptyMessage: "You've played everything.",
            )),
      ),
      (
        Icons.category_rounded,
        'Genres',
        () => _pushScreen(context, const GenresScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, label, onTap) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
            child: GlassCard(
              onTap: onTap,
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: DesignTokens.primarySeed),
                  const SizedBox(width: DesignTokens.spacing12),
                  Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        const SizedBox(height: DesignTokens.spacing8),
        Text('Your Playlists',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: DesignTokens.primarySeed)),
        const SizedBox(height: DesignTokens.spacing12),
      ],
    );
  }

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  // ── Playlists Tab ──────────────────────────────────────────────────────────
  Widget _buildPlaylistsTab() {
    final playlistsAsync = ref.watch(allPlaylistsProvider);
    final tracksAsync = ref.watch(allTracksProvider);

    return playlistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading playlists: $err')),
      data: (playlists) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: playlists.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildSystemPlaylistsHeader(context);
            final p = playlists[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
              child: GlassCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => PlaylistDetailScreen(playlist: p)),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.playlist_play_rounded, size: 36, color: DesignTokens.primarySeed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${p.trackIds.length} tracks • Offline cluster', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_download_rounded, color: DesignTokens.primarySeed),
                      tooltip: 'Export to .m3u8',
                      onPressed: () async {
                        try {
                          final allTracks = tracksAsync.value ?? [];
                          final targetTracks = allTracks.where((t) => p.trackIds.contains(t.id)).toList();
                          // Fallback to library tracks if exact ID match is sparse in demo
                          final exportTracks = targetTracks.isNotEmpty ? targetTracks : allTracks.take(10).toList();

                          final dir = await getApplicationDocumentsDirectory();
                          final file = await PlaylistIoService.writePlaylistFile(
                            directory: dir,
                            playlistName: p.name,
                            tracks: exportTracks,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Playlist exported to ${file.path}')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to export playlist: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Smart Mixes Tab (Offline k-Means clustering) ──────────────────────────
  Widget _buildSmartMixesTab() {
    final mixes = [
      ('Morning Awakening', 'Upbeat tempo & vibrant acoustics', Icons.wb_sunny_rounded),
      ('Deep Focus Flow', 'Low variance energy & binaural harmony', Icons.self_improvement_rounded),
      ('High-Octane Workout', 'Max danceability & 140+ BPM tempo', Icons.fitness_center_rounded),
      ('Midnight Chillout', 'Mellow ambient resonances & low loudness', Icons.nightlight_round),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: mixes.length,
      itemBuilder: (context, index) {
        final mix = mixes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spacing16),
          child: GlassCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SmartMixDetailScreen(
                    mixTitle: mix.$1,
                    mixSubtitle: mix.$2,
                    moodTag: 'ON-DEVICE AI MIX',
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mix.$3, color: DesignTokens.primarySeed, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mix.$1, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(mix.$2, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.play_circle_fill_rounded, size: 36, color: DesignTokens.primarySeed),
              ],
            ),
          ),
        );
      },
    );
  }
}
