/// Entidad de dominio: representa al usuario sin depender de la API.
class User {
  final int id;
  final String nombre;
  final String email;
  final String? telefono;
  final DateTime creadoEn;

  const User({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    required this.creadoEn,
  });

  /// Iniciales para el avatar del perfil.
  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }
}
