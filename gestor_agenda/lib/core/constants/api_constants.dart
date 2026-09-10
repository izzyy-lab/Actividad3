import 'package:flutter/foundation.dart';

/// URLs base de la API REST.
class ApiConstants {
  ApiConstants._();

  /// URL de la API desplegada (por ejemplo en Railway), pasada al compilar:
  ///   flutter run --dart-define=API_URL=https://mi-api.up.railway.app/api
  static const String _apiUrlDesplegada = String.fromEnvironment('API_URL');

  /// Si no se indica API_URL se usa el backend local:
  /// el emulador de Android expone el `localhost` del PC en 10.0.2.2,
  /// y en Web (y escritorio) se usa 127.0.0.1 directamente.
  static String get baseUrl {
    if (_apiUrlDesplegada.isNotEmpty) return _apiUrlDesplegada;
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
