import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import 'routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      // Initial route resolved via the typed Route. No string literal,
      // no `AppRoutes.login` constant — the path lives on the page's
      // `@JetRoute` annotation as the single source of truth.
      initialRoute: const LoginPageRoute().location,
      getPages: AppRouter.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
