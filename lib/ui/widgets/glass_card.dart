import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Reusable Liquid Glass custom widget.
/// Encapsulates frosted glass effects (`ClipRRect` + `BackdropFilter` + tinted surface).
/// 
/// IMPORTANT PERFORMANCE NOTE:
/// Enforces the 'one blur layer per screen' rule. [enableBlur] defaults to false
/// so repeated items in scrolling lists or child elements on blurred backgrounds
/// rely on surface opacity rather than expensive multi-layer GPU shader blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableBlur;
  final Color? surfaceColor;
  final Color? borderColor;
  final String? semanticsLabel;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = DesignTokens.spacing24,
    this.padding = const EdgeInsets.all(DesignTokens.spacing16),
    this.margin,
    this.onTap,
    this.enableBlur = false,
    this.surfaceColor,
    this.borderColor,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultSurface = isDark
        ? DesignTokens.darkCardSurface
        : DesignTokens.lightCardSurface;
    final defaultBorder = isDark
        ? DesignTokens.darkBorder
        : DesignTokens.lightBorder;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor ?? defaultSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: 1.0,
        ),
      ),
      child: child,
    );

    // Only inject BackdropFilter if explicitly requested (one blur layer rule)
    if (enableBlur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: content,
      );
    }

    content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    // Explicit Semantics wrapper for accessibility tree compliance
    return Semantics(
      container: true,
      label: semanticsLabel ?? 'Interactive glass surface',
      enabled: onTap != null,
      child: content,
    );
  }
}
