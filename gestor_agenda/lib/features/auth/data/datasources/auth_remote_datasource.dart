import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Respuesta del backend al autenticarse: token + usuario.
class AuthResponse {
  final String accessToken;
  final UserModel user;
  const AuthResponse({required this.accessToken, required this.user});
}

/// Fuente de datos remota: habla directamente con la API de autenticacion.
class AuthRemoteDataSource {
  final ApiClient _api;
  const AuthRemoteDataSource(this._api);

  Future<AuthResponse> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    final json = await _api.post(
      ApiConstants.register,
      autenticado: false,
      body: {
        'nombre': nombre,
        'email': email,
        'password': password,
        'telefono': telefono,
      },
    );
    return _mapAuth(json);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _api.post(
      ApiConstants.login,
      autenticado: false,
      body: {'email': email, 'password': password},
    );
    return _mapAuth(json);
  }

  Future<String?> forgotPassword(String email) async {
    final json = await _api.post(
      ApiConstants.forgotPassword,
      autenticado: false,
      body: {'email': email},
    );
    return (json as Map<String, dynamic>)['reset_token'] as String?;
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await _api.post(
      ApiConstants.resetPassword,
      autenticado: false,
      body: {'reset_token': resetToken, 'new_password': newPassword},
    );
  }

  Future<UserModel> getProfile() async {
    final json = await _api.get(ApiConstants.profile);
    return UserModel.fromJson(json as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({String? nombre, String? telefono}) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (telefono != null) body['telefono'] = telefono;

    final json = await _api.put(ApiConstants.profile, body: body);
    return UserModel.fromJson(json as Map<String, dynamic>);
  }

  AuthResponse _mapAuth(dynamic json) {
    final mapa = json as Map<String, dynamic>;
    return AuthResponse(
      accessToken: mapa['access_token'] as String,
      user: UserModel.fromJson(mapa['user'] as Map<String, dynamic>),
    );
  }
}
