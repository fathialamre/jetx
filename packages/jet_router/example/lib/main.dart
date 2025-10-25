import 'package:flutter/material.dart';
import 'package:jet/jet_router.dart';
import 'pages/router_examples_page.dart';
import 'pages/push_example_page.dart';
import 'pages/params_example_page.dart';
import 'pages/replace_example_page.dart';
import 'pages/result_example_page.dart';
import 'pages/login_page.dart';
import 'pages/protected_page.dart';
import 'guards/auth_guard.dart';

void main() {
  runApp(const MyApp());
}

// Create the router instance
final jetRouter = JetRouter(routes: appRoutes);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jet Router Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: jetRouter.routerConfig,
    );
  }
}

// Define your routes
final appRoutes = [
  // Main examples page
  JetRoute(
    path: '/',
    builder: (context, data) => const RouterExamplesPage(),
    initialRoute: true,
  ),

  // Push navigation examples
  JetRoute(
    path: '/push-example',
    builder: (context, data) => const PushExamplePage(),
    transition: const TransitionType.slideRight(),
  ),
  JetRoute(
    path: '/push-example-2',
    builder: (context, data) => const PushExamplePage2(),
    transition: const TransitionType.slideLeft(),
  ),

  // Parameters and arguments examples
  JetRoute(
    path: '/params-example',
    builder: (context, data) => const ParamsExamplePage(),
    transition: const TransitionType.fade(),
  ),
  JetRoute(
    path: '/user/:userId',
    builder: (context, data) => const UserPage(),
    transition: const TransitionType.slideUp(),
  ),
  JetRoute(
    path: '/search',
    builder: (context, data) => const SearchPage(),
    transition: const TransitionType.scale(),
  ),

  // Replace navigation examples
  JetRoute(
    path: '/replace-example',
    builder: (context, data) => const ReplaceExamplePage(),
    transition: const TransitionType.slideRight(),
  ),
  JetRoute(
    path: '/replace-target',
    builder: (context, data) => const ReplaceTargetPage(),
    transition: const TransitionType.fade(),
  ),

  // Result handling examples
  JetRoute(
    path: '/result-example',
    builder: (context, data) => const ResultExamplePage(),
    transition: const TransitionType.slideRight(),
  ),
  JetRoute(
    path: '/result-dialog',
    builder: (context, data) => const ResultDialogPage(),
    transition: const TransitionType.slideUp(),
  ),

  // Guards examples
  JetRoute(
    path: '/login',
    builder: (context, data) => const LoginPage(),
    transition: const TransitionType.slideUp(),
  ),
  JetRoute(
    path: '/protected',
    builder: (context, data) => const ProtectedPage(),
    guards: const [AuthGuard()],
    transition: const TransitionType.slideRight(),
  ),
  JetRoute(
    path: '/protected-details',
    builder: (context, data) => const ProtectedDetailsPage(),
    guards: const [AuthGuard()],
    transition: const TransitionType.slideLeft(),
  ),
];
