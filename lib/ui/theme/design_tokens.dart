import 'package:flutter/material.dart';

/// Aura Design Tokens & Style Guide
/// Adheres strictly to an 8-point spatial layout grid and the 60-30-10 color rule.
class DesignTokens {
  DesignTokens._();

  // ── 8-Point Spatial Grid ──────────────────────────────────────────────────
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ── Corner Radii ──────────────────────────────────────────────────────────
  static final BorderRadius radius8 = BorderRadius.circular(8.0);
  static final BorderRadius radius16 = BorderRadius.circular(16.0);
  static final BorderRadius radius24 = BorderRadius.circular(24.0);
  static final BorderRadius radius32 = BorderRadius.circular(32.0);
  static final BorderRadius radiusPill = BorderRadius.circular(100.0);

  // ── 60-30-10 Color System ─────────────────────────────────────────────────
  // Primary Seed Accent (10% interactive highlights, warm apricot)
  static const Color primarySeed = Color(0xFFFF8F6D);
  static const Color accentSparkle = Color(0xFFFFD36E);

  // Light Palette
  static const Color lightBackground = Color(0xFFFBF9F6); // 60% surface
  static const Color lightSurface = Color(0xFFF3EFE9);    // 30% container
  static const Color lightCardSurface = Color(0x99ECE8DF); // Liquid glass surface
  static const Color lightTextPrimary = Color(0xFF1C1917);
  static const Color lightTextSecondary = Color(0xFF78716C);
  static const Color lightBorder = Color(0x33000000);

  // Dark Palette (OLED fluid black & warm neutral ash)
  static const Color darkBackground = Color(0xFF0F0D0A);  // 60% surface
  static const Color darkSurface = Color(0xFF1E1A16);     // 30% container
  static const Color darkCardSurface = Color(0x661E1A16); // Liquid glass surface
  static const Color darkTextPrimary = Color(0xFFF5F5F4);
  static const Color darkTextSecondary = Color(0xFFA8A29E);
  static const Color darkBorder = Color(0x22FFFFFF);

  // ── Typography Scale ──────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.2,
  );
}
