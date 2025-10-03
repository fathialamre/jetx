import '../jet.dart';

extension JetResetExt on JetInterface {
  void reset({bool clearRouteBindings = true}) {
    Jet.resetInstance(clearRouteBindings: clearRouteBindings);
    // Jet.clearRouteTree();
    Jet.clearTranslations();
    // Jet.resetRootNavigator();
  }
}
