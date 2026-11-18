import 'package:material_ui/material_ui.dart';

import '../core/formatters.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Text(product.category.substring(0, 1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: text.titleMedium),
                    Text(
                      '${product.category} · ${formatMoney(product.price)}',
                      style: text.bodySmall,
                    ),
                    if (product.isLowStock)
                      Text(
                        'Estoque baixo',
                        style: text.labelSmall?.copyWith(color: colors.error),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tirar 1',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: product.quantity > 0 ? onDecrement : null,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${product.quantity}',
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Somar 1',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onIncrement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
