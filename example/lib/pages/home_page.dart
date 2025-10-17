import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import '../app_router.dart';
import 'user_page.dart'; // Import User class

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Jet.toNamed('/profile'),
              child: const Text('Go to Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Create a User object to pass
                final user = User(
                  id: 133,
                  name: 'Fathi Alamre',
                  email: 'john@example.com',
                );
                // Pass both URL parameters and complex object
                UserPageRoute(
                  userId: 133,
                  tab: 'posts',
                  user: user,
                  tags: [
                    'flutter',
                    'dart',
                  ], // Complex object passed as argument
                ).push();
              },
              child: const Text('Go to User (Type-Safe)'),
            ),
          ],
        ),
      ),
    );
  }
}
