import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import '../controllers/user_controller.dart';

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

@RoutePage()
class UserPage extends StatelessWidget {
  final int userId;
  final String? tab;
  final User user;
  final List<String> tags;

  const UserPage({
    super.key,
    required this.userId,
    this.tab,
    required this.user,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User $userId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'User ID: $userId',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Tags: ${tags.join(', ')}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Name: ${user.name}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${user.email}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Active tab: ${tab ?? "none"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
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
