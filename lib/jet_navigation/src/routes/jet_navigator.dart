import 'package:flutter/widgets.dart';

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
  }) : super(
          onDidRemovePage: onDidRemovePage ?? ((_) {}),
          observers: [
            HeroController(),
            ...?observers,
          ],
          transitionDelegate:
              transitionDelegate ?? const DefaultTransitionDelegate<dynamic>(),
        );
}
