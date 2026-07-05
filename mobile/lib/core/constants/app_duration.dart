import 'package:flutter/animation.dart';

/// Duraciones y curvas de movimiento del design system (motion "ease-out").
abstract final class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration splashIntro = Duration(milliseconds: 900);
  static const Duration splashHold = Duration(milliseconds: 2200);

  // Entrada de contenido y transiciones de pagina.
  static const Duration entrance = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// Retraso entre elementos consecutivos en una entrada escalonada.
  static const Duration stagger = Duration(milliseconds: 70);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}
