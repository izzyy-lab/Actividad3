import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

enum AuthStatus { desconocido, autenticado, noAutenticado }

/// Estado de autenticacion compartido por toda la app.
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final ForgotPasswordUseCase _forgotPassword;
  final ResetPasswordUseCase _resetPassword;
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final LogoutUseCase _logout;
  final AuthRepository _repository;

  AuthProvider({
    required LoginUseCase login,
    required RegisterUseCase register,
    required ForgotPasswordUseCase forgotPassword,
    required ResetPasswordUseCase resetPassword,
    required GetProfileUseCase getProfile,
    required UpdateProfileUseCase updateProfile,
    required LogoutUseCase logout,
    required AuthRepository repository,
  })  : _login = login,
        _register = register,
        _forgotPassword = forgotPassword,
        _resetPassword = resetPassword,
        _getProfile = getProfile,
        _updateProfile = updateProfile,
        _logout = logout,
        _repository = repository;

  AuthStatus _status = AuthStatus.desconocido;
  User? _user;
  bool _cargando = false;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get cargando => _cargando;
  String? get error => _error;

  /// Al arrancar la app: si hay token guardado se recupera el perfil.
  Future<void> verificarSesion() async {
    if (!await _repository.haySesionActiva()) {
      _status = AuthStatus.noAutenticado;
      notifyListeners();
      return;
    }
    try {
      _user = await _getProfile();
      _status = AuthStatus.autenticado;
    } on Failure {
      await _logout();
      _status = AuthStatus.noAutenticado;
    }
    notifyListeners();
  }

  Future<bool> iniciarSesion(String email, String password) async {
    return _ejecutar(() async {
      _user = await _login(email: email, password: password);
      _status = AuthStatus.autenticado;
    });
  }

  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    return _ejecutar(() async {
      _user = await _register(
        nombre: nombre,
        email: email,
        password: password,
        telefono: telefono,
      );
      _status = AuthStatus.autenticado;
    });
  }

  /// Devuelve el token de recuperacion o null si el correo no existe.
  String? tokenRecuperacion;

  Future<bool> recuperarPassword(String email) async {
    return _ejecutar(() async {
      tokenRecuperacion = await _forgotPassword(email);
    });
  }

  Future<bool> cambiarPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    return _ejecutar(() async {
      await _resetPassword(resetToken: resetToken, newPassword: newPassword);
      tokenRecuperacion = null;
    });
  }

  Future<bool> actualizarPerfil({String? nombre, String? telefono}) async {
    return _ejecutar(() async {
      _user = await _updateProfile(nombre: nombre, telefono: telefono);
    });
  }

  Future<void> cerrarSesion() async {
    await _logout();
    _user = null;
    _error = null;
    tokenRecuperacion = null;
    _status = AuthStatus.noAutenticado;
    notifyListeners();
  }

  void limpiarError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Envuelve cada operacion: maneja el spinner y traduce los [Failure].
  Future<bool> _ejecutar(Future<void> Function() accion) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await accion();
      return true;
    } on Failure catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Ocurrio un error inesperado';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
