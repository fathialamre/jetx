import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Jet.toNamed('/profile'),
          child: const Text('Go to Profile'),
        ),
      ),
    );
  }
}
