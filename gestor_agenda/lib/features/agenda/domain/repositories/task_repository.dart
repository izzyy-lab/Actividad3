import '../entities/task.dart';

/// Contrato del CRUD de la agenda.
abstract class TaskRepository {
  Future<List<Task>> getTasks({EstadoTarea? estado});

  Future<Task> createTask({
    required String titulo,
    String? descripcion,
    required DateTime fecha,
    required EstadoTarea estado,
    required PrioridadTarea prioridad,
  });

  Future<Task> updateTask({
    required int id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    EstadoTarea? estado,
    PrioridadTarea? prioridad,
    bool? completada,
  });

  Future<void> deleteTask(int id);
}
