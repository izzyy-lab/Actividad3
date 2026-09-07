import '../repositories/auth_repository.dart';

/// Caso de uso: solicitar la recuperacion de contrasena.
class ForgotPasswordUseCase {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  Future<String?> call(String email) =>
      _repository.forgotPassword(email.trim().toLowerCase());
}
