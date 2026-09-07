import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/error/failures.dart';
import 'package:gestor_agenda/features/auth/domain/entities/user.dart';
import 'package:gestor_agenda/features/auth/domain/repositories/auth_repository.dart';
import 'package:gestor_agenda/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:gestor_agenda/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:gestor_agenda/features/auth/domain/usecases/login_usecase.dart';
import 'package:gestor_agenda/features/auth/domain/usecases/logout_usecase.dart';
import 'package:gestor_agenda/features/auth/domain/usecases/register_usecase.dart';
import 'package:gestor_agenda/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:gestor_agenda/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:gestor_agenda/features/auth/presentation/providers/auth_provider.dart';

/// Repositorio de autenticacion simulado.
class FakeAuthRepository implements AuthRepository {
  static const String passwordValida = 'clave123';

  User? _usuario;
  bool _sesionGuardada = false;

  /// Correo que recibio la ultima llamada, para verificar la normalizacion.
  String? ultimoEmailRecibido;

  User _construir({String nombre = 'Aprendiz Uno', String email = 'a@sena.edu.co'}) =>
      User(id: 1, nombre: nombre, email: email, creadoEn: DateTime(2026, 1, 1));

  @override
  Future<User> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    ultimoEmailRecibido = email;
    if (email == 'repetido@sena.edu.co') {
      throw const ServerFailure('El correo ya se encuentra registrado', 409);
    }
    _usuario = _construir(nombre: nombre, email: email);
    _sesionGuardada = true;
    return _usuario!;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    ultimoEmailRecibido = email;
    if (password != passwordValida) {
      throw const ServerFailure('Correo o contrasena incorrectos', 401);
    }
    _usuario = _construir(email: email);
    _sesionGuardada = true;
    return _usuario!;
  }

  @override
  Future<String?> forgotPassword(String email) async {
    ultimoEmailRecibido = email;
    return email == 'a@sena.edu.co' ? 'token-de-prueba' : null;
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    if (resetToken != 'token-de-prueba') {
      throw const ServerFailure('Token de recuperacion invalido o expirado', 400);
    }
  }

  @override
  Future<User> getProfile() async {
    if (!_sesionGuardada) throw const UnauthorizedFailure();
    return _usuario ??= _construir();
  }

  @override
  Future<User> updateProfile({String? nombre, String? telefono}) async {
    _usuario = User(
      id: 1,
      nombre: nombre ?? _usuario?.nombre ?? 'Aprendiz Uno',
      email: _usuario?.email ?? 'a@sena.edu.co',
      telefono: telefono,
      creadoEn: DateTime(2026, 1, 1),
    );
    return _usuario!;
  }

  @override
  Future<void> logout() async {
    _sesionGuardada = false;
    _usuario = null;
  }

  @override
  Future<bool> haySesionActiva() async => _sesionGuardada;

  /// Simula que quedo un token guardado de una sesion anterior.
  void simularTokenGuardado() => _sesionGuardada = true;
}

void main() {
  late FakeAuthRepository repo;
  late AuthProvider provider;

  setUp(() {
    repo = FakeAuthRepository();
    provider = AuthProvider(
      login: LoginUseCase(repo),
      register: RegisterUseCase(repo),
      forgotPassword: ForgotPasswordUseCase(repo),
      resetPassword: ResetPasswordUseCase(repo),
      getProfile: GetProfileUseCase(repo),
      updateProfile: UpdateProfileUseCase(repo),
      logout: LogoutUseCase(repo),
      repository: repo,
    );
  });

  test('arranca en estado desconocido', () {
    expect(provider.status, AuthStatus.desconocido);
    expect(provider.user, isNull);
  });

  test('verificarSesion sin token deja al usuario fuera', () async {
    await provider.verificarSesion();

    expect(provider.status, AuthStatus.noAutenticado);
    expect(provider.user, isNull);
  });

  test('verificarSesion con token guardado recupera el perfil', () async {
    repo.simularTokenGuardado();

    await provider.verificarSesion();

    expect(provider.status, AuthStatus.autenticado);
    expect(provider.user, isNotNull);
  });

  test('iniciarSesion con credenciales correctas autentica al usuario', () async {
    final exito = await provider.iniciarSesion('a@sena.edu.co', 'clave123');

    expect(exito, isTrue);
    expect(provider.status, AuthStatus.autenticado);
    expect(provider.user?.email, 'a@sena.edu.co');
    expect(provider.error, isNull);
  });

  test('el caso de uso normaliza el correo antes de enviarlo', () async {
    await provider.iniciarSesion('  A@SENA.EDU.CO  ', 'clave123');

    expect(repo.ultimoEmailRecibido, 'a@sena.edu.co');
  });

  test('iniciarSesion con clave incorrecta expone el mensaje del backend', () async {
    final exito = await provider.iniciarSesion('a@sena.edu.co', 'incorrecta');

    expect(exito, isFalse);
    expect(provider.status, AuthStatus.desconocido);
    expect(provider.error, 'Correo o contrasena incorrectos');
    expect(provider.cargando, isFalse);
  });

  test('registrar con correo repetido reporta el conflicto', () async {
    final exito = await provider.registrar(
      nombre: 'Aprendiz Uno',
      email: 'repetido@sena.edu.co',
      password: 'clave123',
    );

    expect(exito, isFalse);
    expect(provider.error, contains('ya se encuentra registrado'));
  });

  test('recuperarPassword guarda el token devuelto por la API', () async {
    final exito = await provider.recuperarPassword('a@sena.edu.co');

    expect(exito, isTrue);
    expect(provider.tokenRecuperacion, 'token-de-prueba');
  });

  test('cambiarPassword con token invalido falla y conserva el mensaje', () async {
    final exito = await provider.cambiarPassword(
      resetToken: 'token-falso',
      newPassword: 'nueva123',
    );

    expect(exito, isFalse);
    expect(provider.error, contains('invalido o expirado'));
  });

  test('actualizarPerfil refresca el usuario en memoria', () async {
    await provider.iniciarSesion('a@sena.edu.co', 'clave123');

    final exito = await provider.actualizarPerfil(
      nombre: 'Aprendiz Actualizado',
      telefono: '3001234567',
    );

    expect(exito, isTrue);
    expect(provider.user?.nombre, 'Aprendiz Actualizado');
    expect(provider.user?.telefono, '3001234567');
  });

  test('cerrarSesion limpia usuario, token y estado', () async {
    await provider.iniciarSesion('a@sena.edu.co', 'clave123');

    await provider.cerrarSesion();

    expect(provider.status, AuthStatus.noAutenticado);
    expect(provider.user, isNull);
    expect(provider.tokenRecuperacion, isNull);
    expect(await repo.haySesionActiva(), isFalse);
  });

  test('las iniciales del usuario se calculan desde el nombre', () {
    expect(
      User(id: 1, nombre: 'Ana Maria Perez', email: 'a@b.co', creadoEn: DateTime(2026)).iniciales,
      'AM',
    );
    expect(
      User(id: 1, nombre: 'Carlos', email: 'a@b.co', creadoEn: DateTime(2026)).iniciales,
      'C',
    );
  });
}
