import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Main Library View featuring tabs for Tracks, Albums, Artists, Playlists, and Smart Mixes.
/// Utilizes custom GlassCard widgets without stacking blur layers.
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
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () {},
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
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
              child: GlassCard(
                onTap: () {
                  ref.read(playbackOrchestratorProvider).playTrack(track);
                },
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
                    const SizedBox(width: 12),
                    Text(
                      '${(track.durationMs ~/ 60000)}:${((track.durationMs ~/ 1000) % 60).toString().padLeft(2, "0")}',
                      style: Theme.of(context).textTheme.bodySmall,
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
              onTap: () {},
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
                onTap: () {},
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

  // ── Playlists Tab ──────────────────────────────────────────────────────────
  Widget _buildPlaylistsTab() {
    final playlistsAsync = ref.watch(allPlaylistsProvider);

    return playlistsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading playlists: $err')),
      data: (playlists) {
        if (playlists.isEmpty) return const Center(child: Text('No playlists created yet'));
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final p = playlists[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
              child: GlassCard(
                onTap: () {},
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
              // Generate mix via SmartMixGenerator
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
