/// Validaciones reutilizables por los formularios.
class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w.\-]+$');

  static String? requerido(String? valor, [String campo = 'Este campo']) {
    if (valor == null || valor.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'El correo es obligatorio';
    if (!_email.hasMatch(valor.trim())) return 'Ingresa un correo valido';
    return null;
  }

  static String? password(String? valor) {
    if (valor == null || valor.isEmpty) return 'La contrasena es obligatoria';
    if (valor.length < 6) return 'Minimo 6 caracteres';
    return null;
  }

  static String? nombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'El nombre es obligatorio';
    if (valor.trim().length < 3) return 'Minimo 3 caracteres';
    return null;
  }

  static String? confirmar(String? valor, String original) {
    if (valor == null || valor.isEmpty) return 'Confirma la contrasena';
    if (valor != original) return 'Las contrasenas no coinciden';
    return null;
  }

  static String? titulo(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'El titulo es obligatorio';
    if (valor.trim().length < 3) return 'Minimo 3 caracteres';
    return null;
  }
}
