/// Marks a class as a typed JetX route. Read by the companion
/// `jetx_builder` codegen package, which emits a corresponding
/// [JetRouteData] subclass at build time.
///
/// Hand-written code never imports this from `jetx_builder` — the
/// annotation lives here in the main package so consumers only depend
/// on `jetx` at runtime; `jetx_builder` is a build-time dev dependency.
///
/// Usage:
/// ```dart
/// @JetRoute(path: '/user/:id')
/// class UserRouteSpec {
///   const UserRouteSpec({required this.id, this.tab});
///   final int id;
///   final String? tab;
/// }
///
/// // After running build_runner, the generator emits a UserRouteData
/// // class that extends JetRouteData and resolves location via
/// // Jet.buildUrl.
/// ```
class JetRoute {
  const JetRoute({required this.path});

  /// Route pattern. Path params use `:name` syntax (e.g. `/user/:id`)
  /// and are matched against the annotated class's fields by name.
  final String path;
}
