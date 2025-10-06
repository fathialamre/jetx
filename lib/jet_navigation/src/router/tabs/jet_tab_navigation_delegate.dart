import 'package:flutter/widgets.dart';
import '../jet_navigation_state_manager.dart';
import '../jet_navigation_state.dart';

/// A lightweight navigation delegate for tab navigation
///
/// This wraps a tab's Navigator and provides the same API as
/// JetNavigationStateManager, allowing context.router to work
/// seamlessly within tabs.
class JetTabNavigationDelegate extends JetNavigationStateManager {
  final GlobalKey<NavigatorState> navigatorKey;

  JetTabNavigationDelegate({
    required this.navigatorKey,
  }) : super(enableHistory: false);

  NavigatorState? get _navigator => navigatorKey.currentState;

  @override
  void pushNamed(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
    String? name,
  }) {
    _navigator?.pushNamed(path, arguments: arguments);
  }

  @override
  bool pop<T>([T? result]) {
    if (_navigator?.canPop() ?? false) {
      _navigator!.pop(result);
      return true;
    }
    return false;
  }

  @override
  void replaceNamed(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
    String? name,
  }) {
    _navigator?.pushReplacementNamed(path, arguments: arguments);
  }

  @override
  bool get canGoBack => _navigator?.canPop() ?? false;

  @override
  String get currentPath {
    // Return a placeholder for tab navigation
    return '/';
  }

  @override
  String? get currentName => null;

  // Override push to use Navigator
  @override
  void push(JetPageConfiguration config) {
    _navigator?.pushNamed(config.path, arguments: config.arguments);
  }

  // Override replace to use Navigator
  @override
  void replace(JetPageConfiguration config) {
    _navigator?.pushReplacementNamed(config.path, arguments: config.arguments);
  }
}
