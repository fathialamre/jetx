import 'dart:async';
import 'package:flutter/material.dart';
import '../../../route_manager.dart';

/// Modern Navigator 2.0 router delegate with declarative state management
///
/// This implementation fully embraces declarative navigation where the
/// navigation stack is derived from app state rather than being imperatively
/// manipulated.
class JetRouterDelegate extends RouterDelegate<JetNavigationState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<JetNavigationState> {
  /// The state manager that holds the navigation state
  final JetNavigationStateManager stateManager;

  /// Navigator key for controlling the Navigator widget
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  /// List of available routes
  final List<JetPage> routes;

  /// Page to show when route is not found
  final JetPage? notFoundPage;

  /// Route tree for matching routes
  final ParseRouteTree _routeTree;

  /// Navigator observers for tracking navigation events
  final List<NavigatorObserver> navigatorObservers;

  /// Transition delegate for custom transitions
  final TransitionDelegate<dynamic>? transitionDelegate;

  /// Whether to enable debug logging
  final bool enableLog;

  /// Restoration scope ID for state restoration
  final String? restorationScopeId;

  /// Completer for the current page (for awaiting navigation results)
  final Map<String, Completer<dynamic>> _completers = {};

  JetRouterDelegate({
    required this.stateManager,
    required this.navigatorKey,
    required this.routes,
    this.notFoundPage,
    this.navigatorObservers = const [],
    this.transitionDelegate,
    this.enableLog = false,
    this.restorationScopeId,
  }) : _routeTree = ParseRouteTree(routes: routes) {
    // Listen to state manager changes
    stateManager.addListener(_onStateChanged);

    // Add default 404 page if not provided
    if (notFoundPage != null) {
      _routeTree.addRoute(notFoundPage!);
    }

    _log('JetRouterDelegate initialized with ${routes.length} routes');
  }

  /// Current navigation state
  @override
  JetNavigationState? get currentConfiguration => stateManager.state;

