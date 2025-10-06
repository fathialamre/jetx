import 'package:flutter/material.dart';

import 'pages/jet_route.dart';
import 'jet_navigation_state.dart';
import 'jet_navigation_state_manager.dart';
import 'jet_route_information_parser.dart';
import 'jet_router_delegate.dart';

/// Modern RouterConfig implementation for Navigator 2.0
///
/// This provides a simpler API for configuring the router using the
/// modern RouterConfig approach (Flutter 3.0+).
///
/// Usage:
/// ```dart
/// MaterialApp.router(
///   routerConfig: JetRouterConfig(
///     routes: myRoutes,
///     initialRoute: '/',
///   ),
/// )
/// ```
class JetRouterConfig extends RouterConfig<JetNavigationState> {
  /// The router delegate
  final JetRouterDelegate routerDelegate;

  /// The route information parser
  final JetRouteInformationParser routeInformationParser;

  /// The navigation state manager
  final JetNavigationStateManager stateManager;

  factory JetRouterConfig({
    required List<JetPage> routes,
    String initialRoute = '/',
    JetPage? notFoundPage,
    List<NavigatorObserver>? navigatorObservers,
    GlobalKey<NavigatorState>? navigatorKey,
    bool buildProgressiveStack = true,
    bool enableLog = false,
    String? restorationScopeId,
    JetNavigationStateManager? stateManager,
    RouteInformationProvider? routeInformationProvider,
    BackButtonDispatcher? backButtonDispatcher,
  }) {
    // Use singleton instance for navigation, initializing with routes if needed
    JetNavigationStateManager manager;
    if (stateManager != null) {
      manager = stateManager;
    } else {
      // Try to get existing instance or create new one
      try {
        manager = JetNavigationStateManager.instance;
        // If instance exists but has wrong initial route, update it
        if (manager.state.pages.isEmpty ||
            manager.currentPath != initialRoute) {
          manager.pushNamed(initialRoute);
        }
      } catch (e) {
        // Instance doesn't exist, initialize it
        JetNavigationStateManager.initialize(
          initialState: JetNavigationState.initial(initialRoute),
        );
        manager = JetNavigationStateManager.instance;
      }
    }

    final parser = JetRouteInformationParser(
      initialRoute: initialRoute,
      routes: routes,
      buildProgressiveStack: buildProgressiveStack,
      enableLog: enableLog,
    );

    final delegate = JetRouterDelegate(
      stateManager: manager,
      navigatorKey: navigatorKey ?? GlobalKey<NavigatorState>(),
      routes: routes,
      notFoundPage: notFoundPage,
      navigatorObservers: navigatorObservers ?? [],
      enableLog: enableLog,
      restorationScopeId: restorationScopeId,
    );

    return JetRouterConfig._(
      stateManager: manager,
      routeInformationParser: parser,
      routerDelegate: delegate,
      routeInformationProvider: routeInformationProvider ??
          PlatformRouteInformationProvider(
            initialRouteInformation: RouteInformation(
              uri: Uri.parse(initialRoute),
            ),
          ),
      backButtonDispatcher: backButtonDispatcher ?? RootBackButtonDispatcher(),
    );
  }

  JetRouterConfig._({
    required this.stateManager,
    required this.routeInformationParser,
    required this.routerDelegate,
    RouteInformationProvider? routeInformationProvider,
    BackButtonDispatcher? backButtonDispatcher,
  }) : super(
          routeInformationProvider: routeInformationProvider,
          routeInformationParser: routeInformationParser,
          routerDelegate: routerDelegate,
          backButtonDispatcher: backButtonDispatcher,
        );

