import 'package:flutter/widgets.dart';

/// Escala de espaciado del design system de Stitch (grid de 8px).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;

  // Tokens exactos definidos por Stitch.
  static const double touchTargetMin = 56;
  static const double gutter = 16;
  static const double marginMobile = 20;
  static const double marginDesktop = 40;
  static const double stackSm = 8;
  static const double stackMd = 16;
  static const double stackLg = 32;

  /// Ancho maximo de columnas de contenido en flujos por pasos.
  static const double contentMaxWidth = 600;

  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: marginMobile);
}
