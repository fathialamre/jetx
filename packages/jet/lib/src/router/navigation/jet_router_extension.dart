import '../config/jet_route.dart';
import '../core/jet_router_delegate.dart';
import '../models/route_data.dart';

/// Extension class that provides router functionality through a clean API.
///
/// This class encapsulates all router-related functionality and provides
/// both navigation methods and access to router state and configuration.
///
/// Example usage:
/// ```dart
/// // Navigation
/// context.router.push('/profile/123');
/// context.router.replace('/login');
/// context.router.pop();
///
/// // Navigation with results
/// final result = await context.router.push<String>('/edit-profile');
/// if (result != null) {
///   print('Profile updated: $result');
/// }
///
/// // Return result when popping
/// context.router.pop('changes_saved');
///
/// // State access
/// final userId = context.router.pathParam('userId');
/// final query = context.router.queryParam('search');
/// final args = context.router.routeArguments<MyArguments>();
///
/// // Advanced access
/// final delegate = context.router.delegate;
/// ```
class JetRouterExtension {
  final JetRouterDelegate _delegate;

  /// Creates a new JetRouterExtension instance.
  ///
  /// [delegate] is the router delegate that handles navigation.
  JetRouterExtension(this._delegate);

  /// Gets the underlying router delegate for advanced use cases.
  JetRouterDelegate get delegate => _delegate;

  /// Pushes a new route onto the navigation stack.
  ///
  /// Returns a [Future] that completes with a result of type [T] when the
  /// pushed route is popped.
  ///
  /// [path] is the route path to navigate to.
  /// [arguments] are optional arguments to pass to the route.
  ///
  /// Example:
  /// ```dart
  /// // Navigate and await result
  /// final result = await context.router.push<String>('/profile/123');
  /// if (result != null) {
  ///   print('Profile updated: $result');
  /// }
  /// ```
  Future<T?> push<T>(String path, {Object? arguments}) async {
    return await _delegate.push<T>(path, arguments: arguments);
  }

  /// Replaces the current route with a new route.
  ///
  /// Returns a [Future] that completes with a result of type [T] when the
  /// new route is popped.
  ///
  /// [path] is the route path to navigate to.
  /// [arguments] are optional arguments to pass to the route.
  ///
  /// Example:
  /// ```dart
  /// final result = await context.router.replace<bool>('/settings');
  /// ```
  Future<T?> replace<T>(String path, {Object? arguments}) async {
    return await _delegate.replace<T>(path, arguments: arguments);
  }

  /// Pushes a new route and removes all previous routes from the stack.
  ///
  /// Returns a [Future] that completes with a result of type [T] when the
  /// new route is popped.
  ///
  /// [path] is the route path to navigate to.
  /// [arguments] are optional arguments to pass to the route.
  ///
  /// Example:
  /// ```dart
  /// await context.router.pushAndRemoveAll<void>('/login');
  /// ```
  Future<T?> pushAndRemoveAll<T>(String path, {Object? arguments}) async {
    return await _delegate.pushAndRemoveAll<T>(path, arguments: arguments);
  }

  /// Pops the current route from the navigation stack.
  ///
  /// [result] is an optional value to return to the previous route.
  ///
  /// Example:
  /// ```dart
  /// // Return a result when popping
  /// context.router.pop('user_updated');
  ///
  /// // Or with typed result
  /// context.router.pop<bool>(true);
  /// ```
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
