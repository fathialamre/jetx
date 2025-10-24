import 'jet_route.dart';

/// Configuration for the Jet router.
class RouteConfig {
  /// List of all routes in the application.
  final List<JetRoute> routes;

  /// The path for the initial route.
  /// If not specified, the router will use the route marked with initialRoute: true.
  final String? initialRoute;

  /// The route to show when no route matches (404 page).
  final JetRoute? notFoundRoute;

  const RouteConfig({
    required this.routes,
    this.initialRoute,
    this.notFoundRoute,
  });

  /// Merges multiple route configurations into one.
  static RouteConfig merge(List<RouteConfig> configs) {
    final allRoutes = <JetRoute>[];
    String? initialRoute;
    JetRoute? notFoundRoute;

    for (final config in configs) {
      allRoutes.addAll(config.routes);
      initialRoute ??= config.initialRoute;
      notFoundRoute ??= config.notFoundRoute;
    }

    return RouteConfig(
      routes: allRoutes,
      initialRoute: initialRoute,
      notFoundRoute: notFoundRoute,
    );
  }

  /// Creates a copy of this configuration with modified properties.
  RouteConfig copyWith({
    List<JetRoute>? routes,
    String? initialRoute,
    JetRoute? notFoundRoute,
  }) {
    return RouteConfig(
      routes: routes ?? this.routes,
      initialRoute: initialRoute ?? this.initialRoute,
      notFoundRoute: notFoundRoute ?? this.notFoundRoute,
    );
  }
}
