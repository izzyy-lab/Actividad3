import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: registrar un nuevo usuario.
class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<User> call({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) {
    return _repository.register(
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      telefono: (telefono != null && telefono.trim().isEmpty) ? null : telefono?.trim(),
    );
  }
}
