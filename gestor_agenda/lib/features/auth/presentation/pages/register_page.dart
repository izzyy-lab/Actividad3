import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../agenda/presentation/pages/agenda_list_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Pantalla de registro -- Aprendiz A.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final exito = await auth.registrar(
      nombre: _nombreCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      telefono: _telCtrl.text,
    );
    if (!mounted) return;

    if (exito) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AgendaListPage()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'No se pudo completar el registro'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AuthProvider>().cargando;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Completa tus datos para registrarte',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _nombreCtrl,
                      label: 'Nombre completo',
                      icono: Icons.person_outline,
                      validator: Validators.nombre,
                    ),
                    AuthTextField(
                      controller: _emailCtrl,
                      label: 'Correo electronico',
                      icono: Icons.email_outlined,
                      tipoTeclado: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    AuthTextField(
                      controller: _telCtrl,
                      label: 'Telefono (opcional)',
                      icono: Icons.phone_outlined,
                      tipoTeclado: TextInputType.phone,
                    ),
                    AuthTextField(
                      controller: _passCtrl,
                      label: 'Contrasena',
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
                    const SizedBox(height: 8),
                    AuthButton(
                      texto: 'Registrarme',
                      cargando: cargando,
                      onPressed: _enviar,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: cargando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Ya tengo cuenta, iniciar sesion'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
