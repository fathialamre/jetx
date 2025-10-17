import 'route_config.dart';

class RouterConfig {
  final String className;
  final List<RouteConfig> routes;
  final Map<String, String> imports; // className -> import path

  RouterConfig({
    required this.className,
    required this.routes,
    required this.imports,
  });
}
