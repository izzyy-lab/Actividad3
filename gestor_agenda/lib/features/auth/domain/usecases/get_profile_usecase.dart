import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: consultar el perfil del usuario autenticado.
class GetProfileUseCase {
  final AuthRepository _repository;
  const GetProfileUseCase(this._repository);

  Future<User> call() => _repository.getProfile();
}
