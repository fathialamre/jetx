import '../jetx.dart';

extension JetResetExt on JetInterface {
  /// Resets JetX state.
  ///
  /// - [clearRouteBindings] clears route-associated bindings.
  /// - [force] when `true`, also wipes permanent instances (e.g. services).
  ///   Defaults to `true` to preserve the historical behavior expected by
  ///   tests (`Jet.reset()` in tearDown means "clean slate"). Pass `false`
  ///   in production code paths where permanent services must survive.
  void reset({bool clearRouteBindings = true, bool force = true}) {
    Jet.resetInstance(clearRouteBindings: clearRouteBindings, force: force);
    // Jet.clearRouteTree();
    Jet.clearTranslations();
    // Jet.resetRootNavigator();
  }
}
