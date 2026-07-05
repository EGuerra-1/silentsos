import 'package:flutter/material.dart';
import 'app_text_field.dart';

/// Campo de contrasena con toggle de visibilidad (patron repetido en
/// Login, Registro paso 1 y Reset Password).
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        tooltip: _obscure ? 'Mostrar contrasena' : 'Ocultar contrasena',
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
