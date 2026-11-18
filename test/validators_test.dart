import 'package:flutter_test/flutter_test.dart';
import 'package:meu_estoque/core/validators.dart';

void main() {
  group('email', () {
    test('vazio da erro', () {
      expect(Validators.email(''), isNotNull);
    });
    test('sem dominio da erro', () {
      expect(Validators.email('ana@'), 'Digite um e-mail válido');
    });
    test('valido passa', () {
      expect(Validators.email('ana@gmail.com'), isNull);
    });
  });

  group('password', () {
    test('curta da erro', () {
      expect(Validators.password('123'), isNotNull);
    });
    test('6 caracteres passa', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('quantity', () {
    test('negativa da erro', () {
      expect(Validators.quantity('-1'), isNotNull);
    });
    test('texto da erro', () {
      expect(Validators.quantity('abc'), isNotNull);
    });
    test('zero passa', () {
      expect(Validators.quantity('0'), isNull);
    });
  });

  group('price', () {
    test('aceita virgula', () {
      expect(Validators.parsePrice('12,50'), 12.5);
      expect(Validators.price('12,50'), isNull);
    });
    test('negativo da erro', () {
      expect(Validators.price('-3'), isNotNull);
    });
  });
}
