// lib/ui/screens/player/audio_dsp_sheet.dart
// Aura — Audiophile DSP & Binaural Spatial Enhancer Modal Sheet.
// Complies with AGENTS.md vertical overflow rules and Liquid Material guidelines.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// Modal bottom sheet providing deep acoustic equalizer, spatial depth, and crossfeed DSP controls.
class AudioDspSheet extends ConsumerStatefulWidget {
  const AudioDspSheet({super.key});

  @override
  ConsumerState<AudioDspSheet> createState() => _AudioDspSheetState();
}

class _AudioDspSheetState extends ConsumerState<AudioDspSheet> {
  bool _dspMasterEnabled = true;
  double _spatialDepth = 0.6;
  double _bassPunch = 0.4;
  double _vocalClarity = 0.7;
  bool _binauralCrossfeed = true;
  bool _gaplessMode = true;
  bool _bitrateUpsampling = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: DesignTokens.spacing12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: DesignTokens.radius8,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audiophile DSP Engine',
                        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'C++ FFI High-Definition Audio Pipeline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: DesignTokens.primarySeed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _dspMasterEnabled,
                  onChanged: (val) {
                    setState(() => _dspMasterEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? 'DSP Pipeline active' : 'Direct acoustic pass-through enabled')),
                    );
                  },
                  activeThumbColor: DesignTokens.primarySeed,
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing16),
          Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),

          // Scrollable DSP controls
          Flexible(
            child: Opacity(
              opacity: _dspMasterEnabled ? 1.0 : 0.5,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing24,
                  vertical: DesignTokens.spacing16,
                ),
                children: [
                  // Spatial Soundfield Card
                  GlassCard(
                    borderRadius: 16.0,
                    padding: const EdgeInsets.all(DesignTokens.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.spatial_audio_rounded, color: DesignTokens.primarySeed),
                            const SizedBox(width: DesignTokens.spacing12),
                            Expanded(
                              child: Text(
                                '3D Spatial Soundfield Depth',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '${(_spatialDepth * 100).toInt()}%',
                              style: const TextStyle(
                                color: DesignTokens.primarySeed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacing12),
                        Slider(
                          value: _spatialDepth,
                          onChanged: _dspMasterEnabled ? (val) => setState(() => _spatialDepth = val) : null,
                          activeColor: DesignTokens.primarySeed,
                        ),
                        Text(
                          'Simulates wide multi-channel speaker imaging within stereo headphones.',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing16),

                  // Harmonic Tone Enhancers
                  Text(
                    'HARMONIC SHAPING',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing12),
                  GlassCard(
                    borderRadius: 16.0,
                    padding: const EdgeInsets.all(DesignTokens.spacing16),
                    child: Column(
                      children: [
                        _buildSliderRow(
                          context: context,
                          label: 'Sub-Bass Punch (60 Hz)',
                          icon: Icons.speaker_rounded,
                          value: _bassPunch,
                          onChanged: _dspMasterEnabled ? (val) => setState(() => _bassPunch = val) : null,
                        ),
                        const SizedBox(height: DesignTokens.spacing12),
                        Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
                        const SizedBox(height: DesignTokens.spacing12),
                        _buildSliderRow(
                          context: context,
                          label: 'Vocal Presence & Air (3.5 kHz)',
                          icon: Icons.mic_rounded,
                          value: _vocalClarity,
                          onChanged: _dspMasterEnabled ? (val) => setState(() => _vocalClarity = val) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing16),

                  // Advanced Acoustic Toggles
                  Text(
                    'ADVANCED ENGINE ROUTING',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing12),
                  GlassCard(
                    borderRadius: 16.0,
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16, vertical: DesignTokens.spacing8),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          context: context,
                          title: 'Binaural Crossfeed (Headphone Guard)',
                          subtitle: 'Reduces extreme stereo fatigue by naturally mixing low frequencies across channels.',
                          value: _binauralCrossfeed,
                          onChanged: _dspMasterEnabled ? (val) => setState(() => _binauralCrossfeed = val) : null,
                        ),
                        Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
                        _buildSwitchTile(
                          context: context,
                          title: 'Zero-Latency Gapless Playback',
                          subtitle: 'Pre-buffers sequential track headers in C++ ring buffers for seamless album transitions.',
                          value: _gaplessMode,
                          onChanged: _dspMasterEnabled ? (val) => setState(() => _gaplessMode = val) : null,
                        ),
                        Divider(color: colorScheme.onSurface.withValues(alpha: 0.1), height: 1),
                        _buildSwitchTile(
                          context: context,
                          title: '384kHz / 32-bit Floating Upsampling',
                          subtitle: 'Interpolates low-bitrate MP3/AAC streams using high-precision sinc filters.',
                          value: _bitrateUpsampling,
                          onChanged: _dspMasterEnabled ? (val) => setState(() => _bitrateUpsampling = val) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing32),

                  // Reset Defaults button
                  Center(
                    child: TextButton.icon(
                      onPressed: _dspMasterEnabled
                          ? () {
                              setState(() {
                                _spatialDepth = 0.5;
                                _bassPunch = 0.5;
                                _vocalClarity = 0.5;
                                _binauralCrossfeed = true;
                                _gaplessMode = true;
                                _bitrateUpsampling = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('DSP engine calibrated to flat reference profile')),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reset to Flat Reference'),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double>? onChanged,
  }) {
    final theme = Theme.of(context);
    final dbOffset = ((value - 0.5) * 12).toStringAsFixed(1);
    final displayStr = value > 0.5 ? '+$dbOffset dB' : '$dbOffset dB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: DesignTokens.primarySeed),
            const SizedBox(width: DesignTokens.spacing12),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text(
              displayStr,
              style: TextStyle(
                color: value != 0.5 ? DesignTokens.primarySeed : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: DesignTokens.primarySeed,
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spacing12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: DesignTokens.primarySeed,
          ),
        ],
      ),
    );
  }
}
