import 'package:flutter_test/flutter_test.dart';
import 'package:meu_estoque/models/product.dart';

void main() {
  const arroz = Product(
    id: 7,
    ownerId: 1,
    name: 'Arroz 5kg',
    category: 'Alimentos',
    quantity: 4,
    price: 25.0,
  );

  test('valor total = quantidade x preco', () {
    expect(arroz.totalValue, 100.0);
  });

  test('ate 5 unidades conta como estoque baixo', () {
    expect(arroz.isLowStock, isTrue);
    expect(arroz.copyWith(quantity: 6).isLowStock, isFalse);
  });

  test('toRow e fromRow devolvem o mesmo produto', () {
    final back = Product.fromRow(arroz.toRow());
    expect(back.id, arroz.id);
    expect(back.name, arroz.name);
    expect(back.quantity, arroz.quantity);
    expect(back.price, arroz.price);
  });
}
