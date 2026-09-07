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
      // El alto se fija aqui y no en el tema, para no afectar
      // a los botones de los dialogos.
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
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
