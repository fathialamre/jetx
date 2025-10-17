import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Jet.back(),
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () => Jet.toNamed('/reactive'),
              child: const Text('Go to Reactive Example'),
            ),
          ],
        ),
      ),
    );
  }
}
