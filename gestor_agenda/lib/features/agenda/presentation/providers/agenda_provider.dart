import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

/// Estado de la agenda: lista de tareas, filtro activo, carga y errores.
class AgendaProvider extends ChangeNotifier {
  final GetTasksUseCase _getTasks;
  final CreateTaskUseCase _createTask;
  final UpdateTaskUseCase _updateTask;
  final DeleteTaskUseCase _deleteTask;
  final ToggleTaskUseCase _toggleTask;

  AgendaProvider({
    required GetTasksUseCase getTasks,
    required CreateTaskUseCase createTask,
    required UpdateTaskUseCase updateTask,
    required DeleteTaskUseCase deleteTask,
    required ToggleTaskUseCase toggleTask,
  })  : _getTasks = getTasks,
        _createTask = createTask,
        _updateTask = updateTask,
        _deleteTask = deleteTask,
        _toggleTask = toggleTask;

  /// Lista que se muestra en pantalla (puede venir filtrada por estado).
  List<Task> _tareas = [];

  /// Lista completa del usuario: alimenta los contadores del resumen,
  /// que deben ser los mismos aunque haya un filtro activo.
  List<Task> _todas = [];

  EstadoTarea? _filtro;
  bool _cargando = false;
  String? _error;

  List<Task> get tareas => List.unmodifiable(_tareas);
  EstadoTarea? get filtro => _filtro;
  bool get cargando => _cargando;
  String? get error => _error;

  int get totalTareas => _todas.length;
  int get totalPendientes =>
      _todas.where((t) => t.estado == EstadoTarea.pendiente).length;
  int get totalEnProgreso =>
      _todas.where((t) => t.estado == EstadoTarea.enProgreso).length;
  int get totalCompletadas => _todas.where((t) => t.completada).length;

  /// Carga (o recarga) la lista desde la API.
  Future<void> cargarTareas({EstadoTarea? estado, bool mantenerFiltro = true}) async {
    if (!mantenerFiltro) _filtro = estado;
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _recargarSilencioso();
    } on Failure catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'No se pudieron cargar las tareas';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> aplicarFiltro(EstadoTarea? estado) async {
    _filtro = estado;
    await cargarTareas();
  }

  Future<bool> crearTarea({
    required String titulo,
    String? descripcion,
    required DateTime fecha,
    required EstadoTarea estado,
    required PrioridadTarea prioridad,
  }) async {
    return _ejecutar(() async {
      await _createTask(
        titulo: titulo,
        descripcion: descripcion,
        fecha: fecha,
        estado: estado,
        prioridad: prioridad,
      );
      await _recargarSilencioso();
    });
  }

  Future<bool> actualizarTarea({
    required int id,
    required String titulo,
    String? descripcion,
    required DateTime fecha,
    required EstadoTarea estado,
    required PrioridadTarea prioridad,
  }) async {
    return _ejecutar(() async {
      await _updateTask(
        id: id,
        titulo: titulo,
        descripcion: descripcion ?? '',
        fecha: fecha,
        estado: estado,
        prioridad: prioridad,
      );
      await _recargarSilencioso();
    });
  }

  Future<bool> alternarCompletada(Task tarea) async {
    return _ejecutar(() async {
      await _toggleTask(tarea);
      await _recargarSilencioso();
    });
  }

  Future<bool> eliminarTarea(int id) async {
    return _ejecutar(() async {
      await _deleteTask(id);
      await _recargarSilencioso();
    });
  }

  /// Limpia el estado al cerrar sesion.
  void limpiar() {
    _tareas = [];
    _todas = [];
    _filtro = null;
    _error = null;
    notifyListeners();
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Refresca la lista visible y la lista completa del resumen.
  /// Cuando hay un filtro activo se pide tambien la vista filtrada a la API.
  Future<void> _recargarSilencioso() async {
    _todas = await _getTasks();
    _tareas = _filtro == null ? _todas : await _getTasks(estado: _filtro);
  }

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await accion();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Ocurrio un error inesperado';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
