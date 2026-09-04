// lib/ui/screens/widgets/widget_previews.dart
// Aura — Realistic home-screen mock-ups for each widget type. Shared by the
// gallery cards and the live preview in the customization sheet.

import 'package:flutter/material.dart';

import '../../../services/widget_service.dart';
import '../../theme/design_tokens.dart';

/// A "Daily Mix" option (name + colour) used by the Daily Mix Hub widget.
class MixOption {
  const MixOption(this.id, this.name, this.color);
  final String id;
  final String name;
  final Color color;
}

const List<MixOption> kMixOptions = [
  MixOption('mix_focus', 'Focus Flow', Color(0xFF6DD5FF)),
  MixOption('mix_chill', 'Evening Chill', Color(0xFFA78BFA)),
  MixOption('mix_energy', 'High Energy', Color(0xFFFF8F6D)),
  MixOption('mix_throwback', 'Throwback', Color(0xFFFFD36E)),
  MixOption('mix_jazz', 'Late Night Jazz', Color(0xFF64748B)),
  MixOption('mix_indie', 'Indie Mix', Color(0xFF4ADE80)),
];

/// Renders the realistic content of a widget for [type] given a [config] map.
/// Designed to fill whatever box the caller gives it.
class WidgetPreview extends StatelessWidget {
  const WidgetPreview({
    super.key,
    required this.type,
    this.config = const {},
  });

  final HomeWidgetType type;
  final Map<String, Object?> config;

  T _get<T>(String key, T fallback) {
    final v = config[key];
    return v is T ? v : fallback;
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case HomeWidgetType.miniPlayer:
        return _miniPlayer();
      case HomeWidgetType.dailyMixHub:
        return _dailyMixHub();
      case HomeWidgetType.listeningStats:
        return _listeningStats();
      case HomeWidgetType.smartStack:
        return _smartStack();
    }
  }

  // 4×1 frosted pill: artwork, title, play button.
  Widget _miniPlayer() {
    final showArtwork = _get<bool>('showArtwork', true);
    final opacity = _get<double>('backgroundOpacity', 0.6);
    return _Frost(
      opacity: opacity,
      child: Row(
        children: [
          if (showArtwork) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radius8,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DesignTokens.primarySeed, DesignTokens.accentSparkle],
                ),
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
          ],
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Borderline',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text('Tame Impala',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: DesignTokens.primarySeed, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.black, size: 22),
          ),
        ],
      ),
    );
  }

  // 2×2 grid of 4 colourful mix tiles.
  Widget _dailyMixHub() {
    final ids = _get<List<String>>('mixes', const [])
        .cast<String>()
        .toList(growable: false);
    final tiles = ids.isEmpty
        ? kMixOptions.take(4).toList()
        : [
            for (final o in kMixOptions)
              if (ids.contains(o.id)) o
          ].take(4).toList();
    final opacity = 1 - _get<double>('transparency', 0.15);
    return _Frost(
      opacity: opacity.clamp(0.2, 1.0),
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final m in _padded(tiles))
            Container(
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radius8,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: m == null
                      ? [Colors.white24, Colors.white10]
                      : [m.color, m.color.withValues(alpha: 0.55)],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(6),
              child: Text(
                m?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  List<MixOption?> _padded(List<MixOption> tiles) {
    final out = <MixOption?>[...tiles];
    while (out.length < 4) {
      out.add(null);
    }
    return out.take(4).toList();
  }

  // 4×2 stats: monospace time + stat pills.
  Widget _listeningStats() {
    final metric = _get<String>('metric', 'Week');
    final showStreak = _get<bool>('showStreak', true);
    return _Frost(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(metric.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('24h 36m',
              style: TextStyle(
                fontFamily: DesignTokens.fontMono,
                fontFamilyFallback: <String>['monospace'],
                color: DesignTokens.primarySeed,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              const _StatPill(label: '312 songs'),
              const _StatPill(label: '18 artists'),
              if (showStreak) const _StatPill(label: '🔥 7 days'),
            ],
          ),
        ],
      ),
    );
  }

  // Rotating Smart Stack (iOS) — represented as stacked cards.
  Widget _smartStack() {
    return _Frost(
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 14,
            right: 4,
            bottom: 22,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radius12,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 6,
            right: 10,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radius12,
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primarySeed.withValues(alpha: 0.9),
                    DesignTokens.accentSparkle.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.black, size: 16),
                      SizedBox(width: 6),
                      Text('Smart Stack',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Spacer(),
                  Text('Rotates through your widgets',
                      style: TextStyle(color: Colors.black87, fontSize: 11)),
                ],
              ),
            ),
          ),
          const Positioned(
            right: 8,
            bottom: 6,
            child: Icon(Icons.sync_rounded, color: Colors.white38, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Translucent "frosted" surface used inside widget mock-ups. Uses opacity
/// (not a BackdropFilter) to respect the one-blur-layer rule.
class _Frost extends StatelessWidget {
  const _Frost({
    required this.child,
    this.opacity = 0.6,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final double opacity;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: opacity.clamp(0.0, 1.0)),
        borderRadius: DesignTokens.radius16,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: DesignTokens.radiusPill,
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}

/// A stylised, blurred "wallpaper" backdrop for gallery cards so widgets look
/// like they're sitting on a home screen.
class WallpaperBackdrop extends StatelessWidget {
  const WallpaperBackdrop({super.key, required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final palettes = <List<Color>>[
      [const Color(0xFF3A1C71), const Color(0xFFD76D77), const Color(0xFFFFAF7B)],
      [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)],
      [const Color(0xFF42275A), const Color(0xFF734B6D)],
      [const Color(0xFF1A2980), const Color(0xFF26D0CE)],
    ];
    final colors = palettes[seed % palettes.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      // Soft glow blobs to simulate an out-of-focus wallpaper.
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -10,
            child: _Blob(color: Colors.white.withValues(alpha: 0.14), size: 90),
          ),
          Positioned(
            bottom: -30,
            right: -10,
            child: _Blob(
                color: Colors.white.withValues(alpha: 0.10), size: 120),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
