import 'package:flutter/material.dart';
import 'package:jetx/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

class Profile {
  final String userId;

  Profile({required this.userId});
}

@RoutablePage(path: '/profile')
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.userId,
    required this.profile,
    this.name,
  });

  final String userId;
  final Profile profile;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          children: [
            Text('Profile Page', style: TextStyle(fontSize: 24)),
            Text('User ID: $userId'),
            Text('Profile: ${profile.userId}'),
            Text('Name: $name'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Jet.toNamed('/settings'),
        child: const Icon(Icons.settings),
      ),
    );
  }
}
