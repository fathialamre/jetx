/// Base class for type-safe route descriptors.
///
/// Subclasses model a single navigation target. They expose:
///
/// - [location]: the resolved URL (path + query) — typically built via
///   `Jet.buildUrl`. This is what actually gets passed to `toNamed`.
/// - [arguments] (optional override): a strongly-typed `Object?` payload
///   forwarded to the route as `arguments`.
///
/// Hand-written usage:
/// ```dart
/// class UserRoute extends JetRouteData {
///   const UserRoute({required this.id, this.tab});
///   final int id;
///   final String? tab;
///
///   @override
///   String get location => Jet.buildUrl(
///         '/user/:id',
///         pathParams: {'id': id},
///         queryParams: {'tab': tab},
///       );
/// }
///
/// // usage
/// Jet.go(UserRoute(id: 42, tab: 'profile'));
/// ```
///
/// A future `jetx_builder` companion package will generate these classes
/// from `@JetRoute` annotations on plain Dart classes (Phase 4 of the
/// navigation roadmap). The base class ships now so app code can adopt
/// the pattern without waiting on codegen.
abstract class JetRouteData {
  const JetRouteData();

  /// The resolved URL pushed by `Jet.go(this)`. Subclasses typically
  /// build this via `Jet.buildUrl(template, pathParams: ..., queryParams: ...)`.
  String get location;

  /// Optional typed payload forwarded as `arguments` to the route.
  /// Override to attach state that doesn't fit in path/query (e.g. a
  /// pre-fetched data object).
  Object? get arguments => null;
}
