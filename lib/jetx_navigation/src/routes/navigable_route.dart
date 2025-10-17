import 'package:jetx/jetx.dart';

/// Base class for all generated route classes.
///
/// Provides common navigation methods that all routes can use.
/// Generated route classes extend this to get navigation functionality.
abstract class NavigableRoute {
  const NavigableRoute();

  /// The path string for this route with all parameters interpolated
  String get path;

  // ==================== Basic Navigation ====================

  /// Navigate to this route
  ///
  /// Returns a Future that completes with the result when the route is popped.
  ///
  /// Example:
  /// ```dart
  /// const UserPageRoute(userId: 42).push();
  /// ```
  Future<T?>? push<T>() => Jet.toNamed<T>(path);

  /// Replace the current route with this route
  ///
  /// Pops the current route and pushes this route.
  ///
  /// Example:
  /// ```dart
  /// const HomePageRoute().pushReplacement();
  /// ```
  Future<T?>? pushReplacement<T>() => Jet.offNamed<T>(path);

  // ==================== Advanced Navigation ====================

  /// Navigate to this route and remove all previous routes until predicate is true
  ///
  /// Useful for navigation flows like logout where you want to clear the stack.
  ///
  /// Example:
  /// ```dart
  /// const LoginPageRoute().pushAndRemoveUntil((route) => false);
  /// ```
  Future<T?>? pushAndRemoveUntil<T>(bool Function(JetPage)? predicate) =>
      Jet.offNamedUntil<T>(path, predicate, arguments: null);

  /// Navigate to this route and remove all previous routes
  ///
  /// Clears the entire navigation stack and pushes this route.
  ///
  /// Example:
  /// ```dart
  /// const LoginPageRoute().pushAndRemoveAll();
  /// ```
  Future<T?>? pushAndRemoveAll<T>() => Jet.offAllNamed<T>(path);

  // ==================== Navigation with Arguments ====================

  /// Navigate to this route with custom arguments (invisible metadata)
  ///
  /// Arguments are not visible in the URL and can be any type.
  /// Use for complex objects, callbacks, or private data.
  /// Access via `Jet.arguments` in the destination page.
  ///
  /// Example:
  /// ```dart
  /// // Pass complex data (not visible in URL)
  /// const UserPageRoute(userId: 42).pushWithArgs({
  ///   'source': 'notification',
  ///   'user': userObject,  // Full object
  ///   'onComplete': () => refresh(),  // Callback
  /// });
  /// ```
  Future<T?>? pushWithArgs<T>(dynamic arguments) =>
      Jet.toNamed<T>(path, arguments: arguments);

  /// Replace current route with this route and custom arguments
  ///
  /// Example:
  /// ```dart
  /// const HomePageRoute().pushReplacementWithArgs({'refresh': true});
  /// ```
  Future<T?>? pushReplacementWithArgs<T>(dynamic arguments) =>
      Jet.offNamed<T>(path, arguments: arguments);

  /// Navigate to this route with additional query parameters
  ///
  /// Parameters become part of the URL query string and are always strings.
  /// Useful for deep linking, tracking, and URL-based state.
  ///
  /// Example:
  /// ```dart
  /// // Adds query parameters to the route
  /// const UserPageRoute(userId: 42).pushWithParameters({
  ///   'utm_source': 'email',
  ///   'tab': 'posts',
  /// });
  /// // Navigates to: /user/42?utm_source=email&tab=posts
  /// ```
  Future<T?>? pushWithParameters<T>(Map<String, String> parameters) =>
      Jet.toNamed<T>(path, parameters: parameters);

  // ==================== Utility Methods ====================

  /// Check if this route is currently active
  ///
  /// Returns true if the current route matches this route's path.
  bool get isActive => Jet.currentRoute == path;

  /// Get the route name (path)
  String get routeName => path;
}
