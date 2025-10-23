import '../jet.dart';

extension GetResetExt on JetInterface {
  void reset({bool clearRouteBindings = true}) {
    Jet.resetInstance(clearRouteBindings: clearRouteBindings);
    // Jet.clearRouteTree();
    Jet.clearTranslations();
    // Jet.resetRootNavigator();
  }
}
