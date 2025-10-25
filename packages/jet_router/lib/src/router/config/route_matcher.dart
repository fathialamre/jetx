import '../models/route_data.dart';
import '../models/route_match.dart';
import 'jet_route.dart';

/// Matches route paths against configured routes.
class RouteMatcher {
  final List<JetRoute> routes;

  RouteMatcher(this.routes);

  /// Matches a path against the configured routes.
  /// Returns null if no route matches.
  RouteMatch? match(String path) {
    // Parse the path and extract query parameters
    final uri = Uri.parse(path);
    final pathWithoutQuery = uri.path;
    final queryParams = uri.queryParameters;

    // Try to find a matching route
    for (final route in routes) {
      final pathParams = _matchPath(route.path, pathWithoutQuery);
      if (pathParams != null) {
        return RouteMatch(
          route: route,
          data: RouteData(
            path: pathWithoutQuery,
            pathParams: pathParams,
            queryParams: queryParams,
          ),
        );
      }
    }

    return null;
  }

  /// Attempts to match a route pattern against a path.
  /// Returns path parameters if matched, null otherwise.
  Map<String, String>? _matchPath(String pattern, String path) {
    // Convert the pattern to a regex
    final paramNames = <String>[];
    var regexPattern = pattern.replaceAllMapped(RegExp(r':([^/]+)'), (match) {
      paramNames.add(match.group(1)!);
      return r'([^/]+)';
    });

    // Escape special regex characters except for our parameter placeholders
    regexPattern = '^$regexPattern\$';

    final regex = RegExp(regexPattern);
    final match = regex.firstMatch(path);

    if (match == null) return null;

    // Extract parameter values
    final params = <String, String>{};
    for (var i = 0; i < paramNames.length; i++) {
      params[paramNames[i]] = match.group(i + 1)!;
    }

    return params;
  }

  /// Finds the initial route (the one marked with initialRoute: true).
  JetRoute? findInitialRoute() {
    try {
      return routes.firstWhere((route) => route.initialRoute);
    } catch (_) {
      return null;
    }
  }

  /// Finds a route by name.
  JetRoute? findRouteByName(String name) {
    try {
      return routes.firstWhere((route) => route.routeName == name);
    } catch (_) {
      return null;
    }
  }
}
