import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/playback_state.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../theme/dynamic_theme_provider.dart';
import '../../widgets/glass_card.dart';
import 'queue_sheet.dart';
import 'lyrics_sheet.dart';
import 'sleep_timer_sheet.dart';
import 'audio_dsp_sheet.dart';
import 'cast_device_sheet.dart';

/// Full-screen Now Playing immersive view.
/// Implements Liquid Glass design with a SINGLE BackdropFilter layer for peak graphics performance.
/// Features dynamic accent extraction and thumb-zone ergonomic controls with spring animations.
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  late Animation<double> _favoriteScale;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _favoriteScale = CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    );
    _favoriteController.value = 1.0;
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _favoriteController.forward(from: 0.3);
  }

  String _formatDuration(int ms) {
    if (ms <= 0) return '0:00';
    final seconds = (ms / 1000).truncate();
    final minutes = seconds ~/ 60;
    final remainingSec = seconds % 60;
    return '$minutes:${remainingSec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackStateProvider);
    final themeState = ref.watch(dynamicThemeProvider);
    final track = playback.currentTrack;

    final accent = themeState.accentColor;
    final isPlaying = playback.status == EngineStatus.playing;
    final duration = track?.durationMs ?? 1;
    final position = playback.positionMs.clamp(0, duration);

    return Scaffold(
      body: Stack(
        children: [
          // ── Layer 1: Background Gradient & Single Liquid Glass Blur ────────
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  accent.withValues(alpha: 0.35),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          // Single global blur layer per screen (enforcing peak Impeller/Vulkan performance)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45.0, sigmaY: 45.0),
            child: Container(color: Colors.transparent),
          ),

          // ── Layer 2: Foreground UI Content ──────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
              child: Column(
                children: [
                  const SizedBox(height: DesignTokens.spacing16),
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Minimize player',
                      ),
                      Text(
                        'NOW PLAYING',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.5),
                      ),
                      IconButton(
                        icon: const Icon(Icons.queue_music_rounded),
                        onPressed: () {
                          // Placeholder for queue sheet
                        },
                        tooltip: 'Play queue',
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Hero Album Artwork Glass Card
                  Hero(
                    tag: 'album_art_${track?.id ?? "empty"}',
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GlassCard(
                        borderRadius: DesignTokens.spacing32,
                        enableBlur: false, // Do not stack blurs!
                        padding: EdgeInsets.zero,
                        surfaceColor: accent.withValues(alpha: 0.15),
                        borderColor: accent.withValues(alpha: 0.3),
                        child: Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 120,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Track Title & Favorite Button Row (Strict RenderFlex safety applied)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track?.title ?? 'No Track Loaded',
                              style: Theme.of(context).textTheme.headlineMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track?.artistName ?? 'Select audio from library',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Favorite button with spring micro-interaction
                      Semantics(
                        label: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        child: ScaleTransition(
                          scale: _favoriteScale,
                          child: IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: _isFavorite ? DesignTokens.primarySeed : null,
                              size: 28,
                            ),
                            onPressed: _toggleFavorite,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignTokens.spacing24),

                  // Seek Bar & Timers
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: accent,
                          inactiveTrackColor: Theme.of(context).dividerColor,
                          thumbColor: accent,
                        ),
                        child: Slider(
                          value: position.toDouble(),
                          min: 0,
                          max: duration.toDouble(),
                          onChanged: (val) {
                            // Seek command to orchestrator/engine
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position), style: Theme.of(context).textTheme.bodySmall),
                          Text(_formatDuration(duration), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignTokens.spacing24),

                  // Thumb-Zone Ergonomic Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: playback.isShuffleEnabled ? accent : Theme.of(context).disabledColor,
                        ),
                        onPressed: () {
                          // Toggle shuffle state
                        },
                        tooltip: 'Toggle IntelliShuffle',
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 36),
                        onPressed: () {
                          // Previous track
                        },
                        tooltip: 'Previous track',
                      ),
                      Semantics(
                        label: isPlaying ? 'Pause' : 'Play',
                        child: InkWell(
                          onTap: () {
                            final orchestrator = ref.read(playbackOrchestratorProvider);
                            if (isPlaying) {
                              orchestrator.pause();
                            } else {
                              orchestrator.resume();
                            }
                          },
                          borderRadius: DesignTokens.radiusPill,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 40,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 36),
                        onPressed: () {
                          // Next track
                        },
                        tooltip: 'Next track',
                      ),
                      IconButton(
                        icon: Icon(
                          playback.repeatMode == RepeatMode.one
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          color: playback.repeatMode != RepeatMode.none ? accent : Theme.of(context).disabledColor,
                        ),
                        onPressed: () {
                          // Cycle repeat mode
                        },
                        tooltip: 'Cycle Repeat Mode',
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing24),

                  // Secondary Action Toolbar (Lyrics, Queue, Sleep Timer, Cast, DSP)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.lyrics_outlined),
                        tooltip: 'Synced Lyrics',
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const LyricsSheet(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.queue_music),
                        tooltip: 'Up Next & Queue',
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const QueueSheet(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.nightlight_round_outlined),
                        tooltip: 'Sleep Timer',
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const SleepTimerSheet(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cast),
                        tooltip: 'Audio Output & Cast',
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const CastDeviceSheet(),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune),
                        tooltip: 'Audiophile DSP Parameters',
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AudioDspSheet(),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
