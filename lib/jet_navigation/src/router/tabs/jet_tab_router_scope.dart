import 'package:flutter/widgets.dart';
import '../jet_navigation_state_manager.dart';

/// Provides a scoped JetNavigationStateManager for tab navigation
///
/// This allows context.router to find the nearest router,
/// which could be a tab's nested router or the root router.
///
/// Similar to auto_route's AutoRouter scope.
class JetTabRouterScope extends InheritedWidget {
  final JetNavigationStateManager router;

  const JetTabRouterScope({
    super.key,
    required this.router,
    required super.child,
  });

  /// Find the nearest JetTabRouterScope in the widget tree
  static JetNavigationStateManager? of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<JetTabRouterScope>();
    return scope?.router;
  }

  /// Try to find a scoped router, fallback to singleton
  static JetNavigationStateManager nearest(BuildContext context) {
    return of(context) ?? JetNavigationStateManager.instance;
  }

  @override
  bool updateShouldNotify(JetTabRouterScope oldWidget) {
    return router != oldWidget.router;
  }
}
