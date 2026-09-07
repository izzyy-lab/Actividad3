import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../agenda/presentation/providers/agenda_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

/// Pantalla de perfil de usuario -- Aprendiz B (ubicada en el feature auth).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telCtrl;

  bool _editando = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nombreCtrl = TextEditingController(text: user?.nombre ?? '');
    _telCtrl = TextEditingController(text: user?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final exito = await auth.actualizarPerfil(
      nombre: _nombreCtrl.text,
      telefono: _telCtrl.text,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exito ? 'Perfil actualizado' : (auth.error ?? 'No se pudo actualizar'),
        ),
        backgroundColor: exito ? AppColors.completada : AppColors.error,
      ),
    );
    if (exito) setState(() => _editando = false);
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Seguro que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    context.read<AgendaProvider>().limpiar();
    await context.read<AuthProvider>().cerrarSesion();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final agenda = context.watch<AgendaProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            icon: Icon(_editando ? Icons.close : Icons.edit),
            tooltip: _editando ? 'Cancelar' : 'Editar perfil',
            onPressed: () {
              setState(() {
                _editando = !_editando;
                if (!_editando) {
                  _nombreCtrl.text = user.nombre;
                  _telCtrl.text = user.telefono ?? '';
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.iniciales,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _Estadistica(
                      valor: '${agenda.totalTareas}',
                      etiqueta: 'Tareas',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _Estadistica(
                      valor: '${agenda.totalPendientes}',
                      etiqueta: 'Pendientes',
                      color: AppColors.pendiente,
                    ),
                    const SizedBox(width: 12),
                    _Estadistica(
                      valor: '${agenda.totalCompletadas}',
                      etiqueta: 'Completadas',
                      color: AppColors.completada,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (_editando)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _nombreCtrl,
                          label: 'Nombre completo',
                          icono: Icons.person_outline,
                          validator: Validators.nombre,
                        ),
                        AuthTextField(
                          controller: _telCtrl,
                          label: 'Telefono',
                          icono: Icons.phone_outlined,
                          tipoTeclado: TextInputType.phone,
                          accionTeclado: TextInputAction.done,
                        ),
                        AuthButton(
                          texto: 'Guardar cambios',
                          cargando: auth.cargando,
                          onPressed: _guardar,
                        ),
                      ],
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        _Dato(
                          icono: Icons.person_outline,
                          titulo: 'Nombre',
                          valor: user.nombre,
                        ),
                        const Divider(height: 1),
                        _Dato(
                          icono: Icons.email_outlined,
                          titulo: 'Correo',
                          valor: user.email,
                        ),
                        const Divider(height: 1),
                        _Dato(
                          icono: Icons.phone_outlined,
                          titulo: 'Telefono',
                          valor: user.telefono?.isNotEmpty == true
                              ? user.telefono!
                              : 'Sin registrar',
                        ),
                        const Divider(height: 1),
                        _Dato(
                          icono: Icons.calendar_today_outlined,
                          titulo: 'Miembro desde',
                          valor: DateFormat(
                            'dd/MM/yyyy',
                          ).format(user.creadoEn.toLocal()),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Cerrar sesion',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta compacta con un contador de la agenda.
class _Estadistica extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final Color color;

  const _Estadistica({
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de solo lectura con un dato del perfil.
class _Dato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _Dato({required this.icono, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: AppColors.primary),
      title: Text(titulo, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
