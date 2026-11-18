import '../models/product.dart';
import 'database_service.dart';

/// Todas as consultas filtram pelo dono, entao um usuario
/// nunca enxerga nem altera produto de outro.
class ProductService {
  ProductService(this.ownerId);

  final int ownerId;
  static const _table = 'products';

  Future<List<Product>> findAll({String search = ''}) async {
    final db = await DatabaseService.instance.database;
    final term = search.trim();
    final rows = await db.query(
      _table,
      where: term.isEmpty ? 'owner_id = ?' : 'owner_id = ? AND name LIKE ?',
      whereArgs: term.isEmpty ? [ownerId] : [ownerId, '%$term%'],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Product.fromRow).toList();
  }

  Future<int> create(Product product) async {
    final db = await DatabaseService.instance.database;
    final row = product
        .copyWith(ownerId: ownerId, updatedAt: DateTime.now())
        .toRow();
    return db.insert(_table, row);
  }

  Future<void> update(Product product) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      _table,
      product.copyWith(updatedAt: DateTime.now()).toRow(),
      where: 'id = ? AND owner_id = ?',
      whereArgs: [product.id, ownerId],
    );
  }

  Future<void> adjustQuantity(Product product, int delta) async {
    final newQuantity = product.quantity + delta;
    if (newQuantity < 0) return;
    await update(product.copyWith(quantity: newQuantity));
  }

  Future<void> remove(int productId) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      _table,
      where: 'id = ? AND owner_id = ?',
      whereArgs: [productId, ownerId],
    );
  }
}
