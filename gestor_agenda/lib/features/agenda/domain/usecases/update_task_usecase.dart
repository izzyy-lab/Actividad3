import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Caso de uso: actualizar una tarea existente.
class UpdateTaskUseCase {
  final TaskRepository _repository;
  const UpdateTaskUseCase(this._repository);

  Future<Task> call({
    required int id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    EstadoTarea? estado,
    PrioridadTarea? prioridad,
    bool? completada,
  }) {
    if (titulo != null && titulo.trim().length < 3) {
      throw const ValidationFailure('El titulo debe tener al menos 3 caracteres');
    }
    return _repository.updateTask(
      id: id,
      titulo: titulo?.trim(),
      descripcion: descripcion?.trim(),
      fecha: fecha,
      estado: estado,
      prioridad: prioridad,
      completada: completada,
    );
  }
}
