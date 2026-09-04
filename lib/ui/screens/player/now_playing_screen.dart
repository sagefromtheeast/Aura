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

import 'audio_dsp_sheet.dart';
import 'cast_device_sheet.dart';
import 'track_info_sheet.dart';
import 'sleep_timer_sheet.dart';
import '../../../services/sleep_timer_service.dart';

/// Full-screen Now Playing immersive view.
/// Implements Liquid Glass design with a SINGLE BackdropFilter layer for peak graphics performance.
/// Features dynamic accent extraction and thumb-zone ergonomic controls with spring animations.
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with TickerProviderStateMixin {

  bool _showWaveform = false;

  late AnimationController _playPauseController;
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final track = ref.read(playbackStateProvider).currentTrack;
    if (track == null) return;
    await ref.read(favouriteIdsProvider.notifier).toggle(track.id);
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
    final isFavorite =
        track != null && ref.watch(favouriteIdsProvider).contains(track.id);

    final accent = themeState.accentColor;
    final isPlaying = playback.status == EngineStatus.playing;
    final duration = track?.durationMs ?? 1;
    final position = playback.positionMs.clamp(0, duration);

    // Sync play/pause icon state
    if (isPlaying && _playPauseController.status != AnimationStatus.completed) {
      _playPauseController.forward();
    } else if (!isPlaying && _playPauseController.status != AnimationStatus.dismissed) {
      _playPauseController.reverse();
    }

    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 300) {
              // Swipe down: collapse
              Navigator.of(context).pop();
            } else if (details.primaryVelocity! < -300) {
              // Swipe up: queue
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QueueSheet(),
              );
            }
          }
        },
        child: Stack(
          children: [
          // ── Layer 1: Background Gradient & Single Liquid Glass Blur ────────
          Positioned.fill(
            child: Container(
              color: accent, // Dummy full-bleed album art
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
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
                      Expanded(
                        child: Text(
                          track?.title ?? 'Now Playing',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 22,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const TrackInfoSheet(),
                          );
                        },
                        tooltip: 'Track Info',
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Hero Album Artwork Glass Card
                  Hero(
                    tag: 'album_art_${track?.id ?? "empty"}',
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showWaveform = !_showWaveform;
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: AnimatedBuilder(
                          animation: _entranceController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _fadeAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _rotateAnimation.value,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: GlassCard(
                            borderRadius: DesignTokens.spacing32,
                            enableBlur: false, // Do not stack blurs!
                            padding: EdgeInsets.zero,
                            surfaceColor: accent.withValues(alpha: 0.15),
                            borderColor: accent.withValues(alpha: 0.3),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _showWaveform
                                    ? Icon(
                                        Icons.waves_rounded,
                                        key: const ValueKey('waveform'),
                                        size: 120,
                                        color: accent,
                                      )
                                    : Icon(
                                        Icons.music_note_rounded,
                                        key: const ValueKey('album_art'),
                                        size: 120,
                                        color: accent,
                                      ),
                              ),
                            ),
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
                      SparkleLikeButton(
                        isFavorite: isFavorite,
                        onToggle: _toggleFavorite,
                        accent: accent,
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
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _playPauseController,
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

                  // Secondary Action Toolbar (Queue, Lyrics, Cast, Visualizer)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                        icon: const Icon(Icons.graphic_eq),
                        tooltip: 'Waveform View',
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AudioDspSheet(),
                          );
                        },
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final active =
                              ref.watch(sleepTimerProvider).isActive;
                          return IconButton(
                            icon: Icon(active
                                ? Icons.bedtime_rounded
                                : Icons.bedtime_outlined),
                            color: active ? DesignTokens.primarySeed : null,
                            tooltip: 'Sleep Timer',
                            onPressed: () => SleepTimerSheet.show(context),
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
      ),
    );
  }
}

class SparkleLikeButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final Color accent;

  const SparkleLikeButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    required this.accent,
  });

  @override
  State<SparkleLikeButton> createState() => _SparkleLikeButtonState();
}

class _SparkleLikeButtonState extends State<SparkleLikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(SparkleLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      if (widget.isFavorite) {
        _controller.forward(from: 0.0);
      } else {
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(48, 48),
            painter: _SparklePainter(
              animation: _controller,
              color: widget.accent,
            ),
          ),
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.2).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
                reverseCurve: Curves.easeIn,
              ),
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.0 / 1.2).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: widget.isFavorite ? widget.accent : null,
                  size: 28,
                ),
                onPressed: widget.onToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _SparklePainter({required this.animation, required this.color}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0 || animation.value == 1) return;

    final Paint paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final progress = animation.value;

    // Expand outward and fade out
    final radius = progress * size.width;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    paint.color = color.withValues(alpha: opacity);

    const int numParticles = 12;
    for (int i = 0; i < numParticles; i++) {
      final double angle = (i * 2 * 3.14159) / numParticles;
      final double x = center.dx + radius * 0.8 * _mathCos(angle);
      final double y = center.dy + radius * 0.8 * _mathSin(angle);
      
      // Make every other particle slightly smaller and further
      final bool isOuter = i % 2 == 0;
      final double currentX = isOuter ? x + (radius * 0.2 * _mathCos(angle)) : x;
      final double currentY = isOuter ? y + (radius * 0.2 * _mathSin(angle)) : y;
      
      canvas.drawCircle(Offset(currentX, currentY), isOuter ? 2.5 : 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;

  double _mathCos(double rad) {
    return [1.0, 0.866, 0.5, 0.0, -0.5, -0.866, -1.0, -0.866, -0.5, 0.0, 0.5, 0.866][(rad / (3.14159 / 6)).round() % 12];
  }
  
  double _mathSin(double rad) {
    return [0.0, 0.5, 0.866, 1.0, 0.866, 0.5, 0.0, -0.5, -0.866, -1.0, -0.866, -0.5][(rad / (3.14159 / 6)).round() % 12];
  }
}

