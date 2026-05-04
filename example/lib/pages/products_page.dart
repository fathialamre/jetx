import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../routes/typed_routes.dart';

const _demoProducts = ['101', '202', '303'];

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
            // Typed deep-link via codegen. Tap "View specs" on detail
            // page to see the optional ?tab=specs query param.
            onTap: () => Jet.go<void>(ProductDetailRoute(id: id)),
          );
        },
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Jet.parameters['id'] ?? '?';
    final tab = Jet.parameters['tab'];
    return Scaffold(
      appBar: AppBar(title: Text('Product $id')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product $id', style: const TextStyle(fontSize: 24)),
            if (tab != null) ...[
              const SizedBox(height: 8),
              Text('Tab: $tab'),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Jet.goReplacement<void>(
                ProductDetailRoute(id: id, tab: 'specs'),
              ),
              child: const Text('View specs'),
            ),
          ],
        ),
      ),
    );
  }
}
