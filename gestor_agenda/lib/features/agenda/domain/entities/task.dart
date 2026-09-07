/// Estados posibles de una tarea de la agenda.
enum EstadoTarea {
  pendiente('pendiente', 'Pendiente'),
  enProgreso('en_progreso', 'En progreso'),
  completada('completada', 'Completada');

  final String valor;
  final String etiqueta;
  const EstadoTarea(this.valor, this.etiqueta);

  static EstadoTarea desde(String valor) => EstadoTarea.values.firstWhere(
        (e) => e.valor == valor,
        orElse: () => EstadoTarea.pendiente,
      );
}

/// Nivel de prioridad de una tarea.
enum PrioridadTarea {
  baja('baja', 'Baja'),
  media('media', 'Media'),
  alta('alta', 'Alta');

  final String valor;
  final String etiqueta;
  const PrioridadTarea(this.valor, this.etiqueta);

  static PrioridadTarea desde(String valor) => PrioridadTarea.values.firstWhere(
        (p) => p.valor == valor,
        orElse: () => PrioridadTarea.media,
      );
}

/// Entidad de dominio: una actividad de la agenda.
class Task {
  final int id;
  final String titulo;
  final String? descripcion;
  final DateTime fecha;
  final EstadoTarea estado;
  final PrioridadTarea prioridad;
  final bool completada;

  const Task({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fecha,
    required this.estado,
    required this.prioridad,
    required this.completada,
  });

  /// Una tarea esta vencida si su fecha ya paso y aun no se completa.
  bool get vencida =>
      !completada && fecha.isBefore(DateTime.now());
}
