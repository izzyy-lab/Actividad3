import '../../domain/entities/user.dart';

/// Modelo de datos: sabe convertirse desde/hacia el JSON de la API.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.nombre,
    required super.email,
    super.telefono,
    required super.creadoEn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      creadoEn:
          DateTime.tryParse('${json['creado_en']}') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'creado_en': creadoEn.toIso8601String(),
      };
}
