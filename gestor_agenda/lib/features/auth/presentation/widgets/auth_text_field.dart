import 'package:flutter/material.dart';

/// Campo de texto reutilizable en los formularios de autenticacion.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final bool esPassword;
  final TextInputType tipoTeclado;
  final String? Function(String?)? validator;
  final TextInputAction accionTeclado;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icono,
    this.esPassword = false,
    this.tipoTeclado = TextInputType.text,
    this.validator,
    this.accionTeclado = TextInputAction.next,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _oculto = widget.esPassword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _oculto,
        keyboardType: widget.tipoTeclado,
        textInputAction: widget.accionTeclado,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icono),
          suffixIcon: widget.esPassword
              ? IconButton(
                  icon: Icon(_oculto ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _oculto = !_oculto),
                  tooltip: _oculto ? 'Mostrar' : 'Ocultar',
                )
              : null,
        ),
      ),
    );
  }
}
