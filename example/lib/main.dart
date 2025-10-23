import 'package:flutter/material.dart';
import 'package:jet/jet.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      jetPages: [
        JetPage(name: '/', page: () => const HomePage()),
        JetPage(name: '/profile', page: () => const ProfilePage()),
        JetPage(name: '/settings', page: () => const SettingsPage()),
      ],
    );
  }
}
