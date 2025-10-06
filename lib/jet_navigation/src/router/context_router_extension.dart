import 'package:flutter/widgets.dart';
import 'jet_navigation_state_manager.dart';
import '../../../jet_core/src/jet_interface.dart';
import 'tabs/jet_tab_router_scope.dart';

/// Extension to access navigation methods via context
///
/// Usage:
/// ```dart
/// context.router.pushNamed('/profile');
/// context.router.pop();
/// ```
///
/// Inside tabs, this will find the nearest tab router (nested navigation).
/// Outside tabs, this will use the root router.
extension JetNavigationContextExtension on BuildContext {
  /// Access the nearest navigation state manager
  /// 
  /// Searches for the nearest JetTabRouterScope in the widget tree.
  /// If found, returns the tab's router. Otherwise, returns the root router.
  /// 
  /// This is similar to auto_route's context.router behavior.
  JetNavigationStateManager get router => JetTabRouterScope.nearest(this);
}

/// Extension to access navigation methods via Jet class
///
/// Usage:
/// ```dart
/// Jet.router.pushNamed('/profile');
/// Jet.router.pop();
/// ```
extension JetNavigationExtension on JetInterface {
  /// Access the navigation state manager
  JetNavigationStateManager get router => JetNavigationStateManager.instance;
}
