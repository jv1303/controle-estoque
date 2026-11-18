import 'package:material_ui/material_ui.dart';

import '../core/app_routes.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';
import '../widgets/product_card.dart';
import '../widgets/stock_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _user = AuthService.instance.currentUser!;
  late final _products = ProductService(_user.id);
  final _searchCtrl = TextEditingController();

  List<Product> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final result = await _products.findAll(search: _searchCtrl.text);
    if (!mounted) return;
    setState(() {
      _items = result;
      _loading = false;
    });
  }

  Future<void> _openForm([Product? product]) async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.productForm,
      arguments: product,
    );
    if (changed == true) await _refresh();
  }

  Future<void> _adjust(Product product, int delta) async {
    await _products.adjustQuantity(product, delta);
    await _refresh();
  }

  Future<void> _remove(Product product) async {
    setState(() => _items.remove(product));
    await _products.remove(product.id!);
    if (mounted) showMessage(context, '"${product.name}" removido do estoque');
    await _refresh();
  }

  Future<void> _signOut() async {
    final ok = await confirmAction(
      context,
      title: 'Encerrar sessão',
      message: 'Na próxima vez será preciso informar e-mail e senha.',
      confirmLabel: 'Encerrar',
    );
    if (!ok) return;
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Estoque'),
        actions: [
          Tooltip(
            message: _user.name,
            child: CircleAvatar(
              radius: 16,
              child: Text(_user.firstName.substring(0, 1).toUpperCase()),
            ),
          ),
          IconButton(
            tooltip: 'Encerrar sessão',
            icon: const Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo produto',
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_box_outlined),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  StockSummary(products: _items),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => _refresh(),
                    decoration: const InputDecoration(
                      hintText: 'Buscar pelo nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_items.isEmpty)
                    EmptyState(
                      message: _searchCtrl.text.isEmpty
                          ? 'Seu estoque está vazio.\n'
                                'Use o botão no canto para adicionar.'
                          : 'Nada encontrado para "${_searchCtrl.text}".',
                    )
                  else
                    for (final product in _items)
                      Dismissible(
                        key: ValueKey(product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_sweep,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (_) => confirmAction(
                          context,
                          title: 'Remover produto',
                          message: 'Tirar "${product.name}" do estoque?',
                          confirmLabel: 'Remover',
                        ),
                        onDismissed: (_) => _remove(product),
                        child: ProductCard(
                          product: product,
                          onTap: () => _openForm(product),
                          onIncrement: () => _adjust(product, 1),
                          onDecrement: () => _adjust(product, -1),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}
