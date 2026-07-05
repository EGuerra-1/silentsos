import 'package:flutter/material.dart';

/// Colores semanticos que no cubre ColorScheme de Material 3.
/// Se resuelven via Theme para respetar light/dark sin hardcodear.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.danger,
    required this.brandGradientStart,
    required this.brandGradientEnd,
    required this.inputFill,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color danger;
  final Color brandGradientStart;
  final Color brandGradientEnd;
  final Color inputFill;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? danger,
    Color? brandGradientStart,
    Color? brandGradientEnd,
    Color? inputFill,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      brandGradientStart: brandGradientStart ?? this.brandGradientStart,
      brandGradientEnd: brandGradientEnd ?? this.brandGradientEnd,
      inputFill: inputFill ?? this.inputFill,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t) ??
              successContainer,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      brandGradientStart:
          Color.lerp(brandGradientStart, other.brandGradientStart, t) ??
              brandGradientStart,
      brandGradientEnd:
          Color.lerp(brandGradientEnd, other.brandGradientEnd, t) ??
              brandGradientEnd,
      inputFill: Color.lerp(inputFill, other.inputFill, t) ?? inputFill,
    );
  }
}
