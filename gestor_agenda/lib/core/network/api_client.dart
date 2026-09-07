import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../error/failures.dart';
import '../storage/token_storage.dart';

/// Cliente HTTP centralizado: arma las peticiones, adjunta el token
/// y traduce las respuestas de la API a datos o a [Failure].
class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;

  ApiClient({http.Client? client, required TokenStorage tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage;

  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, String>> _headers({bool autenticado = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (autenticado) {
      final token = await _tokenStorage.read();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: query.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool autenticado = true}) async {
    return _enviar(() async => _client
        .get(_uri(path, query), headers: await _headers(autenticado: autenticado))
        .timeout(_timeout));
  }

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body, bool autenticado = true}) async {
    return _enviar(() async => _client
        .post(_uri(path),
            headers: await _headers(autenticado: autenticado),
            body: jsonEncode(body ?? {}))
        .timeout(_timeout));
  }

  Future<dynamic> put(String path,
      {Map<String, dynamic>? body, bool autenticado = true}) async {
    return _enviar(() async => _client
        .put(_uri(path),
            headers: await _headers(autenticado: autenticado),
            body: jsonEncode(body ?? {}))
        .timeout(_timeout));
  }

  Future<dynamic> delete(String path, {bool autenticado = true}) async {
    return _enviar(() async => _client
        .delete(_uri(path), headers: await _headers(autenticado: autenticado))
        .timeout(_timeout));
  }

  Future<dynamic> _enviar(Future<http.Response> Function() peticion) async {
    late final http.Response respuesta;
    try {
      respuesta = await peticion();
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    } catch (_) {
      throw const NetworkFailure();
    }
    return _procesar(respuesta);
  }

  dynamic _procesar(http.Response respuesta) {
    final codigo = respuesta.statusCode;
    final cuerpo = respuesta.body;

    if (codigo == 204 || cuerpo.isEmpty) {
      if (codigo >= 200 && codigo < 300) return null;
      throw ServerFailure('Error del servidor ($codigo)', codigo);
    }

    final decodificado = jsonDecode(utf8.decode(respuesta.bodyBytes));

    if (codigo >= 200 && codigo < 300) return decodificado;
    if (codigo == 401) throw const UnauthorizedFailure();

    throw ServerFailure(_mensajeDeError(decodificado, codigo), codigo);
  }

  /// FastAPI devuelve `detail` como texto o como lista de errores de validacion.
  String _mensajeDeError(dynamic cuerpo, int codigo) {
    if (cuerpo is Map && cuerpo['detail'] != null) {
      final detalle = cuerpo['detail'];
      if (detalle is String) return detalle;
      if (detalle is List && detalle.isNotEmpty) {
        final primero = detalle.first;
        if (primero is Map && primero['msg'] != null) return '${primero['msg']}';
      }
    }
    return 'Ocurrio un error inesperado ($codigo)';
  }
}
