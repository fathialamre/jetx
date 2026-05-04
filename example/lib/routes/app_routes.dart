abstract class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const products = '/products';
  static const productDetail = '/products/:id';

  static String productDetailFor(String id) => '/products/$id';
}