  /// Build the Navigator widget with declarative pages
  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(context);

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: _onPopPage,
      observers: navigatorObservers,
      transitionDelegate:
          transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
      restorationScopeId: restorationScopeId,
    );
  }

  /// Build the list of pages from the current navigation state
  List<Page> _buildPages(BuildContext context) {
    final state = stateManager.state;

    if (state.pages.isEmpty) {
      _log('No pages in state, showing not found');
      return [_buildNotFoundPage('/')];
    }

    final pages = <Page>[];

    for (var i = 0; i < state.pages.length; i++) {
      final pageConfig = state.pages[i];
      final page = _buildPage(pageConfig, context);
      pages.add(page);
    }

    return pages;
  }

  /// Build a single page from a page configuration
  Page _buildPage(JetPageConfiguration config, BuildContext context) {
    // Find matching route
    final matchedRoute = _matchRoute(config.path);

    if (matchedRoute == null) {
      _log('Route not found for path: ${config.path}');
      return _buildNotFoundPage(config.path);
    }

    // Create a decoder for middleware processing
    final uri = Uri.parse(config.path);
    final pageSettings = PageSettings(uri);
    pageSettings.params.addAll(config.parameters);

    // Apply middleware if any
    final processedRoute = matchedRoute.copyWith(
      arguments: config.arguments ?? pageSettings,
      parameters: config.parameters,
      key: ValueKey(config.key ?? config.path),
    );

    return processedRoute;
  }

  /// Build the not found page
  Page _buildNotFoundPage(String path) {
    final page = notFoundPage ??
        JetPage(
          name: '/404',
          page: () => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Page Not Found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('The page "$path" could not be found.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      stateManager.offAll('/');
                    },
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );

    return page.copyWith(key: ValueKey('404-$path'));
  }

  /// Match a route path to a JetPage
  JetPage? _matchRoute(String path) {
    try {
      final matchResult = _routeTree.matchRoute(path);
      return matchResult?.route;
    } catch (e) {
      _log('Error matching route for path: $path, error: $e');
      return null;
    }
  }

  /// Handle pop page events
  bool _onPopPage(Route<dynamic> route, dynamic result) {
    // Complete any pending completer for this route
    final routeName = route.settings.name;
    if (routeName != null && _completers.containsKey(routeName)) {
      final completer = _completers.remove(routeName);
      if (!completer!.isCompleted) {
        completer.complete(result);
      }
    }

    // If the route didn't pop, return false
    if (!route.didPop(result)) {
      return false;
    }

    // Update state manager
    return stateManager.pop(result);
  }

  /// Set new route path (called by the framework when URL changes)
  @override
  Future<void> setNewRoutePath(JetNavigationState configuration) async {
    _log('setNewRoutePath called with: ${configuration.fullPath}');

    // Run middleware for the target page
    if (configuration.currentPage != null) {
      final canNavigate =
          await _runMiddleware(configuration.currentPage!, configuration);

      if (!canNavigate) {
        _log('Navigation blocked by middleware');
        return;
      }
    }

    stateManager.setState(configuration);
  }

  /// Run middleware for a page configuration
  Future<bool> _runMiddleware(
    JetPageConfiguration pageConfig,
    JetNavigationState targetState,
  ) async {
    // Navigator 2.0 uses guards instead of middleware
    // Guards should be implemented at the state manager level before navigation
    // Example: stateManager.addGuard((route) => canAccess(route));
    return true;
  }

  /// Push a new page and return a Future that completes with the result
  Future<T?> pushNamed<T>(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
  }) {
    final completer = Completer<T?>();
    _completers[path] = completer;

    stateManager.pushNamed(
      path,
      arguments: arguments,
      parameters: parameters,
    );

    return completer.future;
  }

  /// Replace current page and return a Future
  Future<T?> replaceNamed<T>(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
  }) {
    final completer = Completer<T?>();
    _completers[path] = completer;

    stateManager.replaceNamed(
      path,
      arguments: arguments,
      parameters: parameters,
    );

    return completer.future;
  }

  /// Navigate to a path
  Future<T?> navigateTo<T>(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
  }) {
    final completer = Completer<T?>();
    _completers[path] = completer;

    stateManager.navigateTo(
      path,
      arguments: arguments,
      parameters: parameters,
    );

    return completer.future;
  }

  /// Clear all and navigate to a new page
  void offAll(String path, {Object? arguments}) {
    stateManager.offAll(path, arguments: arguments);
  }

  /// Pop the current page
  void pop<T>([T? result]) {
    stateManager.pop<T>(result);
  }

  /// Pop until a predicate is satisfied
  void popUntil(bool Function(JetPageConfiguration) predicate) {
    stateManager.popUntil(predicate);
  }

  /// Handle state changes from the state manager
  void _onStateChanged() {
    _log('Navigation state changed: ${stateManager.currentPath}');
    notifyListeners();
  }

  /// Add a new route dynamically
  void addRoute(JetPage page) {
    _routeTree.addRoute(page);
    _log('Route added: ${page.name}');
  }

  /// Remove a route dynamically
  void removeRoute(JetPage page) {
    _routeTree.removeRoute(page);
    _log('Route removed: ${page.name}');
  }

  /// Get all registered routes
  List<JetPage> get registeredRoutes => _routeTree.routes;

  /// Log debug messages
  void _log(String message) {
    if (enableLog) {
      debugPrint('[JetRouterDelegate] $message');
    }
  }

  @override
  void dispose() {
    stateManager.removeListener(_onStateChanged);

    // Complete any pending completers
    for (final completer in _completers.values) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
    _completers.clear();

    super.dispose();
  }

  /// Get the current page configuration
  JetPageConfiguration? get currentPage => stateManager.state.currentPage;

  /// Get the current path
  String get currentPath => stateManager.currentPath;

  /// Check if we can pop
  bool get canPop => stateManager.canGoBack;
}
