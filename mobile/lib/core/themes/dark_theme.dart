import 'package:flutter/material.dart';
import 'app_color_tokens.dart';
import 'app_theme_extensions.dart';
import 'theme_builder.dart';

/// Tema oscuro: usa los tokens inverse/fixed definidos por Stitch.
ThemeData buildDarkTheme() {
  const ColorScheme scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColorTokens.inversePrimary,
    // En dark, el CTA principal usa indigo vivo + texto claro.
    onPrimary: AppColorTokens.onPrimary,
    primaryContainer: AppColorTokens.primaryContainer,
    onPrimaryContainer: AppColorTokens.primaryFixed,
    secondary: AppColorTokens.secondaryFixed,
    onSecondary: AppColorTokens.onSecondaryFixed,
    secondaryContainer: AppColorTokens.onSecondaryFixedVariant,
    onSecondaryContainer: AppColorTokens.secondaryFixed,
    tertiary: AppColorTokens.tertiaryFixedDim,
    onTertiary: AppColorTokens.onTertiaryFixed,
    tertiaryContainer: AppColorTokens.onTertiaryFixedVariant,
    onTertiaryContainer: AppColorTokens.tertiaryFixed,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: AppColorTokens.errorContainer,
    surface: Color(0xFF12141A),
    onSurface: Color(0xFFE6E8EA),
    surfaceDim: Color(0xFF101218),
    surfaceBright: Color(0xFF343740),
    surfaceContainerLowest: Color(0xFF0B0D12),
    surfaceContainerLow: Color(0xFF171A22),
    surfaceContainer: Color(0xFF1C1F29),
    surfaceContainerHigh: Color(0xFF272B36),
    surfaceContainerHighest: Color(0xFF323746),
    onSurfaceVariant: Color(0xFFC7C4D8),
    outline: Color(0xFF918FA3),
    outlineVariant: Color(0xFF464555),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE0E3E5),
    onInverseSurface: Color(0xFF2D3133),
    inversePrimary: AppColorTokens.primary,
    surfaceTint: AppColorTokens.inversePrimary,
  );

  return buildThemeFromScheme(
    scheme: scheme,
    semantic: const AppSemanticColors(
      success: Color(0xFF6FFBBE),
      successContainer: Color(0xFF0A3D2A),
      warning: Color(0xFFFFC857),
      danger: Color(0xFFFF8A80),
      brandGradientStart: AppColorTokens.primaryContainer,
      brandGradientEnd: AppColorTokens.indigoDark,
      inputFill: Color(0xFF171A22),
    ),
  );
}
