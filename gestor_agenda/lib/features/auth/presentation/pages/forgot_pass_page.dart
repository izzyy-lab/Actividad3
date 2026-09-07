import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Pantalla de recuperacion de contrasena -- Aprendiz A.
///
/// Trabaja en dos pasos:
///   1. Se solicita el correo y la API genera un token temporal.
///   2. Con ese token se establece la nueva contrasena.
class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _formSolicitud = GlobalKey<FormState>();
  final _formCambio = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _pasoDos = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _aviso(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? AppColors.error : AppColors.completada,
      ),
    );
  }

  Future<void> _solicitar() async {
    if (!_formSolicitud.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final exito = await auth.recuperarPassword(_emailCtrl.text);
    if (!mounted) return;

    if (!exito) {
      _aviso(auth.error ?? 'No se pudo procesar la solicitud', esError: true);
      return;
    }

    // El backend devuelve el token para poder probar el flujo sin correo real.
    final token = auth.tokenRecuperacion;
    setState(() {
      _pasoDos = true;
      if (token != null) _tokenCtrl.text = token;
    });
    _aviso(
      token == null
          ? 'Si el correo esta registrado recibiras un codigo de recuperacion.'
          : 'Codigo de recuperacion generado. Define tu nueva contrasena.',
    );
  }

  Future<void> _cambiar() async {
    if (!_formCambio.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final exito = await auth.cambiarPassword(
      resetToken: _tokenCtrl.text,
      newPassword: _passCtrl.text,
    );
    if (!mounted) return;

    if (exito) {
      _aviso('Contrasena actualizada. Ya puedes iniciar sesion.');
      Navigator.of(context).pop();
    } else {
      _aviso(auth.error ?? 'No se pudo cambiar la contrasena', esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AuthProvider>().cargando;

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contrasena')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _pasoDos
                  ? _construirPasoDos(cargando)
                  : _construirPasoUno(cargando),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirPasoUno(bool cargando) {
    return Form(
      key: _formSolicitud,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, size: 64, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text(
            'Ingresa el correo con el que te registraste y te enviaremos un '
            'codigo para restablecer tu contrasena.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          AuthTextField(
            controller: _emailCtrl,
            label: 'Correo electronico',
            icono: Icons.email_outlined,
            tipoTeclado: TextInputType.emailAddress,
            accionTeclado: TextInputAction.done,
            validator: Validators.email,
          ),
          AuthButton(
            texto: 'Enviar codigo',
            cargando: cargando,
            onPressed: _solicitar,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: cargando ? null : () => setState(() => _pasoDos = true),
            child: const Text('Ya tengo un codigo'),
          ),
        ],
      ),
    );
  }

  Widget _construirPasoDos(bool cargando) {
    return Form(
      key: _formCambio,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.password, size: 64, color: AppColors.primary),
          const SizedBox(height: 20),
          const Text(
            'Escribe el codigo recibido y tu nueva contrasena.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          AuthTextField(
            controller: _tokenCtrl,
            label: 'Codigo de recuperacion',
            icono: Icons.vpn_key_outlined,
            validator: (v) => Validators.requerido(v, 'El codigo'),
          ),
          AuthTextField(
            controller: _passCtrl,
            label: 'Nueva contrasena',
            icono: Icons.lock_outline,
            esPassword: true,
            validator: Validators.password,
          ),
          AuthTextField(
            controller: _confirmCtrl,
            label: 'Confirmar contrasena',
            icono: Icons.lock_reset_outlined,
            esPassword: true,
            accionTeclado: TextInputAction.done,
            validator: (v) => Validators.confirmar(v, _passCtrl.text),
          ),
          AuthButton(
            texto: 'Cambiar contrasena',
            cargando: cargando,
            onPressed: _cambiar,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: cargando ? null : () => setState(() => _pasoDos = false),
            child: const Text('Volver a solicitar el codigo'),
          ),
        ],
      ),
    );
  }
}
