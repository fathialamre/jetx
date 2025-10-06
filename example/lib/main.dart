import 'package:example/app_rotuer.dart';
import 'package:flutter/material.dart';
import 'package:jet/jet_navigation/src/root/jet_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Navigator 2.0 Demo',
      routes: routes,
      initialRoute: '/',

      // Theme configuration
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Enable debug logging
      enableLog: true,
    );
  }
}
