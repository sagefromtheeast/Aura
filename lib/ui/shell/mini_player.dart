import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'stub_providers.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackStateProvider);
    final theme = Theme.of(context);
    final hasTrack = playbackState.currentTrack != null;

    // We use AnimatedSlide for the slide-up/down entrance/exit.
    // When hasTrack is false, it slides down out of view.
    return AnimatedSlide(
      offset: hasTrack ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: IgnorePointer(
        ignoring: !hasTrack,
        child: GestureDetector(
          onTap: () {
            if (hasTrack) {
              context.push('/now-playing');
            }
          },
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  child: Stack(
                    children: [
                      // Thin progress bar at the top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: playbackState.progress,
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Album Art
                            Hero(
                              tag: 'album_art_${playbackState.currentTrack?.id ?? 'empty'}',
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: theme.colorScheme.primaryContainer,
                                ),
                                child: playbackState.currentTrack?.albumArtUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          playbackState.currentTrack!.albumArtUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.music_note,
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Track Info
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playbackState.currentTrack?.title ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    playbackState.currentTrack?.artist ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Animated waveform icon (stubbed static icon for now)
                            if (playbackState.isPlaying)
                              Icon(
                                Icons.graphic_eq,
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                            const SizedBox(width: 8),
                            // Play/Pause button
                            IconButton(
                              icon: Icon(
                                playbackState.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 32,
                                color: theme.colorScheme.onSurface,
                              ),
                              onPressed: () {
                                // TODO: Toggle playback state
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
