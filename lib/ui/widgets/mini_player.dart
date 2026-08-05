import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/playback_state.dart';
import '../../shared/providers.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';
import '../screens/player/now_playing_screen.dart';

/// Floating Mini-Player widget displaying current track status above navigation bars.
/// Adheres strictly to RenderFlex overflow prevention rules (Row -> Expanded(Column) -> Text).
class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key});

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPlayPauseTap(PlaybackState playback, bool isPlaying) {
    _pulseController.reverse().then((_) => _pulseController.forward());
    final orchestrator = ref.read(playbackOrchestratorProvider);
    if (isPlaying) {
      orchestrator.pause();
    } else {
      orchestrator.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackStateProvider);
    final track = playback.currentTrack;

    if (track == null || playback.status == EngineStatus.idle) {
      return const SizedBox.shrink();
    }

    final isPlaying = playback.status == EngineStatus.playing;
    final progress = track.durationMs > 0
        ? (playback.positionMs / track.durationMs).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing16,
        vertical: DesignTokens.spacing8,
      ),
      child: Semantics(
        container: true,
        label: 'Mini player, currently playing ${track.title} by ${track.artistName}',
        child: GlassCard(
          borderRadius: 100.0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing16,
            vertical: DesignTokens.spacing8,
          ),
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const NowPlayingScreen(),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Album Art Thumbnail
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DesignTokens.primarySeed.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: DesignTokens.primarySeed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Flexible title column to permanently prevent RenderFlex overflow
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.artistName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Play/Pause Control with micro-animation
                  ScaleTransition(
                    scale: _pulseController,
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => _onPlayPauseTap(playback, isPlaying),
                      tooltip: isPlaying ? 'Pause' : 'Play',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Linear progress indicator across pill base
              ClipRRect(
                borderRadius: DesignTokens.radiusPill,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
