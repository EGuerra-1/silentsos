import 'package:flutter/material.dart';
import 'animations/pressable.dart';

enum AppButtonVariant { primary, secondary, text }

/// Boton del design system: 56px de alto, radio 16, label 14/600.
/// Estilos base definidos en el Theme; aqui variantes, loading y micro-
/// animacion de escala al presionar para feedback tactil moderno.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    final Widget content = _buildContent(context);

    final Widget button = switch (variant) {
      AppButtonVariant.primary =>
        FilledButton(onPressed: effectiveOnPressed, child: content),
      AppButtonVariant.secondary =>
        OutlinedButton(onPressed: effectiveOnPressed, child: content),
      AppButtonVariant.text =>
        TextButton(onPressed: effectiveOnPressed, child: content),
    };

    final Widget sized =
        isExpanded ? SizedBox(width: double.infinity, child: button) : button;

    // Solo feedback visual: el tap lo maneja el propio boton (evita doble
    // disparo). Se desactiva en variante de texto o estado inhabilitado.
    if (variant == AppButtonVariant.text || effectiveOnPressed == null) {
      return sized;
    }
    return Pressable(child: sized);
  }

  Widget _buildContent(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? const SizedBox(
              key: ValueKey<String>('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _label(),
    );
  }

  Widget _label() {
    if (trailingIcon == null) return Text(label, key: const ValueKey('label'));

    return Row(
      key: const ValueKey<String>('label-icon'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(label),
        const SizedBox(width: 8),
        Icon(trailingIcon, size: 18),
      ],
    );
  }
}
