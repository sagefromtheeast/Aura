// lib/ui/widgets/count_up_text.dart
// Aura — Animated number that counts up from 0 to a target value on mount.
// Used by the Stats Dashboard hero and the Monthly Wrapped story cards.

import 'package:flutter/material.dart';

/// Animates an integer from 0 → [value] once when first built (and again
/// whenever [value] changes). Optionally groups thousands with a separator.
class CountUpText extends StatefulWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1400),
    this.curve = Curves.easeOutCubic,
    this.prefix = '',
    this.suffix = '',
    this.groupThousands = false,
    this.textAlign,
  });

  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String prefix;
  final String suffix;
  final bool groupThousands;
  final TextAlign? textAlign;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = _buildAnimation(0);
    _controller.forward();
  }

  Animation<double> _buildAnimation(double begin) {
    return Tween<double>(begin: begin, end: widget.value.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void didUpdateWidget(covariant CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = _buildAnimation(_animation.value);
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _format(int n) {
    if (!widget.groupThousands) return n.toString();
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final current = _animation.value.round();
        return Text(
          '${widget.prefix}${_format(current)}${widget.suffix}',
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}
