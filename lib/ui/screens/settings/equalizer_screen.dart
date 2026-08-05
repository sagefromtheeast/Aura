import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';

/// 10-Band Parametric Equalizer Screen interface.
/// Communicates directly with the native C++ DSP audio engine via Dart FFI.
class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  final List<String> _frequencies = [
    '32', '64', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'
  ];
  final List<double> _gains = List.filled(10, 0.0);
  bool _eqEnabled = true;

  void _updateBand(int index, double val) {
    setState(() {
      _gains[index] = val;
    });
    // Send updated dB offset to native C++ engine with quality factor (Q=1.0)
    final engine = ref.read(audioEngineFfiProvider);
    engine.setEqBand(index, val, 1.0);
  }

  void _resetEq() {
    setState(() {
      for (int i = 0; i < 10; i++) {
        _gains[i] = 0.0;
      }
    });
    final engine = ref.read(audioEngineFfiProvider);
    for (int i = 0; i < 10; i++) {
      engine.setEqBand(i, 0.0, 1.0);
    }
  }

  void _toggleEq(bool enabled) {
    setState(() => _eqEnabled = enabled);
    final engine = ref.read(audioEngineFfiProvider);
    for (int i = 0; i < 10; i++) {
      engine.setEqBand(i, enabled ? _gains[i] : 0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Row(
                children: [
                  Text('Parametric DSP EQ', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
                  const Spacer(),
                  Switch(
                    value: _eqEnabled,
                    activeThumbColor: DesignTokens.primarySeed,
                    onChanged: _toggleEq,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16),
              child: GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Audiophile 64-Bit Float Engine',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                    ),
                    TextButton.icon(
                      onPressed: _resetEq,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Flat Reset'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Expanded(
              child: Opacity(
                opacity: _eqEnabled ? 1.0 : 0.4,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final gain = _gains[index];
                    return Container(
                      width: 54,
                      margin: const EdgeInsets.only(right: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${gain > 0 ? "+" : ""}${gain.round()}dB',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    activeTrackColor: DesignTokens.primarySeed,
                                    thumbColor: DesignTokens.primarySeed,
                                  ),
                                  child: Slider(
                                    value: gain,
                                    min: -12.0,
                                    max: 12.0,
                                    divisions: 24,
                                    onChanged: _eqEnabled
                                        ? (val) => _updateBand(index, val)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_frequencies[index]}Hz',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
