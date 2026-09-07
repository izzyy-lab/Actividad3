import '../entities/user.dart';

/// Contrato de autenticacion. La capa de dominio no conoce HTTP ni JSON.
abstract class AuthRepository {
  Future<User> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  });

  Future<User> login({required String email, required String password});

  /// Devuelve el token de recuperacion (en produccion llegaria por correo).
  Future<String?> forgotPassword(String email);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  Future<User> getProfile();

  Future<User> updateProfile({String? nombre, String? telefono});

  Future<void> logout();

  /// Indica si hay una sesion guardada en el dispositivo.
  Future<bool> haySesionActiva();
}
