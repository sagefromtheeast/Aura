import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';
import 'onboarding_wizard.dart';

/// Animated Splash Screen featuring Liquid Glass aesthetic, ambient depth pulses,
/// and smooth transition into the Onboarding Wizard or main app experience.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingWizard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Semantics(
      label: 'Aura Music Player Splash Screen',
      child: Scaffold(
        body: Stack(
          children: [
            // ── Gradient Background ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF8F6D), // Warm apricot primary seed
                    Color(0xFF4A154B), // Deep resonant violet
                    Color(0xFF0F0D0A), // Dark surface
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // ── Ambient Floating Depth Layers ────────────────────────────────
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Positioned(
                  top: size.height * 0.2 + _floatAnimation.value,
                  left: size.width * 0.15 - _floatAnimation.value,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: DesignTokens.primarySeed.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.primarySeed.withValues(alpha: 0.4),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ── Liquid Glass Overlay (Single Blur Layer Rule) ────────────────
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
              child: Container(
                color: const Color(0xFF0F0D0A).withValues(alpha: 0.35),
              ),
            ),

            // ── Center Content: Logo & Tagline ───────────────────────────────
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  DesignTokens.primarySeed,
                                  DesignTokens.primarySeed.withValues(alpha: 0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: DesignTokens.primarySeed.withValues(alpha: 0.4),
                                  blurRadius: 36,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 68,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: DesignTokens.spacing32),
                    Text(
                      'Aura',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    Text(
                      'The Intelligent Offline Music Player',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(flex: 2),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DesignTokens.primarySeed.withValues(alpha: 0.8),
                      ),
                      strokeWidth: 2.5,
                    ),
                    const Spacer(),
                    Text(
                      'Zero-Cloud Privacy Enclave · 64-Bit FFI Engine',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontFamily: DesignTokens.fontMono,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
