import 'package:material_ui/material_ui.dart';

import '../core/formatters.dart';
import '../models/product.dart';

class StockSummary extends StatelessWidget {
  const StockSummary({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final units = products.fold<int>(0, (sum, p) => sum + p.quantity);
    final value = products.fold<double>(0, (sum, p) => sum + p.totalValue);

    return Row(
      children: [
        _Tile(label: 'Produtos', value: '${products.length}'),
        _Tile(label: 'Unidades', value: '$units'),
        _Tile(label: 'Valor total', value: formatMoney(value)),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              FittedBox(child: Text(value, style: text.titleLarge)),
              Text(label, style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
