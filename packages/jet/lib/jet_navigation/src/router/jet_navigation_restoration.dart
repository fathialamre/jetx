import 'dart:convert';
import 'package:flutter/material.dart';

import 'jet_navigation_state.dart';
import 'jet_router_delegate.dart';

/// Mixin for adding state restoration to navigation
///
/// This allows the navigation state to be saved and restored
/// when the app is suspended and resumed.
mixin JetNavigationRestoration on RouterDelegate<JetNavigationState> {
  /// Get the restoration data
  JetNavigationState? get restorationData => currentConfiguration;

  /// Restore from a previous navigation state
  @override
  Future<void> setRestoredRoutePath(JetNavigationState configuration) async {
    return setNewRoutePath(configuration);
  }

  /// Serialize the navigation state to JSON
  Map<String, dynamic> serializeState(JetNavigationState state) {
    return state.toJson();
  }

  /// Deserialize JSON to navigation state
  JetNavigationState deserializeState(Map<String, dynamic> json) {
    return JetNavigationState.fromJson(json);
  }

  /// Serialize the navigation state to a string
  String serializeStateToString(JetNavigationState state) {
    return jsonEncode(serializeState(state));
  }

  /// Deserialize a string to navigation state
  JetNavigationState deserializeStateFromString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return deserializeState(json);
  }
}

/// Widget for managing navigation state restoration
class JetNavigationRestorationScope extends StatefulWidget {
  final Widget child;
  final String restorationId;
  final JetRouterDelegate routerDelegate;

  const JetNavigationRestorationScope({
    required this.child,
    required this.restorationId,
    required this.routerDelegate,
    super.key,
  });

  @override
  State<JetNavigationRestorationScope> createState() =>
      _JetNavigationRestorationScopeState();
}

class _JetNavigationRestorationScopeState
    extends State<JetNavigationRestorationScope> with RestorationMixin {
  late RestorableNavigationState _navigationState;

  @override
  String? get restorationId => widget.restorationId;

  @override
  void initState() {
    super.initState();
    _navigationState = RestorableNavigationState(
      routerDelegate: widget.routerDelegate,
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_navigationState, 'navigation_state');
  }

  @override
  void dispose() {
    _navigationState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Restorable property for navigation state
class RestorableNavigationState extends RestorableValue<JetNavigationState> {
  final JetRouterDelegate routerDelegate;

  RestorableNavigationState({required this.routerDelegate});

  @override
  JetNavigationState createDefaultValue() {
    return routerDelegate.currentConfiguration ??
        JetNavigationState.initial('/');
  }

  @override
  void didUpdateValue(JetNavigationState? oldValue) {
    if (value != oldValue) {
      routerDelegate.setNewRoutePath(value);
    }
    notifyListeners();
  }

  @override
  JetNavigationState fromPrimitives(Object? data) {
    if (data == null) return createDefaultValue();
    if (data is Map<String, dynamic>) {
      return JetNavigationState.fromJson(data);
    }
    if (data is String) {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return JetNavigationState.fromJson(json);
    }
    return createDefaultValue();
  }

  @override
  Object? toPrimitives() {
    return value.toJson();
  }
}

/// Helper class for managing state restoration
class JetNavigationStateRestoration {
  /// Save navigation state to storage
  static Future<void> saveState(
    String key,
    JetNavigationState state,
  ) async {
    // Implementation would depend on the storage mechanism
    // (SharedPreferences, local storage, etc.)
  }

  /// Load navigation state from storage
  static Future<JetNavigationState?> loadState(String key) async {
    // Implementation would depend on the storage mechanism
    return null;
  }

  /// Clear saved state
  static Future<void> clearState(String key) async {
    // Implementation would depend on the storage mechanism
  }
}
