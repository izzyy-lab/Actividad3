import 'package:flutter/foundation.dart';

/// URLs base de la API REST.
class ApiConstants {
  ApiConstants._();

  /// El emulador de Android expone el `localhost` del PC en 10.0.2.2.
  /// En Web (y escritorio) se usa 127.0.0.1 directamente.
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  // --- Autenticacion (Aprendiz A) ---
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/auth/me';

  // --- Agenda (Aprendiz B) ---
  static const String tasks = '/tasks';
  static String taskById(int id) => '/tasks/$id';
}
