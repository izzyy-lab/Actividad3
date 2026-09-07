import '../repositories/auth_repository.dart';

/// Caso de uso: cerrar sesion y borrar el token local.
class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}
