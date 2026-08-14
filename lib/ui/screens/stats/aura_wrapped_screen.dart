// lib/ui/screens/stats/aura_wrapped_screen.dart
// Aura — Celebratory Offline Wrapped Story Experience with RepaintBoundary PNG Export.
// PRD §6.3: Year-in-review story cards with OLED Dark / Dynamic HSL toggle.
// Complies with AGENTS.md "one blur layer per screen" and modal overflow rules.

import 'dart:typed_data';
import 'dart:ui' as ui show ImageByteFormat, ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../theme/design_tokens.dart';

/// Celebratory Aura Wrapped story experience utilizing immersive paginated slides,
/// acoustic personality profiling, and dynamic Liquid Glass animations.
/// Supports OLED Dark and Dynamic HSL Album Splash theme toggle for shareable PNG export.
class AuraWrappedScreen extends ConsumerStatefulWidget {
  const AuraWrappedScreen({super.key});

  @override
  ConsumerState<AuraWrappedScreen> createState() => _AuraWrappedScreenState();
}

enum WrappedTheme { oledDark, dynamicHsl }

class _AuraWrappedScreenState extends ConsumerState<AuraWrappedScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final int _totalSlides = 4;
  WrappedTheme _selectedTheme = WrappedTheme.oledDark;
  bool _isExporting = false;

  /// Global key for RepaintBoundary capture of the final summary card.
  final GlobalKey _exportBoundaryKey = GlobalKey();

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
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Renders the final Sonic Aura card via RepaintBoundary and saves to local PNG file.
  /// Zero-cloud: no network requests — pure local Canvas recording.
  Future<void> _exportWrappedCard() async {
    setState(() => _isExporting = true);
    try {
      final boundary = _exportBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Render boundary not found');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to encode PNG');

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/aura_wrapped_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aura Wrapped card saved to ${file.path}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  /// Returns gradient colors based on current slide index and selected theme.
  List<Color> _getGradientColors(int index) {
    if (_selectedTheme == WrappedTheme.oledDark) {
      switch (index) {
        case 0:
          return const [Color(0xFF1A1A2E), Color(0xFF0F0D0A), Color(0xFF000000)];
        case 1:
          return const [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF000000)];
        case 2:
          return const [Color(0xFF0A1628), Color(0xFF162447), Color(0xFF000000)];
        case 3:
        default:
          return const [Color(0xFF1A0A2E), Color(0xFF0F0D1A), Color(0xFF000000)];
      }
    }

    // Dynamic HSL Album Splash
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
              // ── Dynamic Slide Background ────────────────────────────────────
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

              // ── Single Blur Layer Overlay (AGENTS.md: one blur per screen) ─
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.black.withValues(alpha: 0.25)),
              ),

              // ── Page Content ────────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Progress bar indicator row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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

                    // Top Bar with theme toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: DesignTokens.primarySeed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'AURA WRAPPED 2026',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                          ),
                          const Spacer(),
                          // OLED / HSL theme toggle chip
                          Semantics(
                            label: 'Toggle wrapped card visual theme',
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTheme =
                                      _selectedTheme == WrappedTheme.oledDark
                                          ? WrappedTheme.dynamicHsl
                                          : WrappedTheme.oledDark;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: DesignTokens.radiusPill,
                                  border: Border.all(
                                    color: DesignTokens.primarySeed
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _selectedTheme == WrappedTheme.oledDark
                                          ? Icons.dark_mode_rounded
                                          : Icons.palette_rounded,
                                      size: 14,
                                      color: DesignTokens.primarySeed,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedTheme == WrappedTheme.oledDark
                                          ? 'OLED'
                                          : 'SPLASH',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
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
                        onPageChanged: (idx) =>
                            setState(() => _currentIndex = idx),
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

  // ── Slide 1: Intro ──────────────────────────────────────────────────────────
  Widget _buildIntroSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.headphones_rounded,
              size: 72, color: DesignTokens.primarySeed),
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

  // ── Slide 2: Total Hours ────────────────────────────────────────────────────
  Widget _buildHoursSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL ENCLAVE TIME',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: DesignTokens.primarySeed,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
          ),
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

  // ── Slide 3: Top Artist ─────────────────────────────────────────────────────
  Widget _buildTopArtistSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR ACOUSTIC FIXATION',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: DesignTokens.primarySeed,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: DesignTokens.radius24,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
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
                  child: const Icon(Icons.person_rounded,
                      size: 44, color: Colors.black),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Artist',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70)),
                      Text('Ludovico Einaudi',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                      Text('342 Plays · 12 Albums',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontFamily: DesignTokens.fontMono,
                                color: DesignTokens.primarySeed,
                              )),
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

  // ── Slide 4: Sonic Aura Summary with RepaintBoundary PNG Export ──────────
  Widget _buildSonicAuraSlide() {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Wrap exportable card in RepaintBoundary
          RepaintBoundary(
            key: _exportBoundaryKey,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radius24,
                gradient: LinearGradient(
                  colors: _selectedTheme == WrappedTheme.oledDark
                      ? const [Color(0xFF0A0A0F), Color(0xFF1A0A2E)]
                      : const [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _selectedTheme == WrappedTheme.oledDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_selectedTheme == WrappedTheme.oledDark
                            ? DesignTokens.primarySeed
                            : const Color(0xFFE94057))
                        .withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _selectedTheme == WrappedTheme.oledDark
                            ? const [Color(0xFF7B2FBE), Color(0xFF1A0A2E)]
                            : const [Color(0xFFFF8F6D), Color(0xFF8A2387)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedTheme == WrappedTheme.oledDark
                                  ? const Color(0xFF7B2FBE)
                                  : const Color(0xFFFF8F6D))
                              .withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.blur_on_rounded,
                        size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'YOUR SONIC AURA IS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Warm Amber Vapor',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'High Dynamic Range · Deep Bass · Nocturnal',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: DesignTokens.primarySeed,
                          fontFamily: DesignTokens.fontMono,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AURA WRAPPED 2026 — OFFLINE ENCLAVE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 1.0,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Share / Export button with loading state
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.radius24),
            ),
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt_rounded, size: 20),
            label: Text(
              _isExporting ? 'EXPORTING...' : 'SAVE AURA CARD AS PNG',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _isExporting ? null : _exportWrappedCard,
          ),
        ],
      ),
    );
  }
}
