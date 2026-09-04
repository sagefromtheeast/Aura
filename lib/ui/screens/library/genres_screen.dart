// lib/ui/screens/library/genres_screen.dart
// Aura — Genre browsing.
//
// The genre field has always been on Track and Album; this is the browse
// surface that was missing. A flat list of distinct genres with counts, each
// opening the tracks tagged with it.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'track_list_screen.dart';

class GenresScreen extends ConsumerWidget {
  const GenresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genres'),
        backgroundColor: Colors.transparent,
      ),
      body: genresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (genres) {
          if (genres.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(DesignTokens.spacing32),
                child: Text(
                  'No genres found. Your tracks may not have genre tags.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: genres.length,
            itemBuilder: (context, i) {
              final genre = genres[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing12),
                child: GlassCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TrackListScreen(
                          title: genre.name,
                          leadingIcon: Icons.music_note_rounded,
                          provider: genreTracksProvider(genre.name),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.category_rounded,
                          color: DesignTokens.primarySeed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(genre.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      Text('${genre.trackCount}',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
