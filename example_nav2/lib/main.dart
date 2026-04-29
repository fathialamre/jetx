import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import './services/auth_service.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    JetMaterialApp(
      title: "Application",
      binds: [
        Bind.put(AuthService()),
      ],
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
      // builder: (context, child) {
      //   return FutureBuilder<void>(
      //     key: ValueKey('initFuture'),
      //     future: Jet.find<SplashService>().init(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.done) {
      //         return child ?? SizedBox.shrink();
      //       }
      //       return SplashView();
      //     },
      //   );
      // },
      // routeInformationParser: JetInformationParser(
      //     // initialRoute: Routes.HOME,
      //     ),
      // routerDelegate: JetDelegate(
      //   backButtonPopMode: PopMode.History,
      //   preventDuplicateHandlingMode:
      //       PreventDuplicateHandlingMode.ReorderRoutes,
      // ),
    ),
  );
}
