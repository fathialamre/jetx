library jetx_annotations;

/// Annotation to mark the main router class for code generation.
///
/// Example:
/// ```dart
/// @JetRouteConfig()
/// class AppRouter {
///   static List<JetPage> get pages => _$AppRouterPages;
/// }
/// ```
class JetRouteConfig {
  /// Creates a [JetRouteConfig] annotation.
  ///
  /// [generateForDir] - List of directory paths to scan for routes.
  /// If empty, scans the entire project.
  const JetRouteConfig({this.generateForDir = const ['lib']});

  /// Directories to scan for @JetPageRoute annotations
  final List<String> generateForDir;
}

/// Annotation to mark page widgets that should generate route classes.
///
/// Example:
/// ```dart
/// @RoutablePage(path: '/home')
/// class HomePage extends StatefulWidget { ... }
/// ```
class RoutablePage {
  /// Creates a [RoutablePage] annotation.
  ///
  /// [path] - Custom route path. If not provided, generates from class name.
  /// For example, `HomePage` becomes `/home-page`.
  const RoutablePage({this.path});

  /// Custom path for this route. If null, auto-generates from class name.
  final String? path;
}

/// Annotation to mark constructor parameters as URL parameters.
///
/// These parameters will be passed via `Jet.parameters` as query strings.
/// Works best with primitive types (String, int, double, bool).
///
/// Example:
/// ```dart
/// class ProfilePage extends StatelessWidget {
///   final String userId;
///
///   ProfilePage({@JetParams() required this.userId});
/// }
/// ```
class JetParams {
  /// Creates a [JetParams] annotation.
  const JetParams();
}

/// Annotation to mark constructor parameters as complex arguments.
///
/// These parameters will be passed via `Jet.arguments` as objects.
/// Use for complex types (List, Map, custom objects).
///
/// Example:
/// ```dart
/// class OrderPage extends StatelessWidget {
///   final Order order;
///
///   OrderPage({@JetArgs() required this.order});
/// }
/// ```
class JetArgs {
  /// Creates a [JetArgs] annotation.
  const JetArgs();
}
