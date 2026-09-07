import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: actualizar los datos del perfil.
class UpdateProfileUseCase {
  final AuthRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<User> call({String? nombre, String? telefono}) =>
      _repository.updateProfile(nombre: nombre?.trim(), telefono: telefono?.trim());
}
