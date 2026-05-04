import 'transitions_type.dart';

/// Marks a class as a JetX typed route, read by the companion
/// `jetx_builder` codegen package. Two supported shapes:
///
/// 1. **Widget pages (auto_route-style).** Annotate the page widget
///    itself; the generator scans its constructor params, emits a
///    typed `<ClassName>Route` for navigation, *and* a
///    `<className>Jet` `JetPage` constant pre-wired with [bindings],
///    [middlewares], [transition], and [fullscreenDialog]. The widget
///    is reconstructed at push time from `Jet.parameters`.
///
/// 2. **Standalone route specs.** Annotate any plain Dart class that
///    extends `JetRouteData` with the `_$<ClassName>` mixin; the
///    generator emits only the typed `location` getter. Use this when
///    the route doesn't correspond to a single widget (e.g.
///    branch-shell entry points). Bindings/transition fields are
///    ignored in this mode.
///
/// Annotation lives in the runtime `jetx` package so consumer apps
/// only depend on `jetx`; `jetx_builder` is a build-time dev
/// dependency.
///
/// Example (page form):
/// ```dart
/// @JetRoute(
///   path: '/products/:id',
///   bindings: [ProductDetailBinding],
///   transition: Transition.rightToLeft,
/// )
/// class ProductDetailPage extends StatelessWidget {
///   const ProductDetailPage({super.key, required this.id, this.tab});
///   final String id;
///   final String? tab;
///   ...
/// }
/// ```
///
/// Supported constructor param types in v1: `String`, `String?`,
/// `int`, `int?`, `double`, `double?`, `bool`, `bool?`. Other types
/// must be passed via the typed route's `arguments` field.
class JetRoute {
  const JetRoute({
    required this.path,
    this.bindings = const [],
    this.transition,
    this.middlewares = const [],
    this.fullscreenDialog = false,
  });

  /// Route pattern. `:name` segments are matched against the
  /// annotated class's fields (or constructor params, for widget
  /// pages) by name.
  final String path;

  /// Types of `BindingsInterface` subclasses to instantiate when the
  /// route is pushed. Each must have a public no-arg constructor so
  /// the generator can emit `[MyBinding()]`. Honored only for the
  /// widget-page form (case 1 above).
  final List<Type> bindings;

  /// Transition for the generated `JetPage`. When null, JetX falls
  /// back to the app-level default transition. Honored only for the
  /// widget-page form.
  final Transition? transition;

  /// Types of `JetMiddleware` subclasses to instantiate for the
  /// generated `JetPage`. Same instantiation contract as [bindings].
  /// Honored only for the widget-page form.
  final List<Type> middlewares;

  /// Forwarded as `JetPage.fullscreenDialog`. Honored only for the
  /// widget-page form.
  final bool fullscreenDialog;
}
