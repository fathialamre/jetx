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

/// Annotation for collecting routes into a router
class JetRouter {
  const JetRouter();
}
