import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';

/// IntelliShuffle Algorithmic Tuning Sheet enabling audiophile-grade weight
/// adjustments for recency avoidance, favorite bias, discovery fraction, and artist spacing.
class IntelliShuffleSheet extends ConsumerStatefulWidget {
  const IntelliShuffleSheet({super.key});

  /// Open as an overflow-protected modal bottom sheet.
  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const IntelliShuffleSheet(),
    );
  }

  @override
  ConsumerState<IntelliShuffleSheet> createState() => _IntelliShuffleSheetState();
}

class _IntelliShuffleSheetState extends ConsumerState<IntelliShuffleSheet> {
  late double _recencyStrength;
  late double _favoriteBias;
  late double _discoveryFraction;
  late double _artistSpacing;
  bool _smartCrossfade = true;

  @override
  void initState() {
    super.initState();
    final config = ref.read(shuffleConfigProvider);
    _recencyStrength = config.recencyStrength;
    _favoriteBias = config.favoriteBias;
    _discoveryFraction = config.discoveryFraction;
    _artistSpacing = config.artistSpacing.toDouble();
  }

  void _saveTuning() {
    final current = ref.read(shuffleConfigProvider);
    ref.read(shuffleConfigProvider.notifier).state = current.copyWith(
      recencyStrength: _recencyStrength,
      favoriteBias: _favoriteBias,
      discoveryFraction: _discoveryFraction,
      artistSpacing: _artistSpacing.toInt(),
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IntelliShuffle algorithmic weights updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Strict compliance with Modal Bottom Sheet Vertical Overflow Prevention rule
    return Container(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: mediaQuery.viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, size: 30, color: DesignTokens.primarySeed),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IntelliShuffle Engine',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Acoustic Graph & Transition Tuning',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing16),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSlider(
                  'Recency Avoidance (λ Bias)',
                  'How aggressively to avoid recently-played tracks',
                  _recencyStrength,
                  0.0,
                  1.0,
                  20,
                  (v) => setState(() => _recencyStrength = v),
                  isPercent: true,
                ),
                const Divider(height: 24),
                _buildSlider(
                  'Favorite Bias Weighting',
                  'Boost tracks explicitly rated or frequently played',
                  _favoriteBias,
                  0.0,
                  1.0,
                  20,
                  (v) => setState(() => _favoriteBias = v),
                  isPercent: true,
                ),
                const Divider(height: 24),
                _buildSlider(
                  'Discovery Queue Ratio',
                  'Fraction of queue dedicated to tracks played <3 times',
                  _discoveryFraction,
                  0.0,
                  1.0,
                  20,
                  (v) => setState(() => _discoveryFraction = v),
                  isPercent: true,
                ),
                const Divider(height: 24),
                _buildSlider(
                  'Artist Spacing Threshold',
                  'Minimum number of tracks between plays of same artist',
                  _artistSpacing,
                  0.0,
                  10.0,
                  10,
                  (v) => setState(() => _artistSpacing = v),
                  isPercent: false,
                ),
                const Divider(height: 24),

                SwitchListTile(
                  title: const Text('Algorithmic Smart Crossfade', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Calculate fade curves via onset silence detection'),
                  value: _smartCrossfade,
                  activeThumbColor: DesignTokens.primarySeed,
                  onChanged: (val) => setState(() => _smartCrossfade = val),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primarySeed,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
            ),
            icon: const Icon(Icons.auto_awesome_rounded, size: 22),
            label: const Text('APPLY ENGINE TUNING', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _saveTuning,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged, {
    required bool isPercent,
  }) {
    final valueDisplay = isPercent ? '${(value * 100).toInt()}%' : '${value.toInt()} tracks';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Text(
              valueDisplay,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFamily: DesignTokens.fontMono,
                    color: DesignTokens.primarySeed,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor)),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: DesignTokens.primarySeed,
          inactiveColor: DesignTokens.primarySeed.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
