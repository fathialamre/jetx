import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'pages/jet_route.dart';
import 'pages/parse_route_tree.dart';
import 'jet_navigation_state.dart';

/// Enhanced route information parser for Navigator 2.0
///
/// This parser handles:
/// - Deep linking with progressive stack building
/// - Path parameter extraction
/// - Query parameter parsing
/// - State restoration
/// - Nested routes
class JetRouteInformationParser
    extends RouteInformationParser<JetNavigationState> {
  /// Initial route to use when path is empty
  final String initialRoute;

  /// List of available routes for matching
  final List<JetPage> routes;

  /// Route tree for efficient route matching
  final ParseRouteTree _routeTree;

  /// Whether to build a progressive navigation stack for deep links
  /// e.g., /users/123/profile -> ['/users', '/users/123', '/users/123/profile']
  final bool buildProgressiveStack;

  /// Whether to enable debug logging
  final bool enableLog;

  JetRouteInformationParser({
    required this.initialRoute,
    required this.routes,
    this.buildProgressiveStack = true,
    this.enableLog = false,
  }) : _routeTree = ParseRouteTree(routes: routes) {
    _log('JetRouteInformationParser initialized with ${routes.length} routes');
  }

  @override
  Future<JetNavigationState> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    var path = uri.path;

    _log('Parsing route: $path');

    // Handle empty or root path
    if (path.isEmpty || path == '/') {
      // Check if there's a registered route for '/'
      final hasRootRoute = routes.any((route) => route.name == '/');

      if (!hasRootRoute && path == '/') {
        path = initialRoute;
        _log('No root route registered, using initial route: $initialRoute');
      } else if (path.isEmpty) {
        path = initialRoute;
      }
    }

    // Extract path segments
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    // Build navigation stack
    final pages = buildProgressiveStack
        ? _buildProgressiveStack(segments, uri.queryParameters)
        : [_buildSinglePage(path, uri.queryParameters)];

    // Restore state from routeInformation.state if available
    if (routeInformation.state != null &&
        routeInformation.state is Map<String, dynamic>) {
      try {
        final restoredState = JetNavigationState.fromJson(
          routeInformation.state as Map<String, dynamic>,
        );
        _log('Restored state from route information');
        return restoredState;
      } catch (e) {
        _log('Failed to restore state: $e');
        // Continue with normal parsing
      }
    }

    // Extract path and query parameters
    final pathParams = _extractPathParameters(path);

    return JetNavigationState(
      pages: pages,
      currentIndex: pages.length - 1,
      queryParameters: uri.queryParameters,
      pathParameters: pathParams,
      historyId: DateTime.now().microsecondsSinceEpoch.toString(),
    );
  }

  @override
  RouteInformation? restoreRouteInformation(JetNavigationState configuration) {
    _log('Restoring route information');

    if (configuration.pages.isEmpty) {
      return RouteInformation(
        uri: Uri.parse(initialRoute),
        state: configuration.toJson(),
      );
    }

    // Get the current page
    final currentPage = configuration.currentPage;
    if (currentPage == null) {
      return RouteInformation(
        uri: Uri.parse(initialRoute),
        state: configuration.toJson(),
      );
    }

    // Build URI with query parameters
    final uri = Uri(
      path: currentPage.path,
      queryParameters: configuration.queryParameters.isNotEmpty
          ? configuration.queryParameters.map(
              (key, value) => MapEntry(key, value.toString()),
            )
          : null,
    );

    return RouteInformation(
      uri: uri,
      state: configuration.toJson(), // For state restoration
    );
  }

  /// Build a progressive navigation stack for deep links
  ///
  /// For example: /users/123/profile becomes:
  /// - /users (if it exists as a route)
  /// - /users/123 (if it exists as a route)
  /// - /users/123/profile
  ///
  /// This allows proper back navigation and maintains context.
  List<JetPageConfiguration> _buildProgressiveStack(
    List<String> segments,
    Map<String, String> queryParams,
  ) {
    final pages = <JetPageConfiguration>[];
    var currentPath = '';

    for (var i = 0; i < segments.length; i++) {
      currentPath = currentPath.isEmpty
          ? '/${segments[i]}'
          : '$currentPath/${segments[i]}';

      // Check if this path corresponds to an actual route
      final matchedRoute = _findMatchingRoute(currentPath);

      if (matchedRoute != null) {
        // Extract path parameters for this level
        final pathParams = _extractPathParameters(currentPath);

        pages.add(JetPageConfiguration(
          path: currentPath,
          name: matchedRoute.name,
          parameters: pathParams,
          key: '$currentPath-${pages.length}',
        ));

        _log('Added page to stack: $currentPath (${matchedRoute.name})');
      } else {
        // For the final segment, add it even if it doesn't match
        // (it will show a 404 page)
        if (i == segments.length - 1) {
          pages.add(JetPageConfiguration(
            path: currentPath,
            parameters: _extractPathParameters(currentPath),
            key: '$currentPath-${pages.length}',
          ));
          _log('Added final page to stack (no match): $currentPath');
        }
      }
    }

    // If no pages were added, add the initial route
    if (pages.isEmpty) {
      final pathParams = _extractPathParameters(initialRoute);
      pages.add(JetPageConfiguration(
        path: initialRoute,
        parameters: pathParams,
        key: 'initial-0',
      ));
      _log('No pages matched, added initial route: $initialRoute');
    }

    return pages;
  }

  /// Build a single page configuration (non-progressive)
  JetPageConfiguration _buildSinglePage(
    String path,
    Map<String, String> queryParams,
  ) {
    final matchedRoute = _findMatchingRoute(path);
    final pathParams = _extractPathParameters(path);

    return JetPageConfiguration(
      path: path,
      name: matchedRoute?.name,
      parameters: pathParams,
      key: 'page-$path',
    );
  }

  /// Find a matching route for the given path
  JetPage? _findMatchingRoute(String path) {
    try {
      final matchResult = _routeTree.matchRoute(path);
      return matchResult?.route;
    } catch (e) {
      _log('Error finding route for path: $path, error: $e');
      return null;
    }
  }

  /// Extract path parameters from a URL path
  ///
  /// For example: /users/:id/posts/:postId with /users/123/posts/456
  /// Returns: {'id': '123', 'postId': '456'}
  Map<String, String> _extractPathParameters(String path) {
    final params = <String, String>{};

    try {
      final matchedRoute = _findMatchingRoute(path);
      if (matchedRoute == null) return params;

      // Use the route's regex to extract parameters
      final pathDecoded = matchedRoute.path;
      final match = pathDecoded.regex.firstMatch(path);

      if (match != null && pathDecoded.keys.isNotEmpty) {
        for (var i = 0; i < pathDecoded.keys.length; i++) {
          final key = pathDecoded.keys[i];
          if (key != null && match.groupCount > i) {
            final value = match.group(i + 1);
            if (value != null) {
              params[key] = Uri.decodeComponent(value);
            }
          }
        }
      }
    } catch (e) {
      _log('Error extracting path parameters: $e');
    }

    return params;
  }

  /// Parse a complete URL string into a navigation state
  JetNavigationState parseUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.isEmpty ? '/' : uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    final pages = buildProgressiveStack
        ? _buildProgressiveStack(segments, uri.queryParameters)
        : [_buildSinglePage(path, uri.queryParameters)];

    final pathParams = _extractPathParameters(path);

    return JetNavigationState(
      pages: pages,
      currentIndex: pages.length - 1,
      queryParameters: uri.queryParameters,
      pathParameters: pathParams,
    );
  }

  /// Check if a route exists for the given path
  bool hasRoute(String path) {
    return _findMatchingRoute(path) != null;
  }

  /// Get all registered route paths
  List<String> get registeredPaths {
    return routes.map((route) => route.name).toList();
  }

  /// Add a new route dynamically
  void addRoute(JetPage route) {
    _routeTree.addRoute(route);
    _log('Route added: ${route.name}');
  }

  /// Remove a route dynamically
  void removeRoute(JetPage route) {
    _routeTree.removeRoute(route);
    _log('Route removed: ${route.name}');
  }

  /// Log debug messages
  void _log(String message) {
    if (enableLog) {
      debugPrint('[JetRouteInformationParser] $message');
    }
  }
}

/// Helper extension for route parsing
extension RouteParsingExtension on String {
  /// Check if this string is a valid route path
  bool get isValidRoutePath {
    return startsWith('/') && isNotEmpty;
  }

  /// Normalize a route path
  String get normalizedPath {
    var path = this;

    // Ensure starts with /
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    // Remove trailing slash (except for root)
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  /// Split path into segments
  List<String> get pathSegments {
    return split('/').where((s) => s.isNotEmpty).toList();
  }
}
