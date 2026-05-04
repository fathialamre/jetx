import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../routes/app_router.dart';

@JetRoute(path: '/login', transition: Transition.fadeIn)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton(
          onPressed: () => Jet.goAll<void>(const HomePageRoute()),
          child: const Text('Sign in'),
        ),
      ),
    );
  }
}
