import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

@RoutePage(path: '/settings')
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings Page'),
            const SizedBox(height: 16),
            const Text('Testing 3-level dependency chain:'),
            const Text('AuthService -> UserService -> UserController'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Jet.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
