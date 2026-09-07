import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/error/failures.dart';
import 'package:gestor_agenda/features/agenda/domain/entities/task.dart';
import 'package:gestor_agenda/features/agenda/domain/repositories/task_repository.dart';
import 'package:gestor_agenda/features/agenda/domain/usecases/create_task_usecase.dart';
import 'package:gestor_agenda/features/agenda/domain/usecases/delete_task_usecase.dart';
import 'package:gestor_agenda/features/agenda/domain/usecases/get_tasks_usecase.dart';
import 'package:gestor_agenda/features/agenda/domain/usecases/toggle_task_usecase.dart';
import 'package:gestor_agenda/features/agenda/domain/usecases/update_task_usecase.dart';
import 'package:gestor_agenda/features/agenda/presentation/providers/agenda_provider.dart';

/// Repositorio en memoria: sustituye la API en las pruebas.
class FakeTaskRepository implements TaskRepository {
  final List<Task> _almacen = [];
  int _siguienteId = 1;

  /// Cuando es true toda operacion falla, para probar el manejo de errores.
  bool fallar = false;

  /// Ultimo filtro recibido por getTasks.
  EstadoTarea? ultimoFiltro;

  @override
  Future<List<Task>> getTasks({EstadoTarea? estado}) async {
    if (fallar) throw const NetworkFailure();
    ultimoFiltro = estado;
    if (estado == null) return List.of(_almacen);
    return _almacen.where((t) => t.estado == estado).toList();
  }

  @override
  Future<Task> createTask({
    required String titulo,
    String? descripcion,
    required DateTime fecha,
    required EstadoTarea estado,
    required PrioridadTarea prioridad,
  }) async {
    if (fallar) throw const NetworkFailure();
    final tarea = Task(
      id: _siguienteId++,
      titulo: titulo,
      descripcion: descripcion,
      fecha: fecha,
      estado: estado,
      prioridad: prioridad,
      completada: estado == EstadoTarea.completada,
    );
    _almacen.add(tarea);
    return tarea;
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
  }) async {
    if (fallar) throw const NetworkFailure();
    final i = _almacen.indexWhere((t) => t.id == id);
    if (i == -1) throw const ServerFailure('Tarea no encontrada', 404);

    final actual = _almacen[i];
    final nuevaCompletada = completada ?? actual.completada;
    final nuevoEstado = estado ??
        (completada == null
            ? actual.estado
            : (nuevaCompletada ? EstadoTarea.completada : EstadoTarea.pendiente));

    final actualizada = Task(
      id: actual.id,
      titulo: titulo ?? actual.titulo,
      descripcion: descripcion ?? actual.descripcion,
      fecha: fecha ?? actual.fecha,
      estado: nuevoEstado,
      prioridad: prioridad ?? actual.prioridad,
      completada: estado != null ? estado == EstadoTarea.completada : nuevaCompletada,
    );
    _almacen[i] = actualizada;
    return actualizada;
  }

  @override
  Future<void> deleteTask(int id) async {
    if (fallar) throw const NetworkFailure();
    _almacen.removeWhere((t) => t.id == id);
  }
}

void main() {
  late FakeTaskRepository repo;
  late AgendaProvider provider;

  setUp(() {
    repo = FakeTaskRepository();
    provider = AgendaProvider(
      getTasks: GetTasksUseCase(repo),
      createTask: CreateTaskUseCase(repo),
      updateTask: UpdateTaskUseCase(repo),
      deleteTask: DeleteTaskUseCase(repo),
      toggleTask: ToggleTaskUseCase(repo),
    );
  });

  Future<bool> crear({
    String titulo = 'Tarea de prueba',
    EstadoTarea estado = EstadoTarea.pendiente,
  }) {
    return provider.crearTarea(
      titulo: titulo,
      descripcion: 'descripcion',
      fecha: DateTime(2026, 9, 10, 9),
      estado: estado,
      prioridad: PrioridadTarea.media,
    );
  }

  test('inicia sin tareas ni errores', () {
    expect(provider.tareas, isEmpty);
    expect(provider.error, isNull);
    expect(provider.cargando, isFalse);
  });

  test('crearTarea agrega la tarea y refresca la lista', () async {
    final exito = await crear(titulo: 'Entregar taller');

    expect(exito, isTrue);
    expect(provider.tareas, hasLength(1));
    expect(provider.tareas.first.titulo, 'Entregar taller');
    expect(provider.error, isNull);
  });

  test('crearTarea rechaza titulos de menos de 3 caracteres', () async {
    final exito = await crear(titulo: 'ab');

    expect(exito, isFalse);
    expect(provider.error, contains('al menos 3 caracteres'));
    expect(provider.tareas, isEmpty);
  });

  test('los contadores reflejan el estado de cada tarea', () async {
    await crear(titulo: 'Pendiente uno');
    await crear(titulo: 'En progreso', estado: EstadoTarea.enProgreso);
    await crear(titulo: 'Completada', estado: EstadoTarea.completada);

    expect(provider.totalPendientes, 1);
    expect(provider.totalEnProgreso, 1);
    expect(provider.totalCompletadas, 1);
  });

  test('alternarCompletada cambia el estado a completada y vuelve a pendiente', () async {
    await crear(titulo: 'Repasar Dart');
    final tarea = provider.tareas.first;

    await provider.alternarCompletada(tarea);
    expect(provider.tareas.first.completada, isTrue);
    expect(provider.tareas.first.estado, EstadoTarea.completada);

    await provider.alternarCompletada(provider.tareas.first);
    expect(provider.tareas.first.completada, isFalse);
    expect(provider.tareas.first.estado, EstadoTarea.pendiente);
  });

  test('eliminarTarea quita la tarea de la lista', () async {
    await crear(titulo: 'Tarea a borrar');
    final id = provider.tareas.first.id;

    final exito = await provider.eliminarTarea(id);

    expect(exito, isTrue);
    expect(provider.tareas, isEmpty);
  });

  test('aplicarFiltro consulta el repositorio solo con ese estado', () async {
    await crear(titulo: 'Pendiente uno');
    await crear(titulo: 'Completada', estado: EstadoTarea.completada);

    await provider.aplicarFiltro(EstadoTarea.completada);

    expect(repo.ultimoFiltro, EstadoTarea.completada);
    expect(provider.filtro, EstadoTarea.completada);
    expect(provider.tareas, hasLength(1));
    expect(provider.tareas.first.titulo, 'Completada');
  });

  test('los contadores del resumen no cambian al aplicar un filtro', () async {
    await crear(titulo: 'Pendiente uno');
    await crear(titulo: 'Pendiente dos');
    await crear(titulo: 'Completada', estado: EstadoTarea.completada);

    await provider.aplicarFiltro(EstadoTarea.completada);

    // La lista visible sigue el filtro...
    expect(provider.tareas, hasLength(1));
    // ...pero el resumen sigue contando todas las tareas del usuario.
    expect(provider.totalTareas, 3);
    expect(provider.totalPendientes, 2);
    expect(provider.totalCompletadas, 1);
  });

  test('un fallo de red deja el mensaje en error y no rompe la app', () async {
    repo.fallar = true;

    await provider.cargarTareas();

    expect(provider.cargando, isFalse);
    expect(provider.error, isNotNull);
    expect(provider.tareas, isEmpty);
  });

  test('limpiar deja el estado listo para otro usuario', () async {
    await crear();
    await provider.aplicarFiltro(EstadoTarea.pendiente);

    provider.limpiar();

    expect(provider.tareas, isEmpty);
    expect(provider.filtro, isNull);
    expect(provider.error, isNull);
  });
}
