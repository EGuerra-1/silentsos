import 'package:flutter/material.dart';

/// AppBar del design system: titulo centrado en color de marca, flecha de
/// regreso y barra de progreso inferior opcional (flujos por pasos).
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.progress,
  });

  final String? title;
  final bool showBack;

  /// Progreso 0..1 mostrado como linea inferior (null lo oculta).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack,
      title: title == null ? null : Text(title!),
      bottom: progress == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(value: progress, minHeight: 4),
            ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (progress == null ? 0 : 4));
}
