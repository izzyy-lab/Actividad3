import 'package:flutter/material.dart';

/// Paleta de color de la aplicacion.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2E5BFF);
  static const Color primaryDark = Color(0xFF1B3BB8);
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7280);

  // Estados de la tarea
  static const Color pendiente = Color(0xFFF59E0B);
  static const Color enProgreso = Color(0xFF3B82F6);
  static const Color completada = Color(0xFF10B981);

  // Prioridades
  static const Color prioridadAlta = Color(0xFFEF4444);
  static const Color prioridadMedia = Color(0xFFF59E0B);
  static const Color prioridadBaja = Color(0xFF10B981);

  static const Color error = Color(0xFFDC2626);
}
