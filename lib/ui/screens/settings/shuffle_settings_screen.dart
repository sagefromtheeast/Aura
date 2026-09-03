// lib/ui/screens/settings/shuffle_settings_screen.dart
// Aura — IntelliShuffle engine tuning with a live preview of the next tracks.
//
// Reuses the existing `shuffleConfigProvider` (StateProvider<ShuffleConfig>).
// Slider display values are shown in monospace.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/shuffle_config.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/aura_slider.dart';
import '../../widgets/glass_card.dart';

class ShuffleSettingsScreen extends ConsumerWidget {
  const ShuffleSettingsScreen({super.key});

  // Spec "Smart Defaults".
  static const double _defFavourite = 0.40;
  static const double _defRecency = 0.50;
  static const double _defDiscovery = 0.30;
  static const int _defArtistSpacing = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(shuffleConfigProvider);
    final controller = ref.read(shuffleConfigProvider.notifier);

    void update(ShuffleConfig next) => controller.state = next;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliShuffle Engine'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _ShuffleSliderCard(
              icon: Icons.favorite_rounded,
              title: 'Favourite Bias',
              description:
                  'How much do you want your favourites to appear first?',
              value: config.favoriteBias * 100,
              min: 0,
              max: 100,
              divisions: 100,
              display: '${(config.favoriteBias * 100).round()}',
              onChanged: (v) => update(config.copyWith(favoriteBias: v / 100)),
            ),
            _ShuffleSliderCard(
              icon: Icons.history_toggle_off_rounded,
              title: 'Recency Avoidance',
              description: 'Keep recently played tracks away.',
              value: config.recencyStrength * 100,
              min: 0,
              max: 100,
              divisions: 100,
              display: '${(config.recencyStrength * 100).round()}',
              onChanged: (v) =>
                  update(config.copyWith(recencyStrength: v / 100)),
            ),
            _ShuffleSliderCard(
              icon: Icons.explore_rounded,
              title: 'Discovery',
              description: 'How often should unplayed tracks appear?',
              value: config.discoveryFraction * 100,
              min: 0,
              max: 100,
              divisions: 100,
              display: '${(config.discoveryFraction * 100).round()}',
              onChanged: (v) =>
                  update(config.copyWith(discoveryFraction: v / 100)),
            ),
            _ShuffleSliderCard(
              icon: Icons.space_bar_rounded,
              title: 'Artist Spacing',
              description: 'Minimum tracks between same artist.',
              value: config.artistSpacing.toDouble().clamp(0, 5),
              min: 0,
              max: 5,
              divisions: 5,
              display: '${config.artistSpacing}',
              onChanged: (v) =>
                  update(config.copyWith(artistSpacing: v.round())),
            ),

            const SizedBox(height: DesignTokens.spacing8),
            _LivePreview(config: config),

            const SizedBox(height: DesignTokens.spacing8),
            Center(
              child: TextButton.icon(
                onPressed: () => update(
                  config.copyWith(
                    favoriteBias: _defFavourite,
                    recencyStrength: _defRecency,
                    discoveryFraction: _defDiscovery,
                    artistSpacing: _defArtistSpacing,
                  ),
                ),
                icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                label: const Text('Reset to Smart Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShuffleSliderCard extends StatelessWidget {
  const _ShuffleSliderCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DesignTokens.primarySeed, size: 22),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: DesignTokens.titleLarge.copyWith(
                    fontSize: 16,
                    color: _primary(context),
                  ),
                ),
              ),
              MonoValueLabel(text: display, fontSize: 18),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Text(
            description,
            style: DesignTokens.bodyMedium.copyWith(color: _secondary(context)),
          ),
          AuraSliderTheme(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live preview of the next 5 tracks — recomputed whenever [config] changes.
class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.config});

  final ShuffleConfig config;

  // A small deterministic sample pool (stub for the real shuffle queue).
  static const List<(String, String, String)> _pool = [
    ('Redbone', 'Childish Gambino', '★ Favourite'),
    ('Borderline', 'Tame Impala', '★ Favourite'),
    ('Nights', 'Frank Ocean', 'Recent'),
    ('Motion Sickness', 'Phoebe Bridgers', 'New'),
    ('Weird Fishes', 'Radiohead', '★ Favourite'),
    ('Alright', 'Kendrick Lamar', 'Recent'),
    ('Glue', 'beabadoobee', 'New'),
    ('Sunday', 'The Cranberries', 'New'),
    ('Space Song', 'Beach House', '★ Favourite'),
    ('Fade Into You', 'Mazzy Star', 'Recent'),
    ('The Suburbs', 'Arcade Fire', 'New'),
    ('Dreams', 'Fleetwood Mac', '★ Favourite'),
  ];

  List<(String, String, String)> _previewQueue() {
    // Seed derived from the slider positions so preview shifts as they move.
    final seed = (config.favoriteBias * 1000).round() ^
        (config.recencyStrength * 100).round() * 7 ^
        (config.discoveryFraction * 100).round() * 13 ^
        (config.artistSpacing * 31);
    final indices = List<int>.generate(_pool.length, (i) => i);
    // Simple LCG shuffle for determinism without dart:math import churn.
    var s = (seed & 0x7fffffff) + 1;
    for (int i = indices.length - 1; i > 0; i--) {
      s = (1103515245 * s + 12345) & 0x7fffffff;
      final j = s % (i + 1);
      final tmp = indices[i];
      indices[i] = indices[j];
      indices[j] = tmp;
    }
    // Bias toward favourites when favouriteBias is high.
    if (config.favoriteBias > 0.6) {
      indices.sort((a, b) {
        final fa = _pool[a].$3 == '★ Favourite' ? 0 : 1;
        final fb = _pool[b].$3 == '★ Favourite' ? 0 : 1;
        return fa.compareTo(fb);
      });
    }
    return [for (final i in indices.take(5)) _pool[i]];
  }

  @override
  Widget build(BuildContext context) {
    final queue = _previewQueue();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.queue_music_rounded,
                  color: DesignTokens.accentSparkle, size: 22),
              const SizedBox(width: DesignTokens.spacing8),
              Text(
                'Up Next (Live Preview)',
                style: DesignTokens.titleLarge
                    .copyWith(fontSize: 16, color: _primary(context)),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing12),
          for (int i = 0; i < queue.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontMono,
                        fontFamilyFallback: <String>['monospace'],
                        color: DesignTokens.darkTextSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          queue[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DesignTokens.bodyLarge.copyWith(
                            color: _primary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          queue[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DesignTokens.bodyMedium
                              .copyWith(color: _secondary(context)),
                        ),
                      ],
                    ),
                  ),
                  _Tag(label: queue[i].$3),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isFav = label.startsWith('★');
    final color = isFav
        ? DesignTokens.accentSparkle
        : (label == 'New' ? const Color(0xFF6DD5FF) : DesignTokens.darkTextSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: DesignTokens.radiusPill,
      ),
      child: Text(
        label,
        style: DesignTokens.caption.copyWith(color: color),
      ),
    );
  }
}

Color _primary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextPrimary
        : DesignTokens.lightTextPrimary;

Color _secondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextSecondary
        : DesignTokens.lightTextSecondary;
