import 'package:material_ui/material_ui.dart';

import '../core/validators.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/feedback.dart';

/// Serve para cadastrar (product == null) e para editar.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _service = ProductService(AuthService.instance.currentUser!.id);

  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  late final _quantityCtrl = TextEditingController(
    text: '${widget.product?.quantity ?? 0}',
  );
  late final _priceCtrl = TextEditingController(
    text: widget.product?.price.toStringAsFixed(2).replaceAll('.', ','),
  );
  late String _category = widget.product?.category ?? Product.categories.first;
  bool _saving = false;

  bool get _editing => widget.product != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final product = Product(
      id: widget.product?.id,
      ownerId: _service.ownerId,
      name: _nameCtrl.text.trim(),
      category: _category,
      quantity: int.parse(_quantityCtrl.text.trim()),
      price: Validators.parsePrice(_priceCtrl.text)!,
    );

    if (_editing) {
      await _service.update(product);
    } else {
      await _service.create(product);
    }

    if (!mounted) return;
    showMessage(
      context,
      _editing ? 'Produto atualizado' : 'Produto cadastrado',
    );
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final ok = await confirmAction(
      context,
      title: 'Excluir produto',
      message: 'Excluir "${widget.product!.name}" do estoque?',
      confirmLabel: 'Excluir',
    );
    if (!ok) return;
    await _service.remove(widget.product!.id!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Editar produto' : 'Novo produto'),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _nameCtrl,
              label: 'Nome do produto',
              icon: Icons.label_outline,
              validator: (v) => Validators.notEmpty(v, field: 'Nome'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final c in Product.categories)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _quantityCtrl,
                    label: 'Quantidade',
                    keyboardType: TextInputType.number,
                    validator: Validators.quantity,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _priceCtrl,
                    label: r'Preço (R$)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    validator: Validators.price,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_editing ? 'Salvar alterações' : 'Cadastrar produto'),
            ),
          ],
        ),
      ),
    );
  }
}
