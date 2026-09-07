import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/error/failures.dart';
import 'package:gestor_agenda/core/network/api_client.dart';
import 'package:gestor_agenda/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = TokenStorage();
  });

  ApiClient clienteQueResponde(
    int codigo,
    Object? cuerpo, {
    void Function(http.Request)? alRecibir,
  }) {
    final mock = MockClient((request) async {
      alRecibir?.call(request);
      return http.Response(
        cuerpo == null ? '' : jsonEncode(cuerpo),
        codigo,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    return ApiClient(client: mock, tokenStorage: storage);
  }

  test('adjunta el token guardado en la cabecera Authorization', () async {
    await storage.save('token-abc');
    String? autorizacion;

    final api = clienteQueResponde(
      200,
      {'ok': true},
      alRecibir: (r) => autorizacion = r.headers['Authorization'],
    );
    await api.get('/tasks');

    expect(autorizacion, 'Bearer token-abc');
  });

  test('no adjunta token en las peticiones publicas', () async {
    await storage.save('token-abc');
    Map<String, String>? cabeceras;

    final api = clienteQueResponde(
      200,
      {'ok': true},
      alRecibir: (r) => cabeceras = r.headers,
    );
    await api.post('/auth/login', body: {'email': 'a@b.co'}, autenticado: false);

    expect(cabeceras?.containsKey('Authorization'), isFalse);
  });

  test('agrega los parametros de consulta a la URL', () async {
    Uri? urlLlamada;

    final api = clienteQueResponde(
      200,
      [],
      alRecibir: (r) => urlLlamada = r.url,
    );
    await api.get('/tasks', query: {'estado': 'pendiente'});

    expect(urlLlamada?.queryParameters['estado'], 'pendiente');
  });

  test('traduce un 401 en UnauthorizedFailure', () async {
    final api = clienteQueResponde(401, {'detail': 'Token invalido'});

    expect(() => api.get('/auth/me'), throwsA(isA<UnauthorizedFailure>()));
  });

  test('usa el campo detail de FastAPI como mensaje de error', () async {
    final api = clienteQueResponde(409, {'detail': 'El correo ya se encuentra registrado'});

    await expectLater(
      api.post('/auth/register', autenticado: false),
      throwsA(
        isA<ServerFailure>()
            .having((f) => f.message, 'message', 'El correo ya se encuentra registrado')
            .having((f) => f.statusCode, 'statusCode', 409),
      ),
    );
  });

  test('extrae el mensaje cuando detail es una lista de validacion', () async {
    final api = clienteQueResponde(422, {
      'detail': [
        {'loc': ['body', 'titulo'], 'msg': 'String should have at least 3 characters'},
      ],
    });

    await expectLater(
      api.post('/tasks'),
      throwsA(
        isA<ServerFailure>().having(
          (f) => f.message,
          'message',
          'String should have at least 3 characters',
        ),
      ),
    );
  });

  test('un 204 sin cuerpo se resuelve como null', () async {
    final api = clienteQueResponde(204, null);

    expect(await api.delete('/tasks/1'), isNull);
  });

  test('si el servidor no responde lanza NetworkFailure', () async {
    final mock = MockClient((_) async => throw const SocketExceptionSimulada());
    final api = ApiClient(client: mock, tokenStorage: storage);

    expect(() => api.get('/tasks'), throwsA(isA<NetworkFailure>()));
  });
}

/// Excepcion generica para simular la caida del servidor en las pruebas.
class SocketExceptionSimulada implements Exception {
  const SocketExceptionSimulada();
}
