import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

/// Fuente de datos remota del CRUD de agenda.
class TaskRemoteDataSource {
  final ApiClient _api;
  const TaskRemoteDataSource(this._api);

  Future<List<TaskModel>> getTasks({EstadoTarea? estado}) async {
    final json = await _api.get(
      ApiConstants.tasks,
      query: estado == null ? null : {'estado': estado.valor},
    );
    return (json as List)
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> createTask(TaskModel tarea) async {
    final json = await _api.post(ApiConstants.tasks, body: tarea.toJson());
    return TaskModel.fromJson(json as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(int id, Map<String, dynamic> cambios) async {
    final json = await _api.put(ApiConstants.taskById(id), body: cambios);
    return TaskModel.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) => _api.delete(ApiConstants.taskById(id));
}
