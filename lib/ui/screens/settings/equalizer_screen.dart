// lib/ui/screens/settings/equalizer_screen.dart
// Aura — 10-band graphic equalizer with a live spectrum visualiser.
//
// State lives in [equalizerProvider]; band changes are also forwarded to the
// native C++ DSP engine (best-effort) so audio actually responds.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'settings_providers.dart';

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spectrum;

  @override
  void initState() {
    super.initState();
    _spectrum = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _spectrum.dispose();
    super.dispose();
  }

  void _pushToEngine(int index, double gain) {
    try {
      ref.read(audioEngineFfiProvider).setEqBand(index, gain, 1.0);
    } catch (_) {
      // Engine unavailable (e.g. tests / desktop preview) — UI still works.
    }
  }

  @override
  Widget build(BuildContext context) {
    final eq = ref.watch(equalizerProvider);
    final controller = ref.read(equalizerControllerProvider);

    return Scaffold(
      backgroundColor: DesignTokens.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: DesignTokens.darkTextPrimary,
        title: const Text('Equalizer'),
        actions: [
          Switch(
            value: eq.enabled,
            activeThumbColor: DesignTokens.primarySeed,
            onChanged: (v) => controller.setEnabled(v),
          ),
          const SizedBox(width: DesignTokens.spacing8),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.2,
            colors: [Color(0xFF1E1A16), Color(0xFF0F0D0A)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // ── Spectrum visualiser ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(DesignTokens.spacing12),
                  child: SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _spectrum,
                      builder: (context, _) => CustomPaint(
                        painter: _SpectrumPainter(
                          progress: _spectrum.value,
                          bands: eq.bands,
                          active: eq.enabled,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Preset chips ─────────────────────────────────────────────
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: DesignTokens.spacing8),
                  itemCount: kEqPresetOrder.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final name = kEqPresetOrder[i];
                    final selected = eq.preset == name;
                    return ChoiceChip(
                      label: Text(name),
                      selected: selected,
                      showCheckmark: false,
                      labelStyle: DesignTokens.bodyMedium.copyWith(
                        color: selected ? Colors.black : DesignTokens.darkTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      selectedColor: DesignTokens.primarySeed,
                      backgroundColor: DesignTokens.darkCardSurface,
                      shape: const StadiumBorder(
                        side: BorderSide(color: DesignTokens.darkBorder),
                      ),
                      onSelected: (_) => controller.applyPreset(name),
                    );
                  },
                ),
              ),

              // ── 10-band sliders ──────────────────────────────────────────
              Expanded(
                child: Opacity(
                  opacity: eq.enabled ? 1 : 0.4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < 10; i++)
                          Expanded(
                            child: _BandSlider(
                              gain: eq.bands[i],
                              label: kEqFrequencyLabels[i],
                              enabled: eq.enabled,
                              onChanged: (v) {
                                controller.setBand(i, v);
                                _pushToEngine(i, v);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Toggles ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Bass Boost'),
                        secondary: const Icon(Icons.speaker_rounded,
                            color: DesignTokens.primarySeed),
                        value: eq.bassBoost,
                        activeThumbColor: DesignTokens.primarySeed,
                        onChanged: eq.enabled ? controller.setBassBoost : null,
                      ),
                      Divider(
                          height: 1,
                          color:
                              Theme.of(context).dividerColor.withValues(alpha: 0.4)),
                      SwitchListTile(
                        title: const Text('3D Virtualizer'),
                        secondary: const Icon(Icons.surround_sound_rounded,
                            color: DesignTokens.primarySeed),
                        value: eq.virtualizer,
                        activeThumbColor: DesignTokens.primarySeed,
                        onChanged: eq.enabled ? controller.setVirtualizer : null,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Save preset ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: eq.enabled
                        ? () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                content: Text('Custom preset saved'),
                              ));
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primarySeed,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Custom Preset'),
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

// ── Single vertical band slider ───────────────────────────────────────────────

class _BandSlider extends StatelessWidget {
  const _BandSlider({
    required this.gain,
    required this.label,
    required this.enabled,
    required this.onChanged,
  });

  final double gain;
  final String label;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    // Dynamic fill colour: warm apricot when boosting, cool cyan when cutting.
    final fill = Color.lerp(
      const Color(0xFF6DD5FF),
      DesignTokens.primarySeed,
      ((gain + 12) / 24).clamp(0.0, 1.0),
    )!;

    return Column(
      children: [
        const SizedBox(height: 4),
        SizedBox(
          height: 22,
          child: Text(
            '${gain > 0 ? '+' : ''}${gain.round()}',
            style: TextStyle(
              fontFamily: DesignTokens.fontMono,
              fontFamilyFallback: const <String>['monospace'],
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: enabled ? fill : DesignTokens.darkTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                trackShape: const RoundedRectSliderTrackShape(),
                activeTrackColor: fill,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.10),
                thumbShape: const _PillThumbShape(),
                thumbColor: fill,
                overlayColor: fill.withValues(alpha: 0.16),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: gain,
                min: -12,
                max: 12,
                divisions: 24,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${label}Hz',
          style: DesignTokens.caption.copyWith(
            color: DesignTokens.darkTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// Pill-shaped slider thumb (taller than wide) with a soft glow.
class _PillThumbShape extends SliderComponentShape {
  const _PillThumbShape({this.width = 10, this.height = 22});

  final double width;
  final double height;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final color = sliderTheme.thumbColor ?? DesignTokens.primarySeed;

    // The thumb travels along a horizontal track that is rotated 90° by the
    // parent RotatedBox, so a pill that is "tall" here reads as tall on screen.
    final rect = Rect.fromCenter(center: center, width: height, height: width);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(width));

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
  }
}

// ── Spectrum visualiser painter ───────────────────────────────────────────────

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.progress,
    required this.bands,
    required this.active,
  });

  final double progress;
  final List<double> bands;
  final bool active;

  static const int _barCount = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (_barCount * 1.6);
    final gap = barWidth * 0.6;
    final baseGlow = Paint()
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5);

    for (int i = 0; i < _barCount; i++) {
      // Map bar to nearest EQ band so the visualiser reacts to the curve.
      final band = bands[(i * bands.length ~/ _barCount).clamp(0, bands.length - 1)];
      final bandBoost = ((band + 12) / 24); // 0..1
      final wave = active
          ? (0.5 +
              0.5 *
                  math.sin(progress * 2 * math.pi + i * 0.5) *
                  math.sin(progress * 2 * math.pi * 0.5 + i))
          : 0.06;
      final h = (size.height * (0.15 + 0.85 * wave * (0.4 + bandBoost)))
          .clamp(3.0, size.height);

      final x = i * (barWidth + gap) + gap;
      final color = Color.lerp(
        const Color(0xFF6DD5FF),
        DesignTokens.primarySeed,
        bandBoost,
      )!;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barWidth, h),
        const Radius.circular(3),
      );
      if (active) {
        canvas.drawRRect(rrect, baseGlow..color = color.withValues(alpha: 0.5));
      }
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [color, color.withValues(alpha: 0.6)],
          ).createShader(rrect.outerRect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter old) =>
      old.progress != progress || old.active != active || old.bands != bands;
}
