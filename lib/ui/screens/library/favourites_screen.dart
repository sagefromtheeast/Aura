// lib/ui/screens/library/favourites_screen.dart
// Aura — The favourites list.
//
// Backed by MusicRepository.getFavouriteTracks() (rating ≥ kFavouriteRating).
// Toggling a heart anywhere in the app updates this list, because both read
// the same favouriteIds notifier.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../../sheets/track_actions_sheet.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(favouriteTracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.transparent,
      ),
      body: favouritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tracks) {
          if (tracks.isEmpty) {
            return const _EmptyFavourites();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => ref
                            .read(playbackOrchestratorProvider)
                            .playQueue(tracks,
                                name: 'Favourites', source: 'favourites'),
                        style: FilledButton.styleFrom(
                          backgroundColor: DesignTokens.primarySeed,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('Play all (${tracks.length})'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: tracks.length,
                  itemBuilder: (context, i) {
                    final track = tracks[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: DesignTokens.spacing12),
                      child: GlassCard(
                        onTap: () => ref
                            .read(playbackOrchestratorProvider)
                            .playTrack(track),
                        onLongPress: () =>
                            TrackActionsSheet.show(context, track),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded,
                                color: Colors.pinkAccent, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text(track.artistName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded,
                                  size: 22),
                              onPressed: () =>
                                  TrackActionsSheet.show(context, track),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border_rounded,
                size: 56, color: Theme.of(context).disabledColor),
            const SizedBox(height: DesignTokens.spacing16),
            Text(
              'No favourites yet.\nTap the heart on a track to add it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
