import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Caso de uso: marcar/desmarcar una tarea como completada.
class ToggleTaskUseCase {
  final TaskRepository _repository;
  const ToggleTaskUseCase(this._repository);

  Future<Task> call(Task tarea) => _repository.updateTask(
        id: tarea.id,
        completada: !tarea.completada,
      );
}