  /// Navigate to a named route
  Future<T?> pushNamed<T>(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
  }) {
    return routerDelegate.pushNamed<T>(
      path,
      arguments: arguments,
      parameters: parameters,
    );
  }

  /// Replace the current route
  Future<T?> replaceNamed<T>(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
  }) {
    return routerDelegate.replaceNamed<T>(
      path,
      arguments: arguments,
      parameters: parameters,
    );
  }

  /// Navigate to a route
  Future<T?> navigateTo<T>(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
  }) {
    return routerDelegate.navigateTo<T>(
      path,
      arguments: arguments,
      parameters: parameters,
    );
  }

  /// Clear all routes and navigate to a new route
  void offAll(String path, {Object? arguments}) {
    routerDelegate.offAll(path, arguments: arguments);
  }

  /// Pop the current route
  void pop<T>([T? result]) {
    routerDelegate.pop<T>(result);
  }

  /// Pop until a condition is met
  void popUntil(bool Function(JetPageConfiguration) predicate) {
    routerDelegate.popUntil(predicate);
  }

  /// Get the current navigation state
  JetNavigationState get currentState => stateManager.state;

  /// Get the current path
  String get currentPath => stateManager.currentPath;

  /// Get the current page
  JetPageConfiguration? get currentPage => stateManager.state.currentPage;

  /// Check if we can pop
  bool get canPop => stateManager.canGoBack;

  /// Add a new route dynamically
  void addRoute(JetPage page) {
    routerDelegate.addRoute(page);
    routeInformationParser.addRoute(page);
  }

  /// Remove a route dynamically
  void removeRoute(JetPage page) {
    routerDelegate.removeRoute(page);
    routeInformationParser.removeRoute(page);
  }

  /// Get all registered routes
  List<JetPage> get routes => routerDelegate.registeredRoutes;

  /// Listen to navigation state changes
  void addListener(VoidCallback listener) {
    stateManager.addListener(listener);
  }

  /// Stop listening to navigation state changes
  void removeListener(VoidCallback listener) {
    stateManager.removeListener(listener);
  }

  /// Dispose the router config
  void dispose() {
    stateManager.dispose();
    routerDelegate.dispose();
  }
}

/// Builder for creating a JetRouterConfig with a fluent API
class JetRouterConfigBuilder {
  List<JetPage> _routes = [];
  String _initialRoute = '/';
  JetPage? _notFoundPage;
  List<NavigatorObserver>? _navigatorObservers;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _buildProgressiveStack = true;
  bool _enableLog = false;
  String? _restorationScopeId;

  /// Add a single route
  JetRouterConfigBuilder addRoute(JetPage route) {
    _routes.add(route);
    return this;
  }

  /// Add multiple routes
  JetRouterConfigBuilder addRoutes(List<JetPage> routes) {
    _routes.addAll(routes);
    return this;
  }

  /// Set the initial route
  JetRouterConfigBuilder initialRoute(String route) {
    _initialRoute = route;
    return this;
  }

  /// Set the not found page
  JetRouterConfigBuilder notFoundPage(JetPage page) {
    _notFoundPage = page;
    return this;
  }

  /// Add navigator observers
  JetRouterConfigBuilder navigatorObservers(List<NavigatorObserver> observers) {
    _navigatorObservers = observers;
    return this;
  }

  /// Set the navigator key
  JetRouterConfigBuilder navigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    return this;
  }

  /// Enable/disable progressive stack building
  JetRouterConfigBuilder progressiveStack(bool enabled) {
    _buildProgressiveStack = enabled;
    return this;
  }

  /// Enable/disable debug logging
  JetRouterConfigBuilder enableLog(bool enabled) {
    _enableLog = enabled;
    return this;
  }

  /// Set restoration scope ID
  JetRouterConfigBuilder restorationScopeId(String? id) {
    _restorationScopeId = id;
    return this;
  }

  /// Build the router config
  JetRouterConfig build() {
    if (_routes.isEmpty) {
      throw StateError('At least one route must be added');
    }

    return JetRouterConfig(
      routes: _routes,
      initialRoute: _initialRoute,
      notFoundPage: _notFoundPage,
      navigatorObservers: _navigatorObservers,
      navigatorKey: _navigatorKey,
      buildProgressiveStack: _buildProgressiveStack,
      enableLog: _enableLog,
      restorationScopeId: _restorationScopeId,
    );
  }
}
