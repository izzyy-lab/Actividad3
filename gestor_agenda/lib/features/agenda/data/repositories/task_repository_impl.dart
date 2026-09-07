import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// Implementacion del contrato de agenda sobre la fuente de datos remota.
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;
  const TaskRepositoryImpl(this._remote);

  @override
  Future<List<Task>> getTasks({EstadoTarea? estado}) =>
      _remote.getTasks(estado: estado);

  @override
  Future<Task> createTask({
    required String titulo,
    String? descripcion,
    required DateTime fecha,
    required EstadoTarea estado,
    required PrioridadTarea prioridad,
  }) {
    final modelo = TaskModel(
      id: 0, // lo asigna el backend
      titulo: titulo,
      descripcion: descripcion,
      fecha: fecha,
      estado: estado,
      prioridad: prioridad,
      completada: estado == EstadoTarea.completada,
    );
    return _remote.createTask(modelo);
  }

  @override
  Future<Task> updateTask({
    required int id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    EstadoTarea? estado,
    PrioridadTarea? prioridad,
    bool? completada,
  }) {
    // Solo se envian los campos que realmente cambiaron (PUT parcial).
    final cambios = <String, dynamic>{};
    if (titulo != null) cambios['titulo'] = titulo;
    if (descripcion != null) cambios['descripcion'] = descripcion;
    if (fecha != null) cambios['fecha'] = fecha.toIso8601String();
    if (estado != null) cambios['estado'] = estado.valor;
    if (prioridad != null) cambios['prioridad'] = prioridad.valor;
    if (completada != null) cambios['completada'] = completada;

    return _remote.updateTask(id, cambios);
  }

  @override
  Future<void> deleteTask(int id) => _remote.deleteTask(id);
}
