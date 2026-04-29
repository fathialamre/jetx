import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends JetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.yellow,
          width: double.infinity,
          height: 25,
        ),
        Expanded(
          child: JetRouterOutlet.builder(
            route: Routes.home,
            builder: (context) {
              return Scaffold(
                body: JetRouterOutlet(
                  initialRoute: Routes.dashboard,
                  anchorRoute: Routes.home,
                ),
                bottomNavigationBar: IndexedRouteBuilder(
                    routes: const [
                      Routes.dashboard,
                      Routes.profile,
                      Routes.products
                    ],
                    builder: (context, routes, index) {
                      final delegate = context.delegate;
                      return BottomNavigationBar(
                        currentIndex: index,
                        onTap: (value) => delegate.toNamed(routes[value]),
                        items: const [
                          // _Paths.HOME + [Empty]
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Home',
                          ),
                          // _Paths.HOME + Routes.PROFILE
                          BottomNavigationBarItem(
                            icon: Icon(Icons.account_box_rounded),
                            label: 'Profile',
                          ),
                          // _Paths.HOME + _Paths.PRODUCTS
                          BottomNavigationBarItem(
                            icon: Icon(Icons.account_box_rounded),
                            label: 'Products',
                          ),
                        ],
                      );
                    }),
              );
            },
          ),
        ),
      ],
    );
  }
}
