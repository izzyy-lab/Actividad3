import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Caso de uso: crear una tarea.
/// Aqui vive la regla de negocio de validacion antes de llamar a la API.
class CreateTaskUseCase {
  final TaskRepository _repository;
  const CreateTaskUseCase(this._repository);

  Future<Task> call({
    required String titulo,
    String? descripcion,
    required DateTime fecha,
    EstadoTarea estado = EstadoTarea.pendiente,
    PrioridadTarea prioridad = PrioridadTarea.media,
  }) {
    if (titulo.trim().length < 3) {
      throw const ValidationFailure('El titulo debe tener al menos 3 caracteres');
    }
    return _repository.createTask(
      titulo: titulo.trim(),
      descripcion: descripcion?.trim().isEmpty == true ? null : descripcion?.trim(),
      fecha: fecha,
      estado: estado,
      prioridad: prioridad,
    );
  }
}
