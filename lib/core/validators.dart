abstract final class Validators {
  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? notEmpty(String? value, {String field = 'Campo'}) {
    if (value == null || value.trim().isEmpty) return '$field é obrigatório';
    return null;
  }

  static String? email(String? value) {
    final error = notEmpty(value, field: 'E-mail');
    if (error != null) return error;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 6) return 'Use pelo menos 6 caracteres';
    return null;
  }

  static String? quantity(String? value) {
    final error = notEmpty(value, field: 'Quantidade');
    if (error != null) return error;
    final number = int.tryParse(value!.trim());
    if (number == null || number < 0) return 'Número inteiro, 0 ou mais';
    return null;
  }

  static String? price(String? value) {
    final error = notEmpty(value, field: 'Preço');
    if (error != null) return error;
    final number = parsePrice(value!);
    if (number == null || number < 0) return 'Preço inválido';
    return null;
  }

  /// aceita "12,50" e "12.50"
  static double? parsePrice(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));
}
