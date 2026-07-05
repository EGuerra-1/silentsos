import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

/// Contenedor base de pantalla: SafeArea, padding lateral de 20px (token
/// margin-mobile de Stitch) y ancho maximo para tablets.
class AppPageShell extends StatelessWidget {
  const AppPageShell({
    super.key,
    required this.child,
    this.appBar,
    this.bottomBar,
    this.safeTop = true,
    this.applyPadding = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;

  /// Zona fija inferior (CTA persistente como en Registro paso 2).
  final Widget? bottomBar;
  final bool safeTop;
  final bool applyPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        top: safeTop,
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
            child: Padding(
              padding: applyPadding ? AppSpacing.pagePadding : EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.xs,
                  AppSpacing.marginMobile,
                  AppSpacing.md,
                ),
                child: bottomBar,
              ),
            ),
    );
  }
}
