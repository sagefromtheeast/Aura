// lib/ui/screens/notifications/notification_preview_screen.dart
// Aura — Simulated lock-screen notification shown when the user first enables
// notifications ("Daily Mix Ready"). Presentational.

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

class NotificationPreviewScreen extends StatelessWidget {
  const NotificationPreviewScreen({super.key});

  // Collage palette (stand-in for album artwork).
  static const List<Color> _collage = [
    Color(0xFF6DD5FF), Color(0xFFA78BFA), Color(0xFFFF8F6D), Color(0xFFFFD36E),
    Color(0xFF4ADE80), Color(0xFFFF6B9D), Color(0xFF64748B), Color(0xFF22D3EE),
    Color(0xFFF472B6), Color(0xFF38BDF8), Color(0xFFF97316), Color(0xFF8E7CFF),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Album collage.
          GridView.count(
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final c in _collage)
                Container(color: c.withValues(alpha: 0.8)),
            ],
          ),
          // Single blur layer + dark scrim for the "lock screen" feel.
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing24),
              child: Column(
                children: [
                  const Spacer(),
                  // Faux lock-screen clock.
                  Text('9:41',
                      style: DesignTokens.displayLarge
                          .copyWith(color: Colors.white, fontSize: 56)),
                  Text('Monday, February 16',
                      style: DesignTokens.bodyLarge
                          .copyWith(color: Colors.white70)),
                  const SizedBox(height: DesignTokens.spacing32),

                  // Notification card with a soft glow behind it.
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: DesignTokens.radius24,
                      boxShadow: [
                        BoxShadow(
                          color:
                              DesignTokens.primarySeed.withValues(alpha: 0.45),
                          blurRadius: 60,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const _NotificationCard(),
                  ),

                  const SizedBox(height: DesignTokens.spacing24),
                  Text(
                    'You can play directly from the notification without '
                    'opening the app.',
                    textAlign: TextAlign.center,
                    style: DesignTokens.bodyMedium
                        .copyWith(color: Colors.white60),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: DesignTokens.radius24,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Aura logo + sparkle + timestamp.
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: DesignTokens.radius8,
                  gradient: const LinearGradient(
                    colors: [
                      DesignTokens.primarySeed,
                      DesignTokens.accentSparkle
                    ],
                  ),
                ),
                child: const Icon(Icons.graphic_eq_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: DesignTokens.spacing8),
              Text('AURA  ✨',
                  style: DesignTokens.labelMedium
                      .copyWith(color: Colors.white, letterSpacing: 1.2)),
              const Spacer(),
              Text('now',
                  style: DesignTokens.caption
                      .copyWith(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing12),
          Text('Your Evening Chill Mix is Ready',
              style: DesignTokens.titleLarge
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: DesignTokens.spacing4),
          Text('25 tracks · 1 hr 32 min · Featuring Bon Iver, Tycho',
              style: DesignTokens.bodyMedium
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: DesignTokens.spacing16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignTokens.primarySeed,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play'),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.5)),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
