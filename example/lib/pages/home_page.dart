import 'package:example/pages/computed_example_page.dart';
import 'package:example/pages/profile_page.dart';
import 'package:example/router.dart';
import 'package:flutter/material.dart';
import 'package:jetx/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

@RoutablePage(path: '/home')
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('JetX Examples', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ComputedExamplePageRoute.push();
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Computed Observable Demo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ProfilePageRoute.push(
                  userId: '123',
                  profile: Profile(userId: '888'),
                  name: "Fathi Alamre",
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Profile Page'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
