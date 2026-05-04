import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../routes/app_router.dart';

const _demoProducts = ['101', '202', '303'];

/// Per-route binding. Lifecycle: instantiated when the route is pushed,
/// `dependencies()` runs (registers controllers via `Jet.put`),
/// disposed automatically when the route is popped — see
/// `RouterReportManager`. Declared on the page's `@JetRoute(bindings:
/// [...])` annotation; the generator wires it into the JetPage
/// registration so consumers don't have to call `Jet.put` manually.
class ProductDetailBinding extends BindingsInterface<List<Bind>> {
  @override
  List<Bind> dependencies() => [
        Bind.lazyPut<ProductDetailController>(() => ProductDetailController()),
      ];
}

class ProductDetailController extends JetxController {
  /// Mock product description. Real apps would fetch from a repository.
  String descriptionFor(String id) => 'Detailed write-up for product $id.';
}

@JetRoute(path: '/products', transition: Transition.rightToLeft)
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.separated(
        itemCount: _demoProducts.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final id = _demoProducts[i];
          return ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: Text('Product $id'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Jet.go<void>(ProductDetailPageRoute(id: id)),
          );
        },
      ),
    );
  }
}

@JetRoute(
  path: '/products/:id',
  transition: Transition.rightToLeft,
  bindings: [ProductDetailBinding],
)
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.id, this.tab});

  final String id;
  final String? tab;

  @override
  Widget build(BuildContext context) {
    // Pulled out of the binding registered by ProductDetailBinding.
    // Demonstrates that Jet.find() works because the binding ran on
    // route push and will dispose on pop.
    final controller = Jet.find<ProductDetailController>();
    return Scaffold(
      appBar: AppBar(title: Text('Product $id')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product $id', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(controller.descriptionFor(id)),
            if (tab != null) ...[
              const SizedBox(height: 8),
              Text('Tab: $tab'),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Jet.goReplacement<void>(
                ProductDetailPageRoute(id: id, tab: 'specs'),
              ),
              child: const Text('View specs'),
            ),
          ],
        ),
      ),
    );
  }
}
