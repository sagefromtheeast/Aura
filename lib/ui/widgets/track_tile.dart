import 'package:flutter/material.dart';
import '../../data/dummy_library_data.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';
import 'now_playing_indicator.dart';

class TrackTile extends StatelessWidget {
  final DummyTrack track;
  final int index;
  final bool isPlaying;
  final VoidCallback? onTap;

  const TrackTile({
    super.key,
    required this.track,
    required this.index,
    this.isPlaying = false,
    this.onTap,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(track.id),
      background: _buildSwipeBackground(
        color: DesignTokens.primarySeed,
        icon: Icons.queue_music,
        label: 'Queue',
        alignment: Alignment.centerLeft,
        isDark: isDark,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: Colors.pinkAccent,
        icon: Icons.favorite,
        label: 'Like',
        alignment: Alignment.centerRight,
        isDark: isDark,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "${track.title}" to queue')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Liked "${track.title}"')),
          );
        }
        return false; // Don't actually dismiss the tile
      },
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          enableBlur: false, // Performance
          child: Row(
            children: [
              // Track Number or Now Playing Indicator
              SizedBox(
                width: 32,
                child: Center(
                  child: isPlaying
                      ? const NowPlayingIndicator()
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                        color: isPlaying ? theme.colorScheme.primary : null,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artistName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Duration
              const SizedBox(width: 12),
              Text(
                _formatDuration(track.duration),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
