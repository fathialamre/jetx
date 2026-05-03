import 'package:flutter/widgets.dart';

/// JetX's [Navigator] subclass.
///
/// Always inserts a [HeroController] as the first observer so `Hero`
/// flights work across declarative page diffs (the
/// `Jet.toNamed`/`Jet.back` path drives a Pages-API rebuild, and
/// `HeroController` is what coordinates the source/destination heroes
/// during that diff). Apps that need a custom flight shuttle should
/// pass their own controller via [heroController]; we still honor any
/// extra `observers` after it.
class JetNavigator extends Navigator {
  JetNavigator({
    super.key,
    void Function(Page<Object?>)? onDidRemovePage,
    required super.pages,
    List<NavigatorObserver>? observers,
    super.reportsRouteUpdateToEngine,
    TransitionDelegate? transitionDelegate,
    super.initialRoute,
    super.restorationScopeId,
    HeroController? heroController,
  }) : super(
          onDidRemovePage: onDidRemovePage ?? ((_) {}),
          observers: [
            heroController ?? HeroController(),
            ...?observers,
          ],
          transitionDelegate:
              transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
        );
}
