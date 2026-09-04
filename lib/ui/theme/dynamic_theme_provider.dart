import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'design_tokens.dart';

/// Immutable theme state holding current [ThemeMode] and dynamic accent [Color].
class DynamicThemeState {
  final ThemeMode mode;
  final Color accentColor;
  final bool isMaterialYouEnabled;

  const DynamicThemeState({
    this.mode = ThemeMode.dark,
    this.accentColor = DesignTokens.primarySeed,
    this.isMaterialYouEnabled = true,
  });

  DynamicThemeState copyWith({
    ThemeMode? mode,
    Color? accentColor,
    bool? isMaterialYouEnabled,
  }) {
    return DynamicThemeState(
      mode: mode ?? this.mode,
      accentColor: accentColor ?? this.accentColor,
      isMaterialYouEnabled: isMaterialYouEnabled ?? this.isMaterialYouEnabled,
    );
  }
}

/// Controller managing dynamic color extraction via [PaletteGenerator] and
/// platform-adaptive styling between Material You (Android) and Fluid iOS styles.
class DynamicThemeController extends StateNotifier<DynamicThemeState> {
  DynamicThemeController() : super(const DynamicThemeState());

  /// Switch explicit theme mode between system, light, and dark.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Toggle Material You integration on supported platforms.
  void toggleMaterialYou(bool enabled) {
    state = state.copyWith(isMaterialYouEnabled: enabled);
  }

  /// Extract vibrant/dominant accent color from album artwork image provider.
  Future<void> updateAccentFromImage(ImageProvider imageProvider) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 20,
      );
      final accent = palette.vibrantColor?.color ?? 
                     palette.dominantColor?.color ?? 
                     DesignTokens.primarySeed;
      state = state.copyWith(accentColor: accent);
    } catch (_) {
      // Retain previous accent on decoding failure
    }
  }

  /// Explicitly set the accent color (e.g. from the theme picker).
  void setAccent(Color color) {
    state = state.copyWith(accentColor: color);
  }

  /// Reset accent color back to default seed.
  void resetAccent() {
    state = state.copyWith(accentColor: DesignTokens.primarySeed);
  }
}

final dynamicThemeProvider = StateNotifierProvider<DynamicThemeController, DynamicThemeState>((ref) {
  return DynamicThemeController();
});

/// Helper class to construct platform-adaptive [ThemeData] using either
/// dynamic Material You schemes (from dynamic_color) or custom iOS Liquid styling.
class AdaptiveThemeBuilder {
  AdaptiveThemeBuilder._();

  static bool get _useMaterialYou => !kIsWeb && Platform.isAndroid;

  static ThemeData buildLightTheme(Color seed, ColorScheme? dynamicScheme) {
    final scheme = (_useMaterialYou && dynamicScheme != null)
        ? dynamicScheme
        : ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.light,
            surface: DesignTokens.lightBackground,
            primary: seed,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DesignTokens.lightBackground,
      textTheme: _buildTextTheme(DesignTokens.lightTextPrimary, DesignTokens.lightTextSecondary),
      cardTheme: CardThemeData(
        color: DesignTokens.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
      ),
      dividerTheme: const DividerThemeData(color: DesignTokens.lightBorder, thickness: 1),
    );
  }

  static ThemeData buildDarkTheme(Color seed, ColorScheme? dynamicScheme) {
    final scheme = (_useMaterialYou && dynamicScheme != null)
        ? dynamicScheme
        : ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
            surface: DesignTokens.darkBackground,
            primary: seed,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DesignTokens.darkBackground,
      textTheme: _buildTextTheme(DesignTokens.darkTextPrimary, DesignTokens.darkTextSecondary),
      cardTheme: CardThemeData(
        color: DesignTokens.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radius24),
      ),
      dividerTheme: const DividerThemeData(color: DesignTokens.darkBorder, thickness: 1),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: DesignTokens.displayLarge.copyWith(color: primary),
      headlineMedium: DesignTokens.headlineMedium.copyWith(color: primary),
      titleLarge: DesignTokens.titleLarge.copyWith(color: primary),
      bodyLarge: DesignTokens.bodyLarge.copyWith(color: primary),
      bodyMedium: DesignTokens.bodyMedium.copyWith(color: secondary),
      labelMedium: DesignTokens.labelMedium.copyWith(color: primary),
      bodySmall: DesignTokens.caption.copyWith(color: secondary),
    );
  }
}
