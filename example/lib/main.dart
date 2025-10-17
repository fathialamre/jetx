import 'package:example/reactive_example.dart';
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';
import 'app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Router Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      getPages: [
        ...AppRouter.pages, // Manually registered routes
        // Additional manual routes (still supported)
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
