import 'package:example/router.dart';
import 'package:flutter/material.dart';
import 'package:jetx/jet.dart';

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
      initialRoute: HomePageRoute.path,
      jetPages: AppRouter.pages,
    );
  }
}
