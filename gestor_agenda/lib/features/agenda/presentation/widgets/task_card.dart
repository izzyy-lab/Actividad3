import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/task.dart';
import 'status_badge.dart';

/// Tarjeta que representa una tarea dentro de la lista de agenda.
class TaskCard extends StatelessWidget {
  final Task tarea;
  final VoidCallback onToggle;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TaskCard({
    super.key,
    required this.tarea,
    required this.onToggle,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd MMM yyyy - hh:mm a', 'es');

    return Card(
      child: InkWell(
        onTap: onEditar,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: tarea.completada,
                onChanged: (_) => onToggle(),
                shape: const CircleBorder(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textSecondary,
                      ),
                    ),
                    if (tarea.descripcion != null &&
                        tarea.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tarea.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: tarea.vencida
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formatoFecha.format(tarea.fecha.toLocal()),
                            style: TextStyle(
                              fontSize: 12,
                              color: tarea.vencida
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontWeight: tarea.vencida
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusBadge(estado: tarea.estado),
                        PriorityBadge(prioridad: tarea.prioridad),
                        if (tarea.vencida)
                          const Text(
                            'Vencida',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onSelected: (opcion) {
                  if (opcion == 'editar') onEditar();
                  if (opcion == 'eliminar') onEliminar();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline, color: AppColors.error),
                      title: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
