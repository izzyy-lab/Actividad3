import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/task.dart';

/// Distintivo de color para el estado de una tarea.
class StatusBadge extends StatelessWidget {
  final EstadoTarea estado;

  const StatusBadge({super.key, required this.estado});

  static Color colorDe(EstadoTarea estado) => switch (estado) {
    EstadoTarea.pendiente => AppColors.pendiente,
    EstadoTarea.enProgreso => AppColors.enProgreso,
    EstadoTarea.completada => AppColors.completada,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorDe(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Distintivo de color para la prioridad de una tarea.
class PriorityBadge extends StatelessWidget {
  final PrioridadTarea prioridad;

  const PriorityBadge({super.key, required this.prioridad});

  static Color colorDe(PrioridadTarea prioridad) => switch (prioridad) {
    PrioridadTarea.alta => AppColors.prioridadAlta,
    PrioridadTarea.media => AppColors.prioridadMedia,
    PrioridadTarea.baja => AppColors.prioridadBaja,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorDe(prioridad);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          prioridad.etiqueta,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
