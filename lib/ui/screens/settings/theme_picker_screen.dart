// lib/ui/screens/settings/theme_picker_screen.dart
// Aura — Theme customization. A live Now-Playing preview sits above theme
// swatches, a glass-intensity slider and an accent-colour picker. Changes apply
// immediately through [dynamicThemeProvider].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';
import '../../theme/dynamic_theme_provider.dart';
import '../../widgets/aura_slider.dart';
import '../../widgets/glass_card.dart';
import 'settings_providers.dart';

class ThemePickerScreen extends ConsumerWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsCtrl = ref.read(settingsProvider.notifier);
    final theme = ref.watch(dynamicThemeProvider);
    final themeCtrl = ref.read(dynamicThemeProvider.notifier);

    void selectPreset(ThemePreset p) {
      settingsCtrl.setThemePreset(p);
      themeCtrl.setAccent(p.accent);
      if (p == ThemePreset.amoledDark) {
        themeCtrl.setThemeMode(ThemeMode.dark);
      } else if (p == ThemePreset.pureLight) {
        themeCtrl.setThemeMode(ThemeMode.light);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Customization'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ── Live Now-Playing preview (~40% of screen) ────────────────────
          Expanded(
            flex: 40,
            child: _NowPlayingPreview(
              accent: theme.accentColor,
              // Stored 0–1; this preview works in percent.
              glassIntensity: settings.glassIntensity * 100,
              preset: presetFor(settings),
            ),
          ),
          // ── Controls ─────────────────────────────────────────────────────
          Expanded(
            flex: 60,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text('Theme',
                    style: DesignTokens.titleLarge
                        .copyWith(color: _primary(context))),
                const SizedBox(height: DesignTokens.spacing12),
                Wrap(
                  spacing: DesignTokens.spacing16,
                  runSpacing: DesignTokens.spacing16,
                  children: [
                    for (final p in ThemePreset.values)
                      _ThemeSwatch(
                        preset: p,
                        selected: presetFor(settings) == p,
                        onTap: () => selectPreset(p),
                      ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing24),

                // Glass intensity
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Glass Effect Intensity',
                                style: DesignTokens.titleLarge.copyWith(
                                    fontSize: 16, color: _primary(context))),
                          ),
                          MonoValueLabel(
                            text: '${settings.glassIntensity.round()}',
                            color: theme.accentColor,
                          ),
                        ],
                      ),
                      AuraSliderTheme(
                        accent: theme.accentColor,
                        child: Slider(
                          value: settings.glassIntensity,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          onChanged: settingsCtrl.setGlassIntensity,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing16),

                // Accent colour row
                GlassCard(
                  onTap: () => _openAccentPicker(context, ref),
                  child: Row(
                    children: [
                      Icon(Icons.colorize_rounded,
                          color: theme.accentColor, size: 24),
                      const SizedBox(width: DesignTokens.spacing16),
                      Expanded(
                        child: Text('Accent Color',
                            style: DesignTokens.bodyLarge.copyWith(
                                fontSize: 16, color: _primary(context))),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: theme.accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing8),
                      Icon(Icons.chevron_right_rounded,
                          color: _secondary(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAccentPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AccentPickerSheet(),
    );
  }
}

// ── Live preview ──────────────────────────────────────────────────────────────

class _NowPlayingPreview extends StatelessWidget {
  const _NowPlayingPreview({
    required this.accent,
    required this.glassIntensity,
    required this.preset,
  });

  final Color accent;
  final double glassIntensity;
  final ThemePreset preset;

  @override
  Widget build(BuildContext context) {
    final surfaceAlpha = 0.10 + (glassIntensity / 100) * 0.35;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.35),
            preset == ThemePreset.pureLight
                ? DesignTokens.lightBackground
                : DesignTokens.darkBackground,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Album art
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: DesignTokens.radius24,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: preset.swatch,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.music_note_rounded,
                        color: Colors.white70, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacing16),
              // Frosted control strip whose opacity tracks glass intensity.
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacing12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: surfaceAlpha),
                  borderRadius: DesignTokens.radius16,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Borderline',
                                  style: DesignTokens.titleLarge.copyWith(
                                      fontSize: 16,
                                      color: Colors.white)),
                              Text('Tame Impala',
                                  style: DesignTokens.bodyMedium
                                      .copyWith(color: Colors.white70)),
                            ],
                          ),
                        ),
                        Icon(Icons.favorite_rounded, color: accent, size: 22),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    ClipRRect(
                      borderRadius: DesignTokens.radiusPill,
                      child: LinearProgressIndicator(
                        value: 0.42,
                        minHeight: 4,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.skip_previous_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: DesignTokens.spacing16),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration:
                              BoxDecoration(color: accent, shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.black, size: 28),
                        ),
                        const SizedBox(width: DesignTokens.spacing16),
                        const Icon(Icons.skip_next_rounded,
                            color: Colors.white, size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Theme swatch ──────────────────────────────────────────────────────────────

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: preset.swatch,
                ),
                border: Border.all(
                  color: selected
                      ? DesignTokens.primarySeed
                      : Colors.white.withValues(alpha: 0.2),
                  width: selected ? 3 : 1,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing8),
          Text(
            preset.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: DesignTokens.caption.copyWith(color: _secondary(context)),
          ),
        ],
      ),
    );
  }
}

// ── Accent picker (hue slider) ────────────────────────────────────────────────

class _AccentPickerSheet extends ConsumerStatefulWidget {
  const _AccentPickerSheet();

  @override
  ConsumerState<_AccentPickerSheet> createState() => _AccentPickerSheetState();
}

class _AccentPickerSheetState extends ConsumerState<_AccentPickerSheet> {
  late double _hue;

  static const List<Color> _presets = [
    DesignTokens.primarySeed,
    DesignTokens.accentSparkle,
    Color(0xFF6DD5FF),
    Color(0xFF8E7CFF),
    Color(0xFF4ADE80),
    Color(0xFFFF6B9D),
  ];

  @override
  void initState() {
    super.initState();
    _hue = HSVColor.fromColor(ref.read(dynamicThemeProvider).accentColor).hue;
  }

  @override
  Widget build(BuildContext context) {
    final live = HSVColor.fromAHSV(1, _hue, 0.7, 1).toColor();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accent Color',
                style: DesignTokens.titleLarge.copyWith(color: _primary(context))),
            const SizedBox(height: DesignTokens.spacing16),
            Wrap(
              spacing: DesignTokens.spacing12,
              children: [
                for (final c in _presets)
                  GestureDetector(
                    onTap: () {
                      ref.read(dynamicThemeProvider.notifier).setAccent(c);
                      setState(() => _hue = HSVColor.fromColor(c).hue);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Text('Custom Hue',
                style: DesignTokens.bodyMedium
                    .copyWith(color: _secondary(context))),
            // Hue spectrum track.
            Container(
              height: 14,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radiusPill,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF0000),
                    Color(0xFFFFFF00),
                    Color(0xFF00FF00),
                    Color(0xFF00FFFF),
                    Color(0xFF0000FF),
                    Color(0xFFFF00FF),
                    Color(0xFFFF0000),
                  ],
                ),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                activeTrackColor: live,
                thumbColor: live,
                overlayColor: live.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _hue,
                min: 0,
                max: 360,
                onChanged: (v) {
                  final c = HSVColor.fromAHSV(1, v, 0.7, 1).toColor();
                  setState(() => _hue = v);
                  ref.read(dynamicThemeProvider.notifier).setAccent(c);
                },
              ),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: live,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
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
