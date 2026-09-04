// lib/ui/screens/widgets/widget_customization_sheet.dart
// Aura — Bottom sheet to configure a home-screen widget before adding it.
// Live preview updates as options change; spring curves animate interactions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/widget_service.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/aura_slider.dart';
import 'widget_previews.dart';

class WidgetCustomizationSheet extends ConsumerStatefulWidget {
  const WidgetCustomizationSheet({super.key, required this.type});

  final HomeWidgetType type;

  static Future<void> show(BuildContext context, HomeWidgetType type) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DesignTokens.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => WidgetCustomizationSheet(type: type),
    );
  }

  @override
  ConsumerState<WidgetCustomizationSheet> createState() =>
      _WidgetCustomizationSheetState();
}

class _WidgetCustomizationSheetState
    extends ConsumerState<WidgetCustomizationSheet> {
  // Mini Player
  bool _showArtwork = true;
  double _bgOpacity = 0.6;
  // Daily Mix Hub
  final Set<String> _selectedMixes = {
    kMixOptions[0].id,
    kMixOptions[1].id,
    kMixOptions[2].id,
    kMixOptions[3].id,
  };
  double _transparency = 0.15;
  // Listening Stats
  String _metric = 'Week';
  bool _showStreak = true;

  Map<String, Object?> get _config {
    switch (widget.type) {
      case HomeWidgetType.miniPlayer:
        return {'showArtwork': _showArtwork, 'backgroundOpacity': _bgOpacity};
      case HomeWidgetType.dailyMixHub:
        return {
          'mixes': _selectedMixes.toList(),
          'transparency': _transparency,
        };
      case HomeWidgetType.listeningStats:
        return {'metric': _metric, 'showStreak': _showStreak};
      case HomeWidgetType.smartStack:
        return const {};
    }
  }

  Future<void> _add() async {
    final ok = await ref.read(widgetServiceProvider).addWidget(
          widget.type,
          _config,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok
            ? '${widget.type.label} added to your Home Screen'
            : 'Saved. Add the widget from your Home Screen to finish.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Text('Customize ${widget.type.label}',
                style: DesignTokens.headlineMedium
                    .copyWith(color: Colors.white)),
            const SizedBox(height: DesignTokens.spacing16),

            // Live preview in a glass frame with a faux wallpaper.
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              child: _PreviewFrame(type: widget.type, config: _config),
            ),
            const SizedBox(height: DesignTokens.spacing24),

            Flexible(
              child: SingleChildScrollView(
                child: _buildOptions(),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _add,
                style: FilledButton.styleFrom(
                  backgroundColor: DesignTokens.primarySeed,
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.add_to_home_screen_rounded),
                label: const Text('Add to Home Screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions() {
    switch (widget.type) {
      case HomeWidgetType.miniPlayer:
        return Column(
          children: [
            _ToggleTile(
              label: 'Show Artwork',
              value: _showArtwork,
              onChanged: (v) => setState(() => _showArtwork = v),
            ),
            _SliderTile(
              label: 'Background Opacity',
              value: _bgOpacity,
              display: '${(_bgOpacity * 100).round()}%',
              onChanged: (v) => setState(() => _bgOpacity = v),
            ),
          ],
        );
      case HomeWidgetType.dailyMixHub:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _OptionLabel('Choose up to 4 mixes'),
            const SizedBox(height: DesignTokens.spacing8),
            _MixMultiSelect(
              selected: _selectedMixes,
              onToggle: _toggleMix,
            ),
            const SizedBox(height: DesignTokens.spacing16),
            _SliderTile(
              label: 'Transparency',
              value: _transparency,
              display: '${(_transparency * 100).round()}%',
              onChanged: (v) => setState(() => _transparency = v),
            ),
          ],
        );
      case HomeWidgetType.listeningStats:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _OptionLabel('Metric'),
            const SizedBox(height: DesignTokens.spacing8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Today', label: Text('Today')),
                ButtonSegment(value: 'Week', label: Text('Week')),
                ButtonSegment(value: 'All Time', label: Text('All Time')),
              ],
              selected: {_metric},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _metric = s.first),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            _ToggleTile(
              label: 'Show Streak',
              value: _showStreak,
              onChanged: (v) => setState(() => _showStreak = v),
            ),
          ],
        );
      case HomeWidgetType.smartStack:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Smart Stack rotates through your Aura widgets automatically. '
            'No options to configure.',
            style: TextStyle(color: Colors.white70),
          ),
        );
    }
  }

  void _toggleMix(String id) {
    setState(() {
      if (_selectedMixes.contains(id)) {
        _selectedMixes.remove(id);
      } else {
        if (_selectedMixes.length >= 4) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
                content: Text('You can pick up to 4 mixes')));
          return;
        }
        _selectedMixes.add(id);
      }
    });
  }
}

// ── Preview frame ─────────────────────────────────────────────────────────────

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.type, required this.config});

  final HomeWidgetType type;
  final Map<String, Object?> config;

  @override
  Widget build(BuildContext context) {
    // Mini player is short/wide; others are taller.
    final height = type == HomeWidgetType.miniPlayer ? 92.0 : 168.0;
    return ClipRRect(
      borderRadius: DesignTokens.radius24,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            WallpaperBackdrop(seed: type.index),
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: WidgetPreview(type: type, config: config),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Option atoms ──────────────────────────────────────────────────────────────

class _OptionLabel extends StatelessWidget {
  const _OptionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: DesignTokens.labelMedium.copyWith(
            color: DesignTokens.primarySeed, letterSpacing: 1.2));
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label,
          style: DesignTokens.bodyLarge
              .copyWith(fontSize: 16, color: Colors.white)),
      value: value,
      activeThumbColor: DesignTokens.primarySeed,
      onChanged: onChanged,
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: DesignTokens.bodyLarge
                      .copyWith(fontSize: 16, color: Colors.white)),
            ),
            MonoValueLabel(text: display),
          ],
        ),
        AuraSliderTheme(
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _MixMultiSelect extends StatelessWidget {
  const _MixMultiSelect({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DesignTokens.spacing8,
      runSpacing: DesignTokens.spacing8,
      children: [
        for (final m in kMixOptions)
          _MixChip(
            option: m,
            selected: selected.contains(m.id),
            onTap: () => onToggle(m.id),
          ),
      ],
    );
  }
}

class _MixChip extends StatelessWidget {
  const _MixChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final MixOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Spring pop when toggled.
    return AnimatedScale(
      scale: selected ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? option.color.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: DesignTokens.radiusPill,
            border: Border.all(
              color: selected ? option.color : Colors.white24,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: option.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(option.name,
                  style: DesignTokens.bodyMedium.copyWith(color: Colors.white)),
              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_rounded,
                    color: Colors.white, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
