import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/features/agenda/data/models/task_model.dart';
import 'package:gestor_agenda/features/agenda/domain/entities/task.dart';

void main() {
  group('TaskModel.fromJson', () {
    test('mapea correctamente el JSON de la API', () {
      final modelo = TaskModel.fromJson({
        'id': 7,
        'titulo': 'Entregar taller',
        'descripcion': 'Flutter + FastAPI',
        'fecha': '2026-09-10T09:00:00',
        'estado': 'en_progreso',
        'prioridad': 'alta',
        'completada': false,
        'usuario_id': 1,
        'creado_en': '2026-09-07T08:00:00',
      });

      expect(modelo.id, 7);
      expect(modelo.titulo, 'Entregar taller');
      expect(modelo.estado, EstadoTarea.enProgreso);
      expect(modelo.prioridad, PrioridadTarea.alta);
      expect(modelo.completada, isFalse);
      expect(modelo.fecha, DateTime(2026, 9, 10, 9));
    });

    test('usa valores por defecto cuando el estado o la prioridad no existen', () {
      final modelo = TaskModel.fromJson({
        'id': 1,
        'titulo': 'Tarea',
        'descripcion': null,
        'fecha': '2026-01-01T00:00:00',
        'estado': 'inventado',
        'prioridad': 'inventada',
        'completada': null,
      });

      expect(modelo.estado, EstadoTarea.pendiente);
      expect(modelo.prioridad, PrioridadTarea.media);
      expect(modelo.completada, isFalse);
    });
  });

  group('TaskModel.toJson', () {
    test('serializa los campos que espera el backend', () {
      const fechaTexto = '2026-09-10T09:00:00.000';
      final modelo = TaskModel(
        id: 0,
        titulo: 'Estudiar',
        descripcion: 'Clean Architecture',
        fecha: DateTime.parse(fechaTexto),
        estado: EstadoTarea.pendiente,
        prioridad: PrioridadTarea.baja,
        completada: false,
      );

      expect(modelo.toJson(), {
        'titulo': 'Estudiar',
        'descripcion': 'Clean Architecture',
        'fecha': fechaTexto,
        'estado': 'pendiente',
        'prioridad': 'baja',
      });
    });
  });

  group('Task.vencida', () {
    Task construir({required DateTime fecha, required bool completada}) => Task(
      id: 1,
      titulo: 'Tarea',
      fecha: fecha,
      estado: completada ? EstadoTarea.completada : EstadoTarea.pendiente,
      prioridad: PrioridadTarea.media,
      completada: completada,
    );

    test('una tarea pendiente con fecha pasada esta vencida', () {
      final tarea = construir(
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        completada: false,
      );
      expect(tarea.vencida, isTrue);
    });

    test('una tarea completada nunca aparece como vencida', () {
      final tarea = construir(
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        completada: true,
      );
      expect(tarea.vencida, isFalse);
    });

    test('una tarea futura no esta vencida', () {
      final tarea = construir(
        fecha: DateTime.now().add(const Duration(days: 1)),
        completada: false,
      );
      expect(tarea.vencida, isFalse);
    });
  });
}
