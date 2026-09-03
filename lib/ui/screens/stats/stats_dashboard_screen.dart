// lib/ui/screens/stats/stats_dashboard_screen.dart
// Aura — "Your Week in Music" stats dashboard.
//
// Renders weekly listening aggregates from [statsProvider]:
//   • Header + date range
//   • Frosted hero card (total time, animated gradient border, glowing chart)
//   • 2×2 stats grid (top artist / song / album / streak)
//   • Horizontal weekly-insight rail
//   • Friendly empty state when there is no data yet
//
// Blur budget: the hero card is the single blurred surface on this screen
// (AGENTS.md "one blur layer per screen").

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/design_tokens.dart';
import '../../widgets/glass_card.dart';
import 'listening_history_screen.dart';
import 'monthly_wrapped_screen.dart';
import 'stats_providers.dart';

class StatsDashboardScreen extends ConsumerWidget {
  const StatsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      body: SafeArea(
        child: stats.hasData
            ? _DashboardContent(stats: stats)
            : const _EmptyState(),
      ),
    );
  }
}

// ── Populated content ─────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.stats});

  final WeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    final secondary = _secondaryColor(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacing16,
        DesignTokens.spacing16,
        DesignTokens.spacing16,
        96, // clearance for the floating MiniPlayer
      ),
      children: [
        // Header
        Text(
          'Your Week in Music',
          style: DesignTokens.displayLarge.copyWith(
            fontSize: 28,
            color: _primaryText(context),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing4),
        Text(
          stats.dateRangeLabel,
          style: DesignTokens.bodyMedium.copyWith(color: secondary),
        ),
        const SizedBox(height: DesignTokens.spacing24),

        // Hero card (the screen's single blur layer)
        _HeroCard(stats: stats),
        const SizedBox(height: DesignTokens.spacing24),

        // 2×2 stat grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: DesignTokens.spacing16,
          crossAxisSpacing: DesignTokens.spacing16,
          childAspectRatio: 1.02,
          children: [
            _TopArtistCard(artist: stats.topArtist),
            _TopSongCard(song: stats.topSong),
            _TopAlbumCard(album: stats.topAlbum),
            _StreakCard(days: stats.streakDays, message: stats.streakMessage),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing24),

        // Weekly insights
        Text(
          'Weekly Insights',
          style: DesignTokens.titleLarge.copyWith(color: _primaryText(context)),
        ),
        const SizedBox(height: DesignTokens.spacing12),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stats.insights.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: DesignTokens.spacing12),
            itemBuilder: (context, i) =>
                _InsightCard(text: stats.insights[i], index: i),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing24),

        // Secondary entry points (replaces the old Stats landing banners)
        _NavBanner(
          icon: Icons.auto_awesome_rounded,
          accent: DesignTokens.accentSparkle,
          title: 'Your February Aura',
          subtitle: 'Relive the month in a swipeable story you can share.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MonthlyWrappedScreen(),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing12),
        _NavBanner(
          icon: Icons.history_rounded,
          accent: DesignTokens.primarySeed,
          title: 'Listening History',
          subtitle: 'Browse your full playback timeline and export logs.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ListeningHistoryScreen(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatefulWidget {
  const _HeroCard({required this.stats});

  final WeeklyStats stats;

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle rotating gradient border sweep.
        final gradient = SweepGradient(
          startAngle: 0,
          endAngle: 6.28318,
          transform: GradientRotation(_controller.value * 6.28318),
          colors: const [
            DesignTokens.primarySeed,
            DesignTokens.accentSparkle,
            Color(0xFF6DD5FF),
            DesignTokens.primarySeed,
          ],
        );
        return Container(
          padding: const EdgeInsets.all(1.4), // border thickness
          decoration: BoxDecoration(
            borderRadius: DesignTokens.radius24,
            gradient: gradient,
          ),
          child: child,
        );
      },
      child: GlassCard(
        enableBlur: true,
        semanticsLabel: 'Total listening time this week',
        padding: const EdgeInsets.all(DesignTokens.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAL LISTENING TIME',
              style: DesignTokens.labelMedium.copyWith(
                color: _secondaryColor(context),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              stats.totalListeningLabel,
              style: const TextStyle(
                fontFamily: DesignTokens.fontMono,
                fontFamilyFallback: <String>['monospace'],
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                color: DesignTokens.primarySeed,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            SizedBox(
              height: 84,
              child: _DailyLineChart(dailyMinutes: stats.dailyMinutes),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glowing daily-listening line chart drawn with fl_chart.
class _DailyLineChart extends StatelessWidget {
  const _DailyLineChart({required this.dailyMinutes});

  final List<double> dailyMinutes;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < dailyMinutes.length; i++)
        FlSpot(i.toDouble(), dailyMinutes[i]),
    ];
    final maxY = (dailyMinutes.isEmpty
            ? 1.0
            : dailyMinutes.reduce((a, b) => a > b ? a : b)) *
        1.2;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY <= 0 ? 1 : maxY,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            barWidth: 3,
            color: DesignTokens.primarySeed,
            dotData: const FlDotData(show: false),
            // The glow: a soft shadow gradient hugging the line.
            shadow: const Shadow(
              color: DesignTokens.primarySeed,
              blurRadius: 12,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DesignTokens.primarySeed.withValues(alpha: 0.35),
                  DesignTokens.primarySeed.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
    );
  }
}

// ── Stat grid cards ───────────────────────────────────────────────────────────

class _TopArtistCard extends StatelessWidget {
  const _TopArtistCard({required this.artist});

  final ArtistStat artist;

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      label: 'TOP ARTIST',
      leading: _CircleAvatarArt(
        assetPath: artist.imageAssetPath,
        initials: artist.initials,
        size: 56,
      ),
      title: artist.name,
      subtitle: '${artist.playCount} plays',
    );
  }
}

class _TopSongCard extends StatelessWidget {
  const _TopSongCard({required this.song});

  final SongStat song;

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      label: 'TOP SONG',
      leading: _AlbumArt(
        assetPath: song.albumArtAssetPath,
        seed: song.title,
        size: 56,
      ),
      title: song.title,
      subtitle: '${song.playCount} plays',
    );
  }
}

