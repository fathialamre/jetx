library;

/// Annotation for marking a page class as a route
class RoutePage {
  /// Custom path. If null, auto-generates from class name
  /// Examples:
  ///   null -> '/user' (from UserPage)
  ///   '/users/:id' -> explicit path with parameter
  final String? path;

  /// Route name (defaults to path)
  final String? name;

  /// Transition animation type
  final String? transition;

  /// Transition duration in milliseconds
  final int? transitionDurationMs;

  /// Fullscreen dialog
  final bool fullscreenDialog;

  /// Maintain state
  final bool maintainState;

  /// Prevent duplicate routes
  final bool preventDuplicates;

  const RoutePage({
    this.path,
    this.name,
    this.transition,
    this.transitionDurationMs,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.preventDuplicates = true,
  });
}

/// Annotation for constructor parameters
class PathParam {
  /// Parameter name in path (e.g., 'id' for ':id')
  final String? name;

  const PathParam({this.name});
}

/// Annotation for query parameters
class QueryParam {
  /// Query parameter name
  final String? name;

  /// Default value if not provided
  final Object? defaultValue;

  const QueryParam({this.name, this.defaultValue});
}

/// Annotation to explicitly mark a parameter as an argument (not in URL)
///
/// Use this to pass complex objects that shouldn't be serialized to URL.
/// Complex types like custom classes and Lists are auto-detected as arguments.
///
/// Example:
/// ```dart
/// @RoutePage(path: '/user/:userId')
/// class UserPage extends StatelessWidget {
///   final int userId;           // In URL
///   @ArgumentParam()
///   final User user;            // Passed as argument
///
///   UserPage({required this.userId, required this.user});
/// }
/// ```
class ArgumentParam {
  /// Parameter name (optional, defaults to field name)
  final String? name;

  const ArgumentParam({this.name});
}

/// Annotation for binding controllers
class RouteBinding {
  final Type controller;
  final bool lazy;
  final String? tag;
  final bool permanent;

  const RouteBinding(
    this.controller, {
    this.lazy = true,
    this.tag,
    this.permanent = false,
  });
}

/// Multiple bindings
class RouteBindings {
  final List<Type> controllers;
  final bool lazy;
  final bool permanent;

  const RouteBindings(
    this.controllers, {
    this.lazy = true,
    this.permanent = false,
  });
}

/// Annotation for dependency injection on constructor parameters
///
/// Use this to configure how dependencies should be injected and registered.
///
/// Example:
/// ```dart
/// class UserController {
///   final UserService service;
///
///   UserController(@Inject(lazy: true, tag: 'service', permanent: true) this.service);
/// }
/// ```
class Inject {
  /// Whether to use lazy initialization (default: true)
  final bool lazy;

  /// Tag for this dependency instance
  final String? tag;

  /// Whether to keep this dependency permanent (default: false)
  final bool permanent;

  /// Whether to use Jet.find() to retrieve (default: true)
  /// Set to false if this dependency should be created fresh
  final bool find;

  const Inject({
    this.lazy = true,
    this.tag,
    this.permanent = false,
    this.find = true,
  });
}

/// Annotation for route middleware
class RouteMiddleware {
  final Type middleware;
  final int priority;

  const RouteMiddleware(this.middleware, {this.priority = 0});
}

/// Multiple middlewares
class RouteMiddlewares {
  final List<Type> middlewares;

  const RouteMiddlewares(this.middlewares);
}

/// Annotation for collecting routes into a router
class JetRouter {
  const JetRouter();
}
