import 'package:flutter/widgets.dart';
import '../config/jet_route.dart';
import '../core/jet_router_delegate.dart';
import '../models/route_data.dart';

/// Extension on BuildContext for type-safe navigation using Jet router.
extension JetNavigation on BuildContext {
  /// Gets the router delegate from the current context.
  JetRouterDelegate get _delegate {
    return Router.of(this).routerDelegate as JetRouterDelegate;
  }

  /// Pushes a new route onto the navigation stack.
  ///
  /// [path] is the route path to navigate to.
  /// [arguments] are optional arguments to pass to the route.
  Future<void> push(String path, {Object? arguments}) async {
    await _delegate.push(path, arguments: arguments);
  }

  /// Replaces the current route with a new route.
  ///
  /// [path] is the route path to navigate to.
  /// [arguments] are optional arguments to pass to the route.
  Future<void> replace(String path, {Object? arguments}) async {
    await _delegate.replace(path, arguments: arguments);
  }

  /// Pushes a new route and removes all previous routes from the stack.
  ///
  /// [path] is the route path to navigate to.
  /// [arguments] are optional arguments to pass to the route.
  Future<void> pushAndRemoveAll(String path, {Object? arguments}) async {
    await _delegate.pushAndRemoveAll(path, arguments: arguments);
  }

  /// Pops the current route from the navigation stack.
  ///
  /// [result] is an optional value to return to the previous route.
  void pop<T>([T? result]) {
    _delegate.pop<T>(result);
  }

  /// Pops routes until the predicate returns true.
  ///
  /// [predicate] is a function that tests each route.
  void popUntil(bool Function(JetRoute) predicate) {
    _delegate.popUntil(predicate);
  }

  /// Checks if the current route can be popped.
  bool canPop() {
    return _delegate.canPop();
  }

  /// Gets the current route data including path parameters and query parameters.
  RouteData? get routeData => _delegate.currentRouteData;

  /// Gets the current route.
  JetRoute? get currentRoute => _delegate.currentRoute;

  /// Gets path parameters from the current route.
  Map<String, String> get pathParams => routeData?.pathParams ?? {};

  /// Gets query parameters from the current route.
  Map<String, String> get queryParams => routeData?.queryParams ?? {};

  /// Gets arguments passed to the current route.
  T? routeArguments<T>() => routeData?.arguments as T?;

  /// Gets a specific path parameter by key.
  String? pathParam(String key) => pathParams[key];

  /// Gets a specific query parameter by key.
  String? queryParam(String key) => queryParams[key];
}
