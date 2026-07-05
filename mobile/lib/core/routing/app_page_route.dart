import 'package:flutter/material.dart';
import '../constants/app_duration.dart';

/// Transicion de pagina unificada: fade + deslizamiento horizontal suave.
/// Da continuidad moderna a toda la navegacion de la app.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: AppDuration.pageTransition,
          reverseTransitionDuration: AppDuration.pageTransition,
          pageBuilder: (BuildContext context, _, __) => builder(context),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: AppDuration.easeOut,
              reverseCurve: AppDuration.easeOut,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
