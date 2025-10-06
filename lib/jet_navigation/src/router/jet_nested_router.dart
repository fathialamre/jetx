import 'package:flutter/material.dart';

import 'pages/jet_route.dart';
import 'jet_navigation_state.dart';
import 'jet_navigation_state_manager.dart';
import 'jet_route_information_parser.dart';
import 'jet_router_delegate.dart';

/// Widget for nested navigation with independent navigation stacks
///
/// This allows you to have multiple independent navigation stacks
/// within the same app, useful for bottom navigation, drawer navigation,
/// or tabbed interfaces.
///
/// Example:
/// ```dart
/// JetNestedRouter(
///   routerKey: 'profile_tab',
///   routes: profileRoutes,
///   initialRoute: '/profile',
/// )
/// ```
class JetNestedRouter extends StatefulWidget {
  /// Unique key to identify this nested router
  final String routerKey;

  /// Routes available in this nested router
  final List<JetPage> routes;

  /// Initial route for this nested router
  final String initialRoute;

  /// Optional not found page
  final JetPage? notFoundPage;

  /// Navigator observers
  final List<NavigatorObserver>? navigatorObservers;

  /// Whether to enable debug logging
  final bool enableLog;

  /// Restoration ID for state restoration
  final String? restorationId;

  const JetNestedRouter({
    required this.routerKey,
    required this.routes,
    required this.initialRoute,
    this.notFoundPage,
    this.navigatorObservers,
    this.enableLog = false,
    this.restorationId,
    super.key,
  });

  @override
  State<JetNestedRouter> createState() => _JetNestedRouterState();

  /// Get the navigation state manager for this nested router
  static JetNavigationStateManager? of(BuildContext context, String routerKey) {
    return context
        .dependOnInheritedWidgetOfExactType<_JetNestedRouterInherited>()
        ?.stateManager;
  }

  /// Try to get the navigation state manager (returns null if not found)
  static JetNavigationStateManager? maybeOf(
      BuildContext context, String routerKey) {
    return context
        .findAncestorWidgetOfExactType<_JetNestedRouterInherited>()
        ?.stateManager;
  }
}

class _JetNestedRouterState extends State<JetNestedRouter> {
  late JetNavigationStateManager _stateManager;
  late JetRouterDelegate _delegate;
  late JetRouteInformationParser _parser;
  late GlobalKey<NavigatorState> _navigatorKey;

  @override
  void initState() {
    super.initState();

    _navigatorKey = GlobalKey<NavigatorState>();

    _stateManager = JetNavigationStateManager(
      initialState: JetNavigationState.initial(widget.initialRoute),
    );

    _delegate = JetRouterDelegate(
      stateManager: _stateManager,
      navigatorKey: _navigatorKey,
      routes: widget.routes,
      notFoundPage: widget.notFoundPage,
      navigatorObservers: widget.navigatorObservers ?? [],
      enableLog: widget.enableLog,
      restorationScopeId: widget.restorationId,
    );

    _parser = JetRouteInformationParser(
      initialRoute: widget.initialRoute,
      routes: widget.routes,
      enableLog: widget.enableLog,
    );

    _registerWithParent();
  }

  /// Register this nested navigation state with parent router
  void _registerWithParent() {
    // This would integrate with the parent navigation state
    // to maintain the full navigation hierarchy
  }

  @override
  void dispose() {
    _stateManager.dispose();
    _delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get parent back button dispatcher if available
    final parentBackDispatcher = Router.maybeOf(context)?.backButtonDispatcher;

    ChildBackButtonDispatcher? childBackDispatcher;
    if (parentBackDispatcher != null) {
      childBackDispatcher = ChildBackButtonDispatcher(parentBackDispatcher);
      childBackDispatcher.takePriority();
    }

    return _JetNestedRouterInherited(
      routerKey: widget.routerKey,
      stateManager: _stateManager,
      child: Router(
        routerDelegate: _delegate,
        routeInformationParser: _parser,
        backButtonDispatcher: childBackDispatcher,
        restorationScopeId: widget.restorationId,
      ),
    );
  }
}

/// Inherited widget to provide nested router state
class _JetNestedRouterInherited extends InheritedWidget {
  final String routerKey;
  final JetNavigationStateManager stateManager;

  const _JetNestedRouterInherited({
    required this.routerKey,
    required this.stateManager,
    required super.child,
  });

  @override
  bool updateShouldNotify(_JetNestedRouterInherited oldWidget) {
    return routerKey != oldWidget.routerKey ||
        stateManager != oldWidget.stateManager;
  }
}

/// Helper for managing multiple nested routers
class JetNestedRouterManager {
  final Map<String, JetNavigationStateManager> _routers = {};

  /// Register a nested router
  void register(String key, JetNavigationStateManager stateManager) {
    _routers[key] = stateManager;
  }

  /// Unregister a nested router
  void unregister(String key) {
    _routers.remove(key);
  }

  /// Get a nested router state manager
  JetNavigationStateManager? get(String key) {
    return _routers[key];
  }

  /// Check if a router is registered
  bool has(String key) {
    return _routers.containsKey(key);
  }

  /// Get all registered router keys
  List<String> get keys => _routers.keys.toList();

  /// Clear all routers
  void clear() {
    _routers.clear();
  }

  /// Dispose all routers
  void dispose() {
    for (final manager in _routers.values) {
      manager.dispose();
    }
    _routers.clear();
  }
}
