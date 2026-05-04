import 'package:jetx/jetx.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/products_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = <JetPage>[
    JetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    JetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    JetPage(
      name: AppRoutes.products,
      page: () => const ProductsPage(),
      transition: Transition.rightToLeft,
    ),
    JetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
