import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: iniciar sesion.
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<User> call({required String email, required String password}) {
    return _repository.login(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}
