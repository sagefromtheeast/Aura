import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/artist.dart';
import '../../../domain/entities/track.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';

/// Global Search Screen providing instant live text filtering across tracks,
/// albums, and artists with category filter chips and Liquid Glass card UI.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Tracks', 'Albums', 'Artists'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(allTracksProvider);
    final albumsAsync = ref.watch(allAlbumsProvider);
    final artistsAsync = ref.watch(allArtistsProvider);

    return Semantics(
      label: 'Global Library Search Screen',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ── Search Input App Bar ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back to library',
                    ),
                    const SizedBox(width: DesignTokens.spacing8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                          borderRadius: DesignTokens.radius24,
                          border: Border.all(color: DesignTokens.primarySeed.withValues(alpha: 0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search tracks, albums, artists...',
                            border: InputBorder.none,
                            icon: const Icon(Icons.search_rounded, color: DesignTokens.primarySeed),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 20),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Category Filter Chips ───────────────────────────────────────
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: DesignTokens.spacing8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: DesignTokens.primarySeed.withValues(alpha: 0.25),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: DesignTokens.spacing12),

              // ── Search Results List ─────────────────────────────────────────
              Expanded(
                child: _query.isEmpty
                    ? _buildEmptyState(context)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        children: [
                          if (_selectedCategory == 'All' || _selectedCategory == 'Tracks')
                            ..._buildTrackResults(tracksAsync),
                          if (_selectedCategory == 'All' || _selectedCategory == 'Albums')
                            ..._buildAlbumResults(albumsAsync),
                          if (_selectedCategory == 'All' || _selectedCategory == 'Artists')
                            ..._buildArtistResults(artistsAsync),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded, size: 72, color: Theme.of(context).disabledColor),
          const SizedBox(height: DesignTokens.spacing16),
          Text(
            'Explore your offline music library',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Search across ID3 tags, FLAC headers, and album clusters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTrackResults(AsyncValue<List<Track>> tracksAsync) {
    return tracksAsync.maybeWhen(
      data: (tracks) {
        final filtered = tracks.where((t) => t.title.toLowerCase().contains(_query) || t.artistName.toLowerCase().contains(_query)).toList();
        if (filtered.isEmpty) return const [SizedBox.shrink()];
        return [
          _buildSectionHeader('Tracks (${filtered.length})'),
          ...filtered.map((track) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
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
                            Text(track.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(track.artistName, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_arrow_rounded, color: DesignTokens.primarySeed),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: DesignTokens.spacing16),
        ];
      },
      orElse: () => const [SizedBox.shrink()],
    );
  }

  List<Widget> _buildAlbumResults(AsyncValue<List<Album>> albumsAsync) {
    return albumsAsync.maybeWhen(
      data: (albums) {
        final filtered = albums.where((a) => a.title.toLowerCase().contains(_query) || a.artistName.toLowerCase().contains(_query)).toList();
        if (filtered.isEmpty) return const [SizedBox.shrink()];
        return [
          _buildSectionHeader('Albums (${filtered.length})'),
          ...filtered.map((album) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
                child: GlassCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => AlbumDetailScreen(album: album)),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.album_rounded, size: 36, color: DesignTokens.primarySeed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(album.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(album.artistName, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: DesignTokens.primarySeed),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: DesignTokens.spacing16),
        ];
      },
      orElse: () => const [SizedBox.shrink()],
    );
  }

  List<Widget> _buildArtistResults(AsyncValue<List<Artist>> artistsAsync) {
    return artistsAsync.maybeWhen(
      data: (artists) {
        final filtered = artists.where((a) => a.name.toLowerCase().contains(_query)).toList();
        if (filtered.isEmpty) return const [SizedBox.shrink()];
        return [
          _buildSectionHeader('Artists (${filtered.length})'),
          ...filtered.map((artist) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
                child: GlassCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ArtistDetailScreen(artist: artist)),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(artist.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: DesignTokens.primarySeed),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: DesignTokens.spacing16),
        ];
      },
      orElse: () => const [SizedBox.shrink()],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DesignTokens.primarySeed,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}