class _TopAlbumCard extends StatelessWidget {
  const _TopAlbumCard({required this.album});

  final AlbumStat album;

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      label: 'MOST PLAYED ALBUM',
      leading: _AlbumArt(
        assetPath: album.albumArtAssetPath,
        seed: album.name,
        size: 56,
      ),
      title: album.name,
      subtitle: '${album.playCount} plays',
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days, required this.message});

  final int days;
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      semanticsLabel: 'Listening streak $days days',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LISTENING STREAK',
            style: DesignTokens.labelMedium.copyWith(
              color: _secondaryColor(context),
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: DesignTokens.spacing8),
              Text(
                '$days days',
                style: DesignTokens.headlineMedium.copyWith(
                  color: _primaryText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DesignTokens.caption.copyWith(color: _secondaryColor(context)),
          ),
        ],
      ),
    );
  }
}

/// Shared stat-card scaffold: label, artwork/leading, title, subtitle.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      semanticsLabel: '$label $title, $subtitle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DesignTokens.labelMedium.copyWith(
              color: _secondaryColor(context),
            ),
          ),
          const Spacer(),
          leading,
          const SizedBox(height: DesignTokens.spacing8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DesignTokens.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: _primaryText(context),
            ),
          ),
          Text(
            subtitle,
            style: DesignTokens.bodyMedium.copyWith(
              color: DesignTokens.primarySeed,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insight rail ──────────────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.text, required this.index});

  final String text;
  final int index;

  static const _accents = <Color>[
    DesignTokens.primarySeed,
    DesignTokens.accentSparkle,
    Color(0xFF6DD5FF),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[index % _accents.length];
    return SizedBox(
      width: 240,
      child: GlassCard(
        borderColor: accent.withValues(alpha: 0.35),
        padding: const EdgeInsets.all(DesignTokens.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.insights_rounded, color: accent, size: 22),
            const Spacer(),
            Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: DesignTokens.bodyMedium.copyWith(
                color: _primaryText(context),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Secondary nav banner ──────────────────────────────────────────────────────

class _NavBanner extends StatelessWidget {
  const _NavBanner({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      semanticsLabel: title,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: DesignTokens.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignTokens.titleLarge.copyWith(color: accent),
                ),
                const SizedBox(height: DesignTokens.spacing4),
                Text(
                  subtitle,
                  style: DesignTokens.bodyMedium.copyWith(
                    color: _secondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent),
        ],
      ),
    );
  }
}

// ── Artwork helpers ───────────────────────────────────────────────────────────

/// Rounded album-art thumbnail. Falls back to a deterministic gradient tile.
class _AlbumArt extends StatelessWidget {
  const _AlbumArt({
    required this.seed,
    required this.size,
    this.assetPath,
  });

  final String seed;
  final double size;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(assetPath!, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: _gradientForSeed(seed),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.white70, size: 24),
    );
  }
}

/// Circular artist avatar. Falls back to a gradient circle with initials.
class _CircleAvatarArt extends StatelessWidget {
  const _CircleAvatarArt({
    required this.initials,
    required this.size,
    this.assetPath,
  });

  final String initials;
  final double size;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return CircleAvatar(radius: size / 2, backgroundImage: AssetImage(assetPath!));
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _gradientForSeed(initials),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primarySeed.withValues(alpha: 0.25),
                    DesignTokens.accentSparkle.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: const Icon(
                Icons.graphic_eq_rounded,
                size: 56,
                color: DesignTokens.primarySeed,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Text(
              'No stats yet',
              style: DesignTokens.headlineMedium.copyWith(
                color: _primaryText(context),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              'Play some music to see your stats.',
              textAlign: TextAlign.center,
              style: DesignTokens.bodyLarge.copyWith(
                color: _secondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared colour + gradient utilities ────────────────────────────────────────

Color _primaryText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextPrimary
        : DesignTokens.lightTextPrimary;

Color _secondaryColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? DesignTokens.darkTextSecondary
        : DesignTokens.lightTextSecondary;

/// Deterministic two-stop gradient derived from [seed] so the same artist/album
/// always gets the same placeholder colours.
LinearGradient _gradientForSeed(String seed) {
  final h = seed.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0x7fffffff);
  final hue1 = (h % 360).toDouble();
  final hue2 = ((h ~/ 360) % 360).toDouble();
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      HSLColor.fromAHSL(1, hue1, 0.55, 0.55).toColor(),
      HSLColor.fromAHSL(1, hue2, 0.55, 0.40).toColor(),
    ],
  );
}
