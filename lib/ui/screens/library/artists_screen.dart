import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dummy_library_data.dart';
import '../../widgets/glass_card.dart';
import 'artist_detail_screen.dart';
class ArtistsScreen extends ConsumerWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(dummyArtistsProvider);
    final theme = Theme.of(context);

    return artistsAsync.when(
      data: (artists) {
        if (artists.isEmpty) {
          return const Center(child: Text('No artists found.'));
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Shuffle Button Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Shuffle Artists'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),

                // Artist List
                SliverPadding(
                  padding: const EdgeInsets.only(left: 16.0, right: 32.0, bottom: 100.0), // Right padding for sticky index
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final artist = artists[index];
                        final currentLetter = artist.name[0].toUpperCase();
                        final previousLetter = index > 0 ? artists[index - 1].name[0].toUpperCase() : '';
                        final showHeader = currentLetter != previousLetter;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
                                child: Text(
                                  currentLetter,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            _ArtistRow(artist: artist),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                      childCount: artists.length,
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Letter Index on Right Edge
            Positioned(
              right: 8,
              top: 80,
              bottom: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                    .split('')
                    .map((letter) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading artists: $error')),
    );
  }
}

class _ArtistRow extends StatelessWidget {
  final DummyArtist artist;

  const _ArtistRow({required this.artist});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      enableBlur: false, // Save performance on lists
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ArtistDetailScreen(artist: artist)),
        );
      },
      child: Row(
        children: [
          // Circular Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: artist.imageColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white54, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${artist.trackCount} tracks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
