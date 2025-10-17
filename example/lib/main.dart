import 'package:example/reactive_example.dart';
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Simple Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const HomePage()),
        JetPage(name: '/profile', page: () => const ProfilePage()),
        JetPage(
          name: '/reactive',
          page: () => const ReactiveExampleView(),
          binding: BindingsBuilder(() {
            Jet.put(CartController());
          }),
        ),
      ],
    );
  }
}
