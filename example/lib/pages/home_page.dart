import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../routes/typed_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => Jet.goAll<void>(const LoginRoute()),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Welcome', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Browse products'),
              onPressed: () => Jet.go<void>(const ProductsRoute()),
            ),
          ],
        ),
      ),
    );
  }
}
