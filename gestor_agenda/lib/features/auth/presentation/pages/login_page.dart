import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../agenda/presentation/pages/agenda_list_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'forgot_pass_page.dart';
import 'register_page.dart';

/// Pantalla de inicio de sesion -- Aprendiz A.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final exito = await auth.iniciarSesion(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;

    if (exito) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AgendaListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'No se pudo iniciar sesion'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AuthProvider>().cargando;

    return Scaffold(
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
                    const SizedBox(height: 20),
                    Container(
                      height: 84,
                      width: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.event_note,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Gestor de Agenda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Inicia sesion para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: _emailCtrl,
                      label: 'Correo electronico',
                      icono: Icons.email_outlined,
                      tipoTeclado: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    AuthTextField(
                      controller: _passCtrl,
                      label: 'Contrasena',
                      icono: Icons.lock_outline,
                      esPassword: true,
                      accionTeclado: TextInputAction.done,
                      validator: Validators.password,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: cargando
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPassPage(),
                                ),
                              ),
                        child: const Text('Olvide mi contrasena'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthButton(
                      texto: 'Ingresar',
                      cargando: cargando,
                      onPressed: _enviar,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No tienes cuenta?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: cargando
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                ),
                          child: const Text('Registrate'),
                        ),
                      ],
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
