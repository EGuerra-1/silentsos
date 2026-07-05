import 'package:flutter/material.dart';
import 'app_color_tokens.dart';
import 'app_theme_extensions.dart';
import 'theme_builder.dart';

/// Tema claro: mapeo directo de los tokens light de Stitch a Material 3.
ThemeData buildLightTheme() {
  const ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColorTokens.primary,
    onPrimary: AppColorTokens.onPrimary,
    primaryContainer: AppColorTokens.primaryContainer,
    onPrimaryContainer: AppColorTokens.onPrimaryContainer,
    secondary: AppColorTokens.secondary,
    onSecondary: AppColorTokens.onSecondary,
    secondaryContainer: AppColorTokens.secondaryContainer,
    onSecondaryContainer: AppColorTokens.onSecondaryContainer,
    tertiary: AppColorTokens.tertiary,
    onTertiary: AppColorTokens.onTertiary,
    tertiaryContainer: AppColorTokens.tertiaryContainer,
    onTertiaryContainer: AppColorTokens.onTertiaryContainer,
    error: AppColorTokens.error,
    onError: AppColorTokens.onError,
    errorContainer: AppColorTokens.errorContainer,
    onErrorContainer: AppColorTokens.onErrorContainer,
    surface: AppColorTokens.surface,
    onSurface: AppColorTokens.onSurface,
    surfaceDim: AppColorTokens.surfaceDim,
    surfaceBright: AppColorTokens.surfaceBright,
    surfaceContainerLowest: AppColorTokens.surfaceContainerLowest,
    surfaceContainerLow: AppColorTokens.surfaceContainerLow,
    surfaceContainer: AppColorTokens.surfaceContainer,
    surfaceContainerHigh: AppColorTokens.surfaceContainerHigh,
    surfaceContainerHighest: AppColorTokens.surfaceContainerHighest,
    onSurfaceVariant: AppColorTokens.onSurfaceVariant,
    outline: AppColorTokens.outline,
    outlineVariant: AppColorTokens.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColorTokens.inverseSurface,
    onInverseSurface: AppColorTokens.inverseOnSurface,
    inversePrimary: AppColorTokens.inversePrimary,
    surfaceTint: AppColorTokens.surfaceTint,
  );

  return buildThemeFromScheme(
    scheme: scheme,
    semantic: const AppSemanticColors(
      success: Color(0xFF10B981),
      successContainer: Color(0xFFD1FAE5),
      warning: Color(0xFFF59E0B),
      danger: AppColorTokens.alertCoral,
      brandGradientStart: AppColorTokens.primaryContainer,
      brandGradientEnd: AppColorTokens.indigoDark,
      inputFill: AppColorTokens.surfaceContainerLowest,
    ),
  );
}
