import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementacion del contrato de dominio.
/// Coordina la fuente remota con el almacenamiento local del token.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStorage tokenStorage,
  })  : _remote = remote,
        _tokenStorage = tokenStorage;

  @override
  Future<User> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final respuesta = await _remote.register(
      nombre: nombre,
      email: email,
      password: password,
      telefono: telefono,
    );
    await _tokenStorage.save(respuesta.accessToken);
    return respuesta.user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final respuesta = await _remote.login(email: email, password: password);
    await _tokenStorage.save(respuesta.accessToken);
    return respuesta.user;
  }

  @override
  Future<String?> forgotPassword(String email) => _remote.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) =>
      _remote.resetPassword(resetToken: resetToken, newPassword: newPassword);

  @override
  Future<User> getProfile() => _remote.getProfile();

  @override
  Future<User> updateProfile({String? nombre, String? telefono}) =>
      _remote.updateProfile(nombre: nombre, telefono: telefono);

  @override
  Future<void> logout() => _tokenStorage.clear();

  @override
  Future<bool> haySesionActiva() async {
    final token = await _tokenStorage.read();
    return token != null && token.isNotEmpty;
  }
}
