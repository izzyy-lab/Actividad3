import 'package:flutter/material.dart';

/// Boton principal con indicador de carga integrado.
class AuthButton extends StatelessWidget {
  final String texto;
  final bool cargando;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: cargando ? null : onPressed,
      child: cargando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            )
          : Text(texto),
    );
  }
}
