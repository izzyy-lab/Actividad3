import '../repositories/auth_repository.dart';

/// Caso de uso: establecer una nueva contrasena con el token recibido.
class ResetPasswordUseCase {
  final AuthRepository _repository;
  const ResetPasswordUseCase(this._repository);

  Future<void> call({required String resetToken, required String newPassword}) =>
      _repository.resetPassword(
        resetToken: resetToken.trim(),
        newPassword: newPassword,
      );
}
