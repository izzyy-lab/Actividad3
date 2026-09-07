/// Errores de dominio que la capa de presentacion sabe mostrar al usuario.
class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// El servidor respondio con un codigo de error (4xx / 5xx).
class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure(super.message, this.statusCode);
}

/// No se pudo contactar la API (sin internet, servidor apagado, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No se pudo conectar con el servidor. Verifica que la API este encendida.',
  ]);
}

/// Token ausente, invalido o expirado.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Sesion expirada. Inicia sesion nuevamente.']);
}

/// Datos locales invalidos antes de llamar a la API.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
