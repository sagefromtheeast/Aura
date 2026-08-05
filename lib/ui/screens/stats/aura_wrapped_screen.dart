import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_tokens.dart';

/// Celebratory Aura Wrapped story experience utilizing immersive paginated slides,
/// acoustic personality profiling, and dynamic Liquid Glass animations.
class AuraWrappedScreen extends ConsumerStatefulWidget {
  const AuraWrappedScreen({super.key});

  @override
  ConsumerState<AuraWrappedScreen> createState() => _AuraWrappedScreenState();
}

class _AuraWrappedScreenState extends ConsumerState<AuraWrappedScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final int _totalSlides = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _totalSlides - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Aura Wrapped Celebratory Story Experience',
      child: Scaffold(
        body: GestureDetector(
          onTapUp: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < width * 0.35) {
              _prevPage();
            } else {
              _nextPage();
            }
          },
          child: Stack(
            children: [
              // ── Dynamic Slide Backgrounds ──────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(_currentIndex),
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // ── Single Blur Layer Overlay ──────────────────────────────────
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.black.withValues(alpha: 0.25)),
              ),

              // ── Page Content ───────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Progress bar indicator row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: List.generate(_totalSlides, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: index <= _currentIndex
                                    ? DesignTokens.primarySeed
                                    : Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: DesignTokens.primarySeed, size: 20),
                              const SizedBox(width: 8),
                              Text('AURA WRAPPED 2026', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    // Slide Views
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (idx) => setState(() => _currentIndex = idx),
                        children: [
                          _buildIntroSlide(),
                          _buildHoursSlide(),
                          _buildTopArtistSlide(),
                          _buildSonicAuraSlide(),
                        ],
                      ),
                    ),

                    // Footer instruction
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        'TAP RIGHT TO CONTINUE · TAP LEFT TO BACK UP',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontFamily: DesignTokens.fontMono,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 1.0,
                            ),
                      ),
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

  List<Color> _getGradientColors(int index) {
    switch (index) {
      case 0:
        return const [Color(0xFFFF8F6D), Color(0xFF4A154B), Color(0xFF0F0D0A)];
      case 1:
        return const [Color(0xFF2A5298), Color(0xFF1E3C72), Color(0xFF0F0D0A)];
      case 2:
        return const [Color(0xFF11998E), Color(0xFF38EF7D), Color(0xFF0F0D0A)];
      case 3:
      default:
        return const [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)];
    }
  }

  Widget _buildIntroSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headphones_rounded, size: 72, color: DesignTokens.primarySeed),
          const SizedBox(height: 32),
          Text(
            'Your Offline Year in High-Res Audio',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'While others streamed compressed bytes from remote servers, your enclave stayed pure, sovereign, and bit-perfect.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL ENCLAVE TIME', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: DesignTokens.primarySeed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(

            '14,820\nMinutes',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'That is 247 hours of uninterrupted, zero-telemetry acoustic immersion. You spent 68% of this time listening to lossless FLAC recordings.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopArtistSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR ACOUSTIC FIXATION', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: DesignTokens.primarySeed, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: DesignTokens.radius24,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignTokens.primarySeed,
                  ),
                  child: const Icon(Icons.person_rounded, size: 44, color: Colors.black),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Artist', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      Text('Ludovico Einaudi', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('342 Plays · 12 Albums', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: DesignTokens.fontMono, color: DesignTokens.primarySeed)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your IntelliShuffle engine prioritized classical harmonic transitions more than any other sonic profile.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSonicAuraSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFF8F6D), Color(0xFF8A2387)],
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF8F6D).withValues(alpha: 0.5), blurRadius: 60, spreadRadius: 10),
              ],
            ),
            child: const Icon(Icons.blur_on_rounded, size: 84, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text('YOUR SONIC AURA IS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 8),
          Text(
            'Warm Amber Vapor',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'High Dynamic Range · Deep Bass Affinity · Nocturnal Tendencies',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: DesignTokens.primarySeed,
                  fontFamily: DesignTokens.fontMono,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
            ),
            icon: const Icon(Icons.share_rounded, size: 20),
            label: const Text('SHARE AURA CARD', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aura Wrapped Card saved to offline album!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
