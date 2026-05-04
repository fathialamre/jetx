import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../routes/typed_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton(
          // Typed navigation via jetx_builder-generated routes — no
          // string literals at the call site.
          onPressed: () => Jet.goAll<void>(const HomeRoute()),
          child: const Text('Sign in'),
        ),
      ),
    );
  }
}
