import 'package:flutter/material.dart';
import 'package:jetx/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

class Product {
  final String name;
  final double price;
  final int quantity;

  Product(this.name, this.price, this.quantity);
}

class ProductController extends JetxController {
  // Observable list of products
  final products = <Product>[].obs;

  // Computed total that automatically updates when products list changes
  late final total = Computed(() {
    return products.fold(
      0.0,
      (sum, product) => sum + (product.price * product.quantity),
    );
  });

  void addRandomProduct() {
    final randomProducts = [
      Product('Widget', 29.99, 1),
      Product('Gadget', 49.99, 2),
      Product('Tool', 19.99, 3),
      Product('Device', 99.99, 1),
    ];

    // Add random product
    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % randomProducts.length;
    products.add(randomProducts[randomIndex]);
  }

  void clearProducts() {
    products.clear();
  }
}

@RoutablePage()
class ComputedExamplePage extends JetView<ProductController> {
  const ComputedExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Product List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total display
            Obx(
              () => Text(
                'Total: \$${controller.total.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Products list
            Expanded(
              child: Obx(() {
                if (controller.products.isEmpty) {
                  return const Center(child: Text('No products. Add some!'));
                }
                return ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        'Qty: ${product.quantity} × \$${product.price}',
                      ),
                      trailing: Text(
                        '\$${(product.price * product.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: controller.addRandomProduct,
                  child: const Text('Add Random Product'),
                ),
                ElevatedButton(
                  onPressed: controller.clearProducts,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
