import 'package:flutter/material.dart';

class HeroAlbumArt extends StatelessWidget {
  final String heroTag;
  final Color dominantColor;
  final double size;

  const HeroAlbumArt({
    super.key,
    required this.heroTag,
    required this.dominantColor,
    this.size = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: dominantColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: dominantColor.withValues(alpha: 0.6),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.music_note,
            size: 80,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }
}
