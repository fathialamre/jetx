import 'package:flutter/widgets.dart';
import '../config/jet_route.dart';
import '../config/route_config.dart';
import '../deep_linking/url_strategy.dart';
import 'jet_route_information_parser.dart';
import 'jet_router_delegate.dart';
import 'route_information_state.dart';

/// Main router configuration class that encapsulates all routing components.
///
/// JetRouter provides a clean, unified API for configuring Flutter's Navigator 2.0
/// routing system. It manages the creation and lifecycle of router delegates,
/// parsers, and dispatchers.
///
/// Example usage:
/// ```dart
/// final jetRouter = JetRouter(
///   routes: [
///     JetRoute(
///       path: '/',
///       builder: (context, data) => HomePage(),
///       initialRoute: true,
///     ),
///     JetRoute(
///       path: '/profile/:userId',
///       builder: (context, data) => ProfilePage(
///         userId: data.pathParams['userId']!,
///       ),
///     ),
///   ],
/// );
///
/// MaterialApp.router(
///   routerDelegate: jetRouter.routerDelegate,
///   routeInformationParser: jetRouter.routeInformationParser,
///   backButtonDispatcher: jetRouter.backButtonDispatcher,
/// );
///
/// // Or use the modern RouterConfig API:
/// MaterialApp.router(
///   routerConfig: jetRouter.routerConfig,
/// );
/// ```
class JetRouter {
  /// List of routes for the application.
  final List<JetRoute> routes;

  /// Optional initial route path.
  /// If not provided, the route marked with `initialRoute: true` will be used.
  final String? initialRoute;

  /// Whether to use hash-based URLs on web (e.g., `/#/path`).
  ///
  /// - `false` (default): Uses path-based URLs (`/path`)
  /// - `true`: Uses hash-based URLs (`/#/path`)
  ///
  /// Only affects web platform. Has no effect on mobile platforms.
  final bool useHashUrl;

  /// Optional navigator key for accessing the navigator state.
  ///
  /// If not provided, a new key will be created automatically.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Optional route to show when a path is not found.
  final JetRoute? notFoundRoute;

  /// Lazy-initialized router delegate that manages the navigation stack.
  late final JetRouterDelegate routerDelegate;

  /// Lazy-initialized route information parser that converts URLs to route data.
  late final JetRouteInformationParser routeInformationParser;

  /// Back button dispatcher for handling system back button events.
  late final BackButtonDispatcher backButtonDispatcher;

  /// Creates a new JetRouter instance.
  ///
  /// [routes] is required and must contain at least one route marked as initial.
  ///
  /// [initialRoute] can override the default initial route.
  ///
  /// [useHashUrl] configures URL strategy for web (default: false).
  ///
  /// [navigatorKey] allows external access to the navigator state.
  ///
  /// [notFoundRoute] specifies a custom 404 page.
  JetRouter({
    required this.routes,
    this.initialRoute,
    this.useHashUrl = false,
    this.navigatorKey,
    this.notFoundRoute,
  }) {
    _initialize();
  }

  /// Initializes all router components.
  void _initialize() {
    // Set URL strategy for web
    if (useHashUrl) {
      setHashUrlStrategy();
    } else {
      setPathUrlStrategy();
    }

    // Create route configuration
    final config = RouteConfig(
      routes: routes,
      initialRoute: initialRoute,
      notFoundRoute: notFoundRoute,
    );

    // Initialize router delegate
    routerDelegate = JetRouterDelegate(
      config: config,
      navigatorKey: navigatorKey,
    );

    // Initialize route information parser
    routeInformationParser = JetRouteInformationParser(
      initialRoute: initialRoute ?? config.initialRoute ?? '/',
    );

    // Initialize back button dispatcher
    backButtonDispatcher = RootBackButtonDispatcher();
  }

  /// Returns a RouterConfig for use with MaterialApp.router.
  ///
  /// This is a convenience getter that bundles all router components
  /// into a single configuration object for newer Flutter versions.
  ///
  /// Example:
  /// ```dart
  /// MaterialApp.router(
  ///   routerConfig: jetRouter.routerConfig,
  /// );
  /// ```
  RouterConfig<RouteInformationState> get routerConfig {
    return RouterConfig(
      routerDelegate: routerDelegate,
      backButtonDispatcher: backButtonDispatcher,
    );
  }

  /// Disposes of router resources.
  ///
  /// This should be called when the router is no longer needed to clean up
  /// resources and prevent memory leaks.
  void dispose() {
    routerDelegate.dispose();
  }
}
