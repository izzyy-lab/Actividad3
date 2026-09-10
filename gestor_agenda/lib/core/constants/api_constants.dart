import 'package:flutter/foundation.dart';

/// URLs base de la API REST.
class ApiConstants {
  ApiConstants._();

  /// API desplegada en Vercel (base de datos PostgreSQL en Neon).
  static const String _apiProduccion = 'https://gestor-agenda-api.vercel.app/api';

  /// Permite apuntar a cualquier otra API al compilar:
  ///   flutter run --dart-define=API_URL=https://otra-api.com/api
  static const String _apiUrlPersonalizada = String.fromEnvironment('API_URL');

  /// Para usar el backend que corre en tu PC:
  ///   flutter run --dart-define=API_LOCAL=true
  static const bool _usarApiLocal = bool.fromEnvironment('API_LOCAL');

  /// Por defecto se usa la API de Vercel. En modo local, el emulador de
  /// Android ve el `localhost` del PC en 10.0.2.2, y en Web se usa 127.0.0.1.
  static String get baseUrl {
    if (_apiUrlPersonalizada.isNotEmpty) return _apiUrlPersonalizada;
    if (!_usarApiLocal) return _apiProduccion;
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
