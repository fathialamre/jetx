import 'package:flutter/widgets.dart';
import 'jet_navigation_state_manager.dart';
import '../../../jet_core/src/jet_interface.dart';

/// Extension to access navigation methods via context
///
/// Usage:
/// ```dart
/// context.nav.pushNamed('/profile');
/// context.nav.pop();
/// ```
extension JetNavigationContextExtension on BuildContext {
  /// Access the navigation state manager
  JetNavigationStateManager get router => JetNavigationStateManager.instance;
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
