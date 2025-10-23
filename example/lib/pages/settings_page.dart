import 'package:flutter/material.dart';
import 'package:jet/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

@RoutablePage(path: '/settings')
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Settings Page', style: TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Jet.back(),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
