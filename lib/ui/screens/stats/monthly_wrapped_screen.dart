// lib/ui/screens/stats/monthly_wrapped_screen.dart
// Aura — "Monthly Wrapped" full-screen story experience.
//
// A dark, moody, spotlight background hosts a 7-card PageView the user swipes
// through. Cards animate in with slide + fade; numbers count up; soft music
// notes drift in the background. The final card is captured with the
// `screenshot` package and shared through the local OS share sheet
// (share_plus) — no network calls.
//
// Data comes from [wrappedProvider] (stub aggregates, computed locally).

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/design_tokens.dart';
import '../../widgets/count_up_text.dart';
import 'stats_providers.dart';

class MonthlyWrappedScreen extends ConsumerStatefulWidget {
  const MonthlyWrappedScreen({super.key});

  @override
  ConsumerState<MonthlyWrappedScreen> createState() =>
      _MonthlyWrappedScreenState();
}

class _MonthlyWrappedScreenState extends ConsumerState<MonthlyWrappedScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ScreenshotController _shotController = ScreenshotController();
  late final AnimationController _noteController;

  int _currentPage = 0;
  double _page = 0;
  static const int _pageCount = 7;

  @override
  void initState() {
    super.initState();
    _noteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _pageController.addListener(() {
      final p = _pageController.page ?? 0;
      setState(() {
        _page = p;
        _currentPage = p.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(wrappedProvider);

    final pages = <Widget>[
      _IntroCard(data: data),
      _TotalStatsCard(data: data),
      _TopArtistCard(data: data),
      _TopSongCard(data: data),
      _MoodCard(data: data),
      _PersonalityCard(data: data),
      _ShareCard(data: data),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Moody spotlight background.
          const Positioned.fill(child: _SpotlightBackground()),
          // Drifting music notes.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _noteController,
                builder: (context, _) => CustomPaint(
                  painter: _MusicNotesPainter(progress: _noteController.value),
                ),
              ),
            ),
          ),

          // Story cards.
          SafeArea(
            child: Column(
              children: [
                // Top bar: progress dots + close.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacing16,
                    DesignTokens.spacing12,
                    DesignTokens.spacing8,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProgressDots(
                          count: _pageCount,
                          current: _currentPage,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white70),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageCount,
                    itemBuilder: (context, index) {
                      // Per-page slide + fade based on distance from center.
                      final delta = (index - _page);
                      final opacity = (1 - delta.abs()).clamp(0.0, 1.0);
                      final dy = delta * 40;
                      // The last card is the capture target.
                      final child = index == _pageCount - 1
                          ? Screenshot(
                              controller: _shotController,
                              child: pages[index],
                            )
                          : pages[index];
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        ),
                      );
                    },
                  ),
                ),
                // Share button.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spacing24,
                    DesignTokens.spacing8,
                    DesignTokens.spacing24,
                    DesignTokens.spacing24,
                  ),
                  child: _ShareButton(onPressed: () => _openShareSheet(data)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Capture + share ─────────────────────────────────────────────────────────

  Future<File?> _captureShareCard(MonthlyWrapped data) async {
    // Capture the share card off-screen so it renders regardless of the
    // currently visible page.
    final bytes = await _shotController.captureFromWidget(
      MediaQuery(
        data: MediaQuery.of(context),
        child: Directionality(
          textDirection: Directionality.of(context),
          child: SizedBox(
            width: 1080,
            height: 1920,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.black),
              child: _ShareCard(data: data),
            ),
          ),
        ),
      ),
      delay: const Duration(milliseconds: 20),
      pixelRatio: 1,
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/aura_wrapped_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _openShareSheet(MonthlyWrapped data) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: DesignTokens.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: DesignTokens.spacing12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: DesignTokens.spacing16),
              _SheetAction(
                icon: Icons.download_rounded,
                label: 'Save Image',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final file = await _captureShareCard(data);
                  if (!mounted || file == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved to ${file.path}')),
                  );
                },
              ),
              _SheetAction(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Clipboard.setData(
                    ClipboardData(text: _shareSummaryText(data)),
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Summary copied to clipboard')),
                  );
                },
              ),
              _SheetAction(
                icon: Icons.ios_share_rounded,
                label: 'More',
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final file = await _captureShareCard(data);
                  if (file == null) return;
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: _shareSummaryText(data),
                  );
                },
              ),
              const SizedBox(height: DesignTokens.spacing8),
            ],
          ),
        );
      },
    );
  }

  String _shareSummaryText(MonthlyWrapped data) {
    return 'My ${data.monthLabel} Aura 🎧\n'
        '${data.totalSongs} songs • Top artist: ${data.topArtist.name}\n'
        'Mood: ${data.moodLabel} • ${data.personalityBadge} ${data.personalityEmoji}';
  }
}

// ── Story cards ───────────────────────────────────────────────────────────────

/// Shared vertical layout for a story card.
class _StoryScaffold extends StatelessWidget {
  const _StoryScaffold({required this.children, this.crossAxis});

