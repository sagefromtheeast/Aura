// lib/ui/widgets/aura_slider.dart
// Aura — Shared SliderTheme wrapper for consistent slider styling across
// Settings, Equalizer and Shuffle screens. Active track/thumb use the accent
// colour; the thumb is a soft pill.

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Wraps [child] (a [Slider]) in a consistent [SliderTheme].
///
/// Pass [accent] to override the active colour (defaults to the primary seed).
class AuraSliderTheme extends StatelessWidget {
  const AuraSliderTheme({
    super.key,
    required this.child,
    this.accent = DesignTokens.primarySeed,
    this.trackHeight = 6,
    this.thumbRadius = 9,
  });

  final Widget child;
  final Color accent;
  final double trackHeight;
  final double thumbRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: trackHeight,
        trackShape: const RoundedRectSliderTrackShape(),
        activeTrackColor: accent,
        inactiveTrackColor:
            (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
        thumbColor: accent,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
        overlayColor: accent.withValues(alpha: 0.16),
        overlayShape: RoundSliderOverlayShape(overlayRadius: thumbRadius + 8),
        valueIndicatorColor: accent,
        valueIndicatorTextStyle: DesignTokens.labelMedium.copyWith(
          color: Colors.black,
        ),
      ),
      child: child,
    );
  }
}

/// Monospace numeric label used to show slider values (per spec: "Monospace
/// numbers for all values").
class MonoValueLabel extends StatelessWidget {
  const MonoValueLabel({
    super.key,
    required this.text,
    this.color = DesignTokens.primarySeed,
    this.fontSize = 15,
  });

  final String text;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: DesignTokens.fontMono,
        fontFamilyFallback: const <String>['monospace'],
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
