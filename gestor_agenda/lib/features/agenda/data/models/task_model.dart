import '../../domain/entities/task.dart';

/// Modelo de datos de la tarea: conversion desde/hacia el JSON de la API.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.titulo,
    super.descripcion,
    required super.fecha,
    required super.estado,
    required super.prioridad,
    required super.completada,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      fecha: DateTime.tryParse('${json['fecha']}') ?? DateTime.now(),
      estado: EstadoTarea.desde('${json['estado']}'),
      prioridad: PrioridadTarea.desde('${json['prioridad']}'),
      completada: json['completada'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
        'estado': estado.valor,
        'prioridad': prioridad.valor,
      };
}
