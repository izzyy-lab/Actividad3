import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/task.dart';
import '../providers/agenda_provider.dart';
import '../widgets/status_badge.dart';

/// Formulario de nueva tarea / edicion -- Aprendiz B.
class TaskFormPage extends StatefulWidget {
  /// Si viene una tarea el formulario funciona en modo edicion.
  final Task? tarea;

  const TaskFormPage({super.key, this.tarea});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descCtrl;

  late DateTime _fecha;
  late EstadoTarea _estado;
  late PrioridadTarea _prioridad;

  bool get _esEdicion => widget.tarea != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarea;
    _tituloCtrl = TextEditingController(text: t?.titulo ?? '');
    _descCtrl = TextEditingController(text: t?.descripcion ?? '');
    _fecha = t?.fecha.toLocal() ??
        DateTime.now().add(const Duration(hours: 1)).copyWith(
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            );
    _estado = t?.estado ?? EstadoTarea.pendiente;
    _prioridad = t?.prioridad ?? PrioridadTarea.media;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Fecha de la actividad',
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fecha),
      helpText: 'Hora de la actividad',
    );
    if (!mounted) return;

    setState(() {
      _fecha = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora?.hour ?? _fecha.hour,
        hora?.minute ?? _fecha.minute,
      );
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final agenda = context.read<AgendaProvider>();
    final exito = _esEdicion
        ? await agenda.actualizarTarea(
            id: widget.tarea!.id,
            titulo: _tituloCtrl.text,
            descripcion: _descCtrl.text,
            fecha: _fecha,
            estado: _estado,
            prioridad: _prioridad,
          )
        : await agenda.crearTarea(
            titulo: _tituloCtrl.text,
            descripcion: _descCtrl.text,
            fecha: _fecha,
            estado: _estado,
            prioridad: _prioridad,
          );

    if (!mounted) return;

    if (exito) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(agenda.error ?? 'No se pudo guardar la tarea'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<AgendaProvider>().cargando;
    final formato = DateFormat('EEEE dd MMMM yyyy - hh:mm a', 'es');

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar tarea' : 'Nueva tarea'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _tituloCtrl,
                      textInputAction: TextInputAction.next,
                      validator: Validators.titulo,
                      decoration: const InputDecoration(
                        labelText: 'Titulo de la actividad',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion (opcional)',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.notes),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.calendar_month,
                          color: AppColors.primary,
                        ),
                        title: const Text(
                          'Fecha y hora',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        subtitle: Text(
                          formato.format(_fecha),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: const Icon(Icons.edit_calendar),
                        onTap: cargando ? null : _seleccionarFecha,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _Etiqueta('Estado'),
                    Wrap(
                      spacing: 8,
                      children: EstadoTarea.values.map((estado) {
                        return ChoiceChip(
                          label: Text(estado.etiqueta),
                          selected: _estado == estado,
                          selectedColor: StatusBadge.colorDe(
                            estado,
                          ).withValues(alpha: 0.25),
                          onSelected: (_) => setState(() => _estado = estado),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const _Etiqueta('Prioridad'),
                    Wrap(
                      spacing: 8,
                      children: PrioridadTarea.values.map((prioridad) {
                        return ChoiceChip(
                          label: Text(prioridad.etiqueta),
                          selected: _prioridad == prioridad,
                          selectedColor: PriorityBadge.colorDe(
                            prioridad,
                          ).withValues(alpha: 0.25),
                          onSelected: (_) =>
                              setState(() => _prioridad = prioridad),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: cargando ? null : _guardar,
                      icon: cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _esEdicion ? 'Guardar cambios' : 'Crear tarea',
                      ),
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

class _Etiqueta extends StatelessWidget {
  final String texto;
  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
