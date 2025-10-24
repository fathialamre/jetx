import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../config/jet_route.dart';
import '../config/route_config.dart';
import '../config/route_matcher.dart';
import '../models/route_data.dart';
import 'jet_page.dart';
import 'route_information_state.dart';

/// Manages the navigation stack and handles route changes.
class JetRouterDelegate extends RouterDelegate<RouteInformationState>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<RouteInformationState> {
  final RouteConfig config;
  final RouteMatcher _matcher;
  final List<JetPage> _pages = [];

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  JetRouterDelegate({
    required this.config,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : _matcher = RouteMatcher(config.routes),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    _initializeInitialRoute();
  }

  /// Initializes the router with the initial route.
  void _initializeInitialRoute() {
    final initialRoute = _matcher.findInitialRoute();
    if (initialRoute != null) {
      _pages.add(
        JetPage(
          route: initialRoute,
          data: RouteData(
            path: initialRoute.path,
            pathParams: const {},
            queryParams: const {},
          ),
          key: ValueKey(initialRoute.path),
        ),
      );
    }
  }

  /// Gets the current page stack.
  List<JetPage> get pages => List.unmodifiable(_pages);

  /// Gets the current route data.
  RouteData? get currentRouteData => _pages.isEmpty ? null : _pages.last.data;

  /// Gets the current route.
  JetRoute? get currentRoute => _pages.isEmpty ? null : _pages.last.route;

  @override
  RouteInformationState? get currentConfiguration {
    if (_pages.isEmpty) return null;
    final lastPage = _pages.last;
    return RouteInformationState(path: lastPage.data.path, data: lastPage.data);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onPopPage: _onPopPage,
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    if (_pages.isNotEmpty) {
      _pages.removeLast();
      notifyListeners();
    }

    return true;
  }

  @override
  Future<void> setNewRoutePath(RouteInformationState configuration) async {
    await _navigate(configuration.path, arguments: configuration.state);
  }

  /// Navigates to a path.
  Future<void> _navigate(
    String path, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) async {
    final match = _matcher.match(path);

    if (match == null) {
      // No route found, navigate to not found route if available
      if (config.notFoundRoute != null) {
        await _navigateToRoute(
          config.notFoundRoute!,
          RouteData(
            path: path,
            pathParams: const {},
            queryParams: const {},
            arguments: arguments,
          ),
          replace: replace,
          clearStack: clearStack,
        );
      }
      return;
    }

    // Check if we're already on this exact route (initial route scenario)
    if (_pages.length == 1 &&
        _pages.first.route.path == match.route.path &&
        arguments == null) {
      // We're already on this route (initial route), don't add it again
      return;
    }

    // Check route guards
    final canActivate = await _checkGuards(match.route);
    if (!canActivate) {
      // Find redirect from guards
      final redirectPath = await _getRedirectFromGuards(match.route);
      if (redirectPath != null) {
        await _navigate(redirectPath, arguments: arguments);
      }
      return;
    }

    // Add arguments to route data
    final dataWithArguments = RouteData(
      path: match.data.path,
      pathParams: match.data.pathParams,
      queryParams: match.data.queryParams,
      arguments: arguments,
    );

    await _navigateToRoute(
      match.route,
      dataWithArguments,
      replace: replace,
      clearStack: clearStack,
    );
  }

  /// Checks if all guards allow navigation.
  Future<bool> _checkGuards(JetRoute route) async {
    for (final guard in route.guards) {
      final canActivate = await guard.canActivate(
        navigatorKey.currentContext!,
        route,
      );
      if (!canActivate) {
        return false;
      }
    }
    return true;
  }

  /// Gets redirect path from guards.
  Future<String?> _getRedirectFromGuards(JetRoute route) async {
    for (final guard in route.guards) {
      final canActivate = await guard.canActivate(
        navigatorKey.currentContext!,
        route,
      );
      if (!canActivate) {
        return guard.redirect(navigatorKey.currentContext!, route);
      }
    }
    return null;
  }

  /// Navigates to a specific route.
  Future<void> _navigateToRoute(
    JetRoute route,
    RouteData data, {
    bool replace = false,
    bool clearStack = false,
  }) async {
    final page = JetPage(
      route: route,
      data: data,
      key: ValueKey('${route.path}_${DateTime.now().millisecondsSinceEpoch}'),
    );

    if (clearStack) {
      _pages.clear();
    }

    if (replace && _pages.isNotEmpty) {
      _pages.removeLast();
    }

    _pages.add(page);
    notifyListeners();
  }

  /// Pushes a new route onto the stack.
  Future<void> push(String path, {Object? arguments}) async {
    await _navigate(path, arguments: arguments);
  }

  /// Replaces the current route with a new one.
  Future<void> replace(String path, {Object? arguments}) async {
    await _navigate(path, arguments: arguments, replace: true);
  }

  /// Pushes a route and clears the entire stack.
  Future<void> pushAndRemoveAll(String path, {Object? arguments}) async {
    await _navigate(path, arguments: arguments, clearStack: true);
  }

  /// Pops the current route.
  void pop<T>([T? result]) {
    if (_pages.length > 1) {
      navigatorKey.currentState?.pop(result);
    }
  }

  /// Pops routes until the predicate returns true.
  void popUntil(bool Function(JetRoute) predicate) {
    while (_pages.length > 1 && !predicate(_pages.last.route)) {
      _pages.removeLast();
    }
    notifyListeners();
  }

  /// Checks if we can pop.
  bool canPop() {
    return _pages.length > 1;
  }

  @override
  Future<bool> popRoute() async {
    if (canPop()) {
      pop();
      return true;
    }
    return false;
  }
}