  final List<Widget> children;
  final CrossAxisAlignment? crossAxis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing32,
        vertical: DesignTokens.spacing24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAxis ?? CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.data});

  final MonthlyWrapped data;

  @override
  Widget build(BuildContext context) {
    return _StoryScaffold(
      crossAxis: CrossAxisAlignment.center,
      children: [
        const _GlowingAura(),
        const SizedBox(height: DesignTokens.spacing48),
        Text(
          'Your ${data.monthLabel} Aura',
          textAlign: TextAlign.center,
          style: DesignTokens.displayLarge.copyWith(
            color: Colors.white,
            fontSize: 34,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Text(
          'Swipe to relive your month in sound',
          textAlign: TextAlign.center,
          style: DesignTokens.bodyLarge.copyWith(color: Colors.white60),
        ),
      ],
    );
  }
}

class _TotalStatsCard extends StatelessWidget {
  const _TotalStatsCard({required this.data});

  final MonthlyWrapped data;

  @override
  Widget build(BuildContext context) {
    return _StoryScaffold(
      children: [
        Text(
          'You listened to',
          style: DesignTokens.titleLarge.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: DesignTokens.spacing16),
        CountUpText(
          value: data.totalSongs,
          groupThousands: true,
          duration: const Duration(milliseconds: 1800),
          style: const TextStyle(
            fontFamily: DesignTokens.fontMono,
            fontFamilyFallback: <String>['monospace'],
            fontSize: 72,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            color: DesignTokens.accentSparkle,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          'songs',
          style: DesignTokens.displayLarge.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _TopArtistCard extends StatelessWidget {
  const _TopArtistCard({required this.data});

  final MonthlyWrapped data;

  @override
  Widget build(BuildContext context) {
    return _StoryScaffold(
      crossAxis: CrossAxisAlignment.center,
      children: [
        _SpotlitAvatar(
          initials: data.topArtist.initials,
          assetPath: data.topArtist.imageAssetPath,
        ),
        const SizedBox(height: DesignTokens.spacing32),
        Text(
          'Your top artist was',
          style: DesignTokens.titleLarge.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          data.topArtist.name,
          textAlign: TextAlign.center,
          style: DesignTokens.displayLarge.copyWith(
            color: Colors.white,
            fontSize: 40,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          '${data.topArtist.playCount} plays this month',
          style: DesignTokens.bodyLarge.copyWith(
            color: DesignTokens.primarySeed,
          ),
        ),
      ],
    );
  }
}

class _TopSongCard extends StatelessWidget {
  const _TopSongCard({required this.data});

  final MonthlyWrapped data;

  @override
  Widget build(BuildContext context) {
    return _StoryScaffold(
      crossAxis: CrossAxisAlignment.center,
      children: [
        _GlowingAlbumArt(seed: data.topSong.title),
        const SizedBox(height: DesignTokens.spacing32),
        Text(
          'On repeat',
          style: DesignTokens.titleLarge.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          data.topSong.title,
          textAlign: TextAlign.center,
          style: DesignTokens.headlineMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: DesignTokens.spacing4),
        Text(
          data.topSong.artist,
          style: DesignTokens.bodyLarge.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          '${data.topSong.playCount} plays',
          style: DesignTokens.bodyLarge.copyWith(
            color: DesignTokens.primarySeed,
          ),
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.data});

  final MonthlyWrapped data;

  @override
  Widget build(BuildContext context) {
    return _StoryScaffold(
      crossAxis: CrossAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(colors: [...data.moodColors, data.moodColors.first]),
            boxShadow: [
              BoxShadow(
                color: data.moodColors.first.withValues(alpha: 0.5),
                blurRadius: 60,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.spacing48),
        Text(
          'Your mood was',
          style: DesignTokens.titleLarge.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: DesignTokens.spacing8),
        Text(
          '“${data.moodLabel}”',
          textAlign: TextAlign.center,
          style: DesignTokens.displayLarge.copyWith(
            color: Colors.white,
            fontSize: 36,
          ),
        ),
      ],
    );
  }
}

class _PersonalityCard extends StatefulWidget {
  const _PersonalityCard({required this.data});

  final MonthlyWrapped data;

  @override
  State<_PersonalityCard> createState() => _PersonalityCardState();
}

class _PersonalityCardState extends State<_PersonalityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final curved = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    return _StoryScaffold(
      crossAxis: CrossAxisAlignment.center,
      children: [
        Text(
          'Your listening personality',
          style: DesignTokens.titleLarge.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: DesignTokens.spacing32),
        ScaleTransition(
          scale: curved,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing24,
              vertical: DesignTokens.spacing20,
            ),
            decoration: BoxDecoration(
              borderRadius: DesignTokens.radius32,
              gradient: const LinearGradient(
                colors: [DesignTokens.primarySeed, DesignTokens.accentSparkle],
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.primarySeed.withValues(alpha: 0.5),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(data.personalityEmoji,
                    style: const TextStyle(fontSize: 56)),
                const SizedBox(height: DesignTokens.spacing8),
                Text(
                  data.personalityBadge,
                  textAlign: TextAlign.center,
                  style: DesignTokens.headlineMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing24),
        FadeTransition(
          opacity: _controller,
          child: Text(
            data.personalityBlurb,
            textAlign: TextAlign.center,
            style: DesignTokens.bodyLarge.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

/// The composed, share-ready summary card (capture target).
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.data});

  final MonthlyWrapped data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(DesignTokens.spacing24),
        padding: const EdgeInsets.all(DesignTokens.spacing24),
        decoration: BoxDecoration(
          borderRadius: DesignTokens.radius32,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignTokens.darkSurface,
              Colors.black,
            ],
          ),
          border: Border.all(
            color: DesignTokens.primarySeed.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: DesignTokens.accentSparkle, size: 22),
                const SizedBox(width: DesignTokens.spacing8),
                Text(
                  'Aura • ${data.monthLabel}',
                  style: DesignTokens.labelMedium.copyWith(
                    color: DesignTokens.accentSparkle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Text(
              '${data.totalSongs} songs',
              style: const TextStyle(
                fontFamily: DesignTokens.fontMono,
                fontFamilyFallback: <String>['monospace'],
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),
            _ShareRow(label: 'Top artist', value: data.topArtist.name),
            _ShareRow(label: 'Top song', value: data.topSong.title),
            _ShareRow(label: 'Mood', value: data.moodLabel),
            _ShareRow(
              label: 'Vibe',
              value: '${data.personalityBadge} ${data.personalityEmoji}',
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final c in data.moodColors)
                  Expanded(
                    child: Container(
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: DesignTokens.bodyMedium.copyWith(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: DesignTokens.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Decorative pieces ─────────────────────────────────────────────────────────

class _SpotlightBackground extends StatelessWidget {
  const _SpotlightBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.5),
          radius: 1.1,
          colors: [
            Color(0xFF241C17), // warm spotlight glow
            Color(0xFF0F0D0A),
            Colors.black,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

/// Pulsing radial "aura" used on the intro card.
class _GlowingAura extends StatefulWidget {
  const _GlowingAura();

  @override
  State<_GlowingAura> createState() => _GlowingAuraState();
}

class _GlowingAuraState extends State<_GlowingAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final size = 160 + t * 30;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                DesignTokens.accentSparkle,
                DesignTokens.primarySeed,
                Colors.transparent,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primarySeed.withValues(alpha: 0.4 + t * 0.3),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpotlitAvatar extends StatelessWidget {
  const _SpotlitAvatar({required this.initials, this.assetPath});

  final String initials;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 168,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DesignTokens.primarySeed, Color(0xFF6D3BFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.primarySeed.withValues(alpha: 0.55),
            blurRadius: 70,
            spreadRadius: 6,
          ),
        ],
        image: assetPath != null
            ? DecorationImage(image: AssetImage(assetPath!), fit: BoxFit.cover)
            : null,
      ),
      child: assetPath != null
          ? null
          : Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

class _GlowingAlbumArt extends StatelessWidget {
  const _GlowingAlbumArt({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final h = seed.codeUnits.fold<int>(0, (a, c) => (a * 31 + c) & 0x7fffffff);
    final hue = (h % 360).toDouble();
    final base = HSLColor.fromAHSL(1, hue, 0.6, 0.55).toColor();
    return Container(
      width: 200,
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: DesignTokens.radius24,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base,
            HSLColor.fromAHSL(1, (hue + 40) % 360, 0.6, 0.4).toColor(),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.55),
            blurRadius: 60,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 64),
    );
  }
}

// ── Small UI atoms ────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < count; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= current
                    ? DesignTokens.accentSparkle
                    : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.primarySeed,
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          textStyle: DesignTokens.titleLarge,
        ),
        icon: const Icon(Icons.ios_share_rounded),
        label: const Text('Share Your Aura'),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

// ── Background music-note particles ───────────────────────────────────────────

class _MusicNotesPainter extends CustomPainter {
  _MusicNotesPainter({required this.progress});

  final double progress;

  static final _notes = <_Note>[
    for (int i = 0; i < 14; i++)
      _Note(
        x: (i * 0.137) % 1.0,
        speed: 0.5 + (i % 5) * 0.12,
        size: 10.0 + (i % 4) * 5,
        phase: (i * 0.31) % 1.0,
        glyph: i.isEven ? '♪' : '♫',
      ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final n in _notes) {
      final t = (progress * n.speed + n.phase) % 1.0;
      final y = size.height * (1.05 - t); // drift upward
      final x = size.width * n.x + math.sin(t * math.pi * 2) * 12;
      final opacity = (math.sin(t * math.pi)).clamp(0.0, 1.0) * 0.18;
      final tp = TextPainter(
        text: TextSpan(
          text: n.glyph,
          style: TextStyle(
            color: Colors.white.withValues(alpha: opacity),
            fontSize: n.size,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _MusicNotesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Note {
  const _Note({
    required this.x,
    required this.speed,
    required this.size,
    required this.phase,
    required this.glyph,
  });

  final double x;
  final double speed;
  final double size;
  final double phase;
  final String glyph;
}
