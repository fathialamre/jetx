import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Example',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JetX Example')),
      body: const Center(child: Text('Home')),
    );
  }
}
