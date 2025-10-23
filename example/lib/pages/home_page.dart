import 'package:example/pages/profile_page.dart';
import 'package:example/router.dart';
import 'package:flutter/material.dart';
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
      body: const Center(
        child: Text('Home Page', style: TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ProfilePageRoute.push(
          userId: '123',
          profile: Profile(userId: '888'),
          name: "Fathi Alamre",
        ),
        child: const Icon(Icons.person),
      ),
    );
  }
}
