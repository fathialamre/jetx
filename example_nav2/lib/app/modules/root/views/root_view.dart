import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../../../routes/app_pages.dart';
import '../controllers/root_controller.dart';
import 'drawer.dart';

class RootView extends JetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: RouterListener(builder: (context) {
          final title = context.location;
          return Text(title);
        }),
        centerTitle: true,
      ),
      //body: HomeView(),

      body: JetRouterOutlet(
        initialRoute: Routes.home,
        anchorRoute: '/',
      ),
    );
  }
}
