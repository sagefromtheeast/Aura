import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class NowPlayingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const NowPlayingIndicator({
    super.key,
    this.color,
    this.size = 14.0,
  });

  @override
  State<NowPlayingIndicator> createState() => _NowPlayingIndicatorState();
}

class _NowPlayingIndicatorState extends State<NowPlayingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? DesignTokens.primarySeed;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AnimatedBar(controller: _controller, color: activeColor, heightFactor: 0.8, offset: 0.0),
          _AnimatedBar(controller: _controller, color: activeColor, heightFactor: 1.0, offset: 0.4),
          _AnimatedBar(controller: _controller, color: activeColor, heightFactor: 0.6, offset: 0.8),
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double heightFactor;
  final double offset;

  const _AnimatedBar({
    required this.controller,
    required this.color,
    required this.heightFactor,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Create an offset sine wave effect
        final progress = (controller.value + offset) % 1.0;
        final wave = sin(progress * pi);
        // Map wave (-1 to 1) to height multiplier (0.3 to 1.0)
        final heightMultiplier = 0.3 + (wave.abs() * 0.7);
        
        return Container(
          width: 3,
          height: 14 * heightFactor * heightMultiplier,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      },
    );
  }
}
