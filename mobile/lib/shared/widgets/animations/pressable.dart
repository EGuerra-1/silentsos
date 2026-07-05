import 'package:flutter/material.dart';
import '../../../core/constants/app_duration.dart';

/// Micro-animacion de escala al presionar para feedback tactil moderno.
///
/// Usa [Listener] para detectar el gesto sin competir en la arena, de modo
/// que puede envolver botones (que manejan su propio onTap) sin duplicarlo.
/// Si se pasa [onTap], tambien actua como elemento tocable (p. ej. tarjetas).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppDuration.fast,
        curve: AppDuration.easeOut,
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: content,
      );
    }
    return content;
  }
}
