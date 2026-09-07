import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/task.dart';
import '../providers/agenda_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_page.dart';

/// Pantalla principal con la lista de la agenda -- Aprendiz B.
class AgendaListPage extends StatefulWidget {
  const AgendaListPage({super.key});

  @override
  State<AgendaListPage> createState() => _AgendaListPageState();
}

class _AgendaListPageState extends State<AgendaListPage> {
  @override
  void initState() {
    super.initState();
    // Se carga la agenda apenas se monta la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaProvider>().cargarTareas();
    });
  }

  Future<void> _abrirFormulario({Task? tarea}) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskFormPage(tarea: tarea)),
    );
    if (guardado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tarea == null ? 'Tarea creada' : 'Tarea actualizada',
          ),
          backgroundColor: AppColors.completada,
        ),
      );
    }
  }

  Future<void> _confirmarEliminar(Task tarea) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('Se eliminara "${tarea.titulo}". Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final agenda = context.read<AgendaProvider>();
    final exito = await agenda.eliminarTarea(tarea.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito ? 'Tarea eliminada' : (agenda.error ?? 'No se pudo eliminar')),
        backgroundColor: exito ? AppColors.completada : AppColors.error,
      ),
    );
  }

  Future<void> _alternar(Task tarea) async {
    final agenda = context.read<AgendaProvider>();
    final exito = await agenda.alternarCompletada(tarea);
    if (!mounted || exito) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(agenda.error ?? 'No se pudo actualizar la tarea'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agenda = context.watch<AgendaProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white24,
              child: Text(
                user?.iniciales ?? '?',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: Column(
        children: [
          _BarraResumen(agenda: agenda),
          _BarraFiltros(
            filtro: agenda.filtro,
            onSeleccionar: (estado) => agenda.aplicarFiltro(estado),
          ),
          Expanded(child: _construirCuerpo(agenda)),
        ],
      ),
    );
  }

  Widget _construirCuerpo(AgendaProvider agenda) {
    if (agenda.cargando && agenda.tareas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (agenda.error != null && agenda.tareas.isEmpty) {
      return _EstadoVacio(
        icono: Icons.cloud_off,
        titulo: 'No se pudo cargar la agenda',
        mensaje: agenda.error!,
        accion: FilledButton.icon(
          onPressed: () => agenda.cargarTareas(),
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      );
    }

    if (agenda.tareas.isEmpty) {
      return _EstadoVacio(
        icono: Icons.event_available,
        titulo: agenda.filtro == null
            ? 'Aun no tienes tareas'
            : 'Sin tareas en "${agenda.filtro!.etiqueta}"',
        mensaje: 'Pulsa el boton "Nueva tarea" para agregar una actividad.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => agenda.cargarTareas(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: agenda.tareas.length,
        itemBuilder: (_, i) {
          final tarea = agenda.tareas[i];
          return TaskCard(
            tarea: tarea,
            onToggle: () => _alternar(tarea),
            onEditar: () => _abrirFormulario(tarea: tarea),
            onEliminar: () => _confirmarEliminar(tarea),
          );
        },
      ),
    );
  }
}

/// Franja superior con los contadores de la agenda.
class _BarraResumen extends StatelessWidget {
  final AgendaProvider agenda;
  const _BarraResumen({required this.agenda});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _Contador(valor: agenda.totalPendientes, etiqueta: 'Pendientes'),
          _Contador(valor: agenda.totalEnProgreso, etiqueta: 'En progreso'),
          _Contador(valor: agenda.totalCompletadas, etiqueta: 'Completadas'),
        ],
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  final int valor;
  final String etiqueta;
  const _Contador({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$valor',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// Chips para filtrar la lista por estado.
class _BarraFiltros extends StatelessWidget {
  final EstadoTarea? filtro;
  final ValueChanged<EstadoTarea?> onSeleccionar;

  const _BarraFiltros({required this.filtro, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    final opciones = <(String, EstadoTarea?)>[
      ('Todas', null),
      (EstadoTarea.pendiente.etiqueta, EstadoTarea.pendiente),
      (EstadoTarea.enProgreso.etiqueta, EstadoTarea.enProgreso),
      (EstadoTarea.completada.etiqueta, EstadoTarea.completada),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: opciones.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (etiqueta, estado) = opciones[i];
          return ChoiceChip(
            label: Text(etiqueta),
            selected: filtro == estado,
            onSelected: (_) => onSeleccionar(estado),
          );
        },
      ),
    );
  }
}

/// Mensaje para lista vacia o error.
class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget? accion;

  const _EstadoVacio({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (accion != null) ...[const SizedBox(height: 20), accion!],
          ],
        ),
      ),
    );
  }
}
