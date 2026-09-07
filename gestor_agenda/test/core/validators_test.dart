import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('acepta correos con formato valido', () {
      expect(Validators.email('aprendiz@sena.edu.co'), isNull);
      expect(Validators.email('nombre.apellido+etiqueta@dominio.com'), isNull);
    });

    test('rechaza vacios y formatos invalidos', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('sin-arroba.com'), isNotNull);
      expect(Validators.email('sin@dominio'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('exige al menos 6 caracteres', () {
      expect(Validators.password('12345'), 'Minimo 6 caracteres');
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmar', () {
    test('detecta contrasenas que no coinciden', () {
      expect(Validators.confirmar('abc123', 'abc124'), isNotNull);
      expect(Validators.confirmar('abc123', 'abc123'), isNull);
    });
  });

  group('Validators.nombre y titulo', () {
    test('exigen minimo 3 caracteres sin contar espacios', () {
      expect(Validators.nombre('  Ju  '), isNotNull);
      expect(Validators.nombre('Juan'), isNull);
      expect(Validators.titulo('ab'), isNotNull);
      expect(Validators.titulo('Entregar taller'), isNull);
    });
  });

  group('Validators.requerido', () {
    test('usa el nombre del campo en el mensaje', () {
      expect(Validators.requerido('', 'El codigo'), 'El codigo es obligatorio');
      expect(Validators.requerido('valor'), isNull);
    });
  });
}
