class Product {
  const Product({
    this.id,
    required this.ownerId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    this.updatedAt,
  });

  static const categories = [
    'Alimentos',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Eletrônicos',
    'Outros',
  ];

  static const lowStockLimit = 5;

  final int? id;
  final int ownerId;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final DateTime? updatedAt;

  double get totalValue => quantity * price;
  bool get isLowStock => quantity <= lowStockLimit;

  Product copyWith({
    int? ownerId,
    String? name,
    String? category,
    int? quantity,
    double? price,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toRow() => {
    if (id != null) 'id': id,
    'owner_id': ownerId,
    'name': name,
    'category': category,
    'quantity': quantity,
    'price': price,
    'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
  };

  factory Product.fromRow(Map<String, Object?> row) {
    return Product(
      id: row['id'] as int?,
      ownerId: row['owner_id']! as int,
      name: row['name']! as String,
      category: row['category']! as String,
      quantity: row['quantity']! as int,
      price: (row['price']! as num).toDouble(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? ''),
    );
  }
}
