import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

// Simple Shopping Cart Example

class CartItem {
  final String name;
  final double price;

  CartItem({required this.name, required this.price});
}

class CartController extends JetxController {
  // Observable cart items
  final items = <CartItem>[].obs;

  // Computed: Total automatically recalculates when items change
  late final total = computed(
    () => items.fold(0.0, (sum, item) => sum + item.price),
    watch: [items],
  );

  final _random = Random();
  final _products = [
    'Laptop',
    'Mouse',
    'Keyboard',
    'Monitor',
    'Headphones',
    'Webcam',
    'Microphone',
    'Tablet',
  ];

  void addRandomItem() {
    final name = _products[_random.nextInt(_products.length)];
    final price = (_random.nextDouble() * 900 + 100); // $100-$1000
    items.add(CartItem(name: name, price: price));
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  void clearCart() {
    items.clear();
  }
}

class ReactiveExampleView extends JetView<CartController> {
  const ReactiveExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Cart Example'),
        actions: [
          Obx(
            () => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${controller.items.length} items',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Cart items list
          Expanded(
            child: Obx(() {
              if (controller.items.isEmpty) {
                return const Center(
                  child: Text(
                    'Cart is empty\nTap the button below to add items',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => controller.removeItem(index),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Total and buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Total - computed value
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${controller.total.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.addRandomItem,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add Random Product'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.clearCart,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.delete_sweep),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example app
void main() => runApp(const ReactiveExampleApp());

class ReactiveExampleApp extends StatelessWidget {
  const ReactiveExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'Simple Cart Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ReactiveExampleView(),
      initialRoute: '/',
      getPages: [
        JetPage(
          name: '/',
          page: () => const ReactiveExampleView(),
          binding: BindingsBuilder(() {
            Jet.put(CartController());
          }),
        ),
      ],
    );
  }
}
