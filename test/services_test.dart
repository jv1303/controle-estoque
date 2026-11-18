import 'package:flutter_test/flutter_test.dart';
import 'package:meu_estoque/models/product.dart';
import 'package:meu_estoque/services/auth_service.dart';
import 'package:meu_estoque/services/database_service.dart';
import 'package:meu_estoque/services/product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// roda o sqlite de verdade no computador, sem emulador
void main() {
  final auth = AuthService.instance;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    final folder = await getDatabasesPath();
    await databaseFactory.deleteDatabase('$folder/meu_estoque.db');
    await DatabaseService.instance.database;
  });

  test('cadastro abre sessao e email repetido da erro', () async {
    final ana = await auth.register(
      name: 'Ana Souza',
      email: 'Ana@Teste.com',
      password: '123456',
    );
    expect(auth.currentUser?.id, ana.id);
    expect(ana.email, 'ana@teste.com');

    expect(
      () => auth.register(
        name: 'Outra',
        email: 'ana@teste.com',
        password: 'x1x1x1',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('login com senha errada falha e com a certa funciona', () async {
    await auth.logout();
    expect(auth.isLoggedIn, isFalse);

    expect(
      () => auth.login(email: 'ana@teste.com', password: 'errada'),
      throwsA(isA<AuthException>()),
    );
    expect(
      () => auth.login(email: 'ninguem@teste.com', password: '123456'),
      throwsA(isA<AuthException>()),
    );

    final user = await auth.login(email: 'ana@teste.com', password: '123456');
    expect(user.firstName, 'Ana');
  });

  test('sessao fica salva e volta no restoreSession', () async {
    final id = auth.currentUser!.id;
    await auth.restoreSession();
    expect(auth.currentUser?.id, id);
  });

  test('CRUD completo de produtos', () async {
    final service = ProductService(auth.currentUser!.id);

    final id = await service.create(
      const Product(
        ownerId: 0,
        name: 'Café 500g',
        category: 'Alimentos',
        quantity: 10,
        price: 18.9,
      ),
    );
    var list = await service.findAll();
    expect(list.single.id, id);
    expect(list.single.ownerId, auth.currentUser!.id);

    await service.update(list.single.copyWith(name: 'Café 1kg', price: 32));
    await service.adjustQuantity((await service.findAll()).single, -3);
    list = await service.findAll();
    expect(list.single.name, 'Café 1kg');
    expect(list.single.quantity, 7);

    expect(await service.findAll(search: 'caf'), hasLength(1));
    expect(await service.findAll(search: 'arroz'), isEmpty);

    await service.remove(id);
    expect(await service.findAll(), isEmpty);
  });

  test('um usuario nao ve produto de outro', () async {
    final anaProducts = ProductService(auth.currentUser!.id);
    await anaProducts.create(
      const Product(
        ownerId: 0,
        name: 'Sabão',
        category: 'Limpeza',
        quantity: 2,
        price: 5,
      ),
    );

    final bruno = await auth.register(
      name: 'Bruno Lima',
      email: 'bruno@teste.com',
      password: '654321',
    );
    expect(await ProductService(bruno.id).findAll(), isEmpty);
    expect(await anaProducts.findAll(), hasLength(1));
  });
}
