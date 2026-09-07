import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Caso de uso: listar las tareas del usuario, con filtro opcional por estado.
class GetTasksUseCase {
  final TaskRepository _repository;
  const GetTasksUseCase(this._repository);

  Future<List<Task>> call({EstadoTarea? estado}) =>
      _repository.getTasks(estado: estado);
}
