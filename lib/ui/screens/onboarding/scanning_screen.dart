import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';
import 'onboarding_providers.dart';
import 'completion_screen.dart';

class ScanningScreen extends ConsumerStatefulWidget {
  const ScanningScreen({super.key});

  @override
  ConsumerState<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends ConsumerState<ScanningScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _progressController;
  late Timer _typewriterTimer;
  int _textIndex = 0;
  String _currentText = '';
  int _charIndex = 0;
  
  final List<String> _scanMessages = [
    'Initializing local scanner...',
    'Found Tame Impala...',
    'Detecting Jazz...',
    'Analyzing audio fingerprints...',
    'Organizing library...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // matching the 3s stub
    )..forward();

    _startTypewriter();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _rippleController.stop();
    } else if (!_rippleController.isAnimating) {
      _rippleController.repeat();
    }
  }
  
  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_textIndex >= _scanMessages.length) {
        timer.cancel();
        return;
      }
      
      final fullText = _scanMessages[_textIndex];
      if (_charIndex < fullText.length) {
        setState(() {
          _currentText = fullText.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _textIndex++;
              _charIndex = 0;
              _currentText = '';
            });
            _startTypewriter();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _progressController.dispose();
    _typewriterTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanCount = ref.watch(libraryScanProvider);
    
    ref.listen<AsyncValue<int>>(libraryScanProvider, (previous, next) {
      if (next.hasValue && next.value! >= (60 * 41)) { // The max value from the provider
        // Wait a small moment to ensure animation completes before navigating
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder: (context, animation, secondaryAnimation) => const CompletionScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0D0A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Counter
            Text(
              scanCount.when(
                data: (count) => '${count.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]},')} songs detected',
                loading: () => '0 songs detected',
                error: (_, __) => 'Error detecting songs',
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontFamily: DesignTokens.fontMono,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const Spacer(),
            
            // Central Radar
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripples
                  ...List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        // Offset each ripple's progress
                        double progress = (_rippleController.value + (index / 3.0)) % 1.0;
                        return Opacity(
                          opacity: (1.0 - progress) * 0.5,
                          child: Container(
                            width: 100 + (progress * 200),
                            height: 100 + (progress * 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DesignTokens.primarySeed,
                                width: 2.0,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  // Core
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DesignTokens.primarySeed,
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.primarySeed.withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.radar,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Typewriter Text
            Container(
              height: 24,
              alignment: Alignment.center,
              child: Text(
                _currentText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontFamily: DesignTokens.fontMono,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: _progressController.value,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: DesignTokens.primarySeed,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [
                              BoxShadow(
                                color: DesignTokens.primarySeed,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
