import 'package:flutter/widgets.dart';
import '../pages/jet_route.dart';

/// Represents a single tab in a bottom navigation bar with its own route tree
class TabItem {
  /// Unique identifier for this tab
  final String name;

  /// Path segment for this tab (e.g., 'home', 'search', 'profile')
  final String path;

  /// Display label for the tab
  final String label;

  /// Icon widget for the tab
  final Widget icon;

  /// Optional selected icon widget
  final Widget? selectedIcon;

  /// Whether this is the initial/default tab
  final bool initial;

  /// Restoration ID for state restoration
  final String? restorationId;

  /// Child routes within this tab
  final List<JetPage> routes;

  /// Optional badge to display on the tab (e.g., notification count)
  final Widget? badge;

  /// Tooltip for accessibility
  final String? tooltip;

  const TabItem({
    required this.name,
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.initial = false,
    this.restorationId,
    this.routes = const [],
    this.badge,
    this.tooltip,
  });

  /// Get the full path for this tab's root
  String getFullPath(String parentPath) {
    return '$parentPath/$path';
  }

  /// Find a route by path within this tab
  JetPage? findRoute(String path) {
    for (final route in routes) {
      if (route.name == path) {
        return route;
      }
    }
    return null;
  }

  @override
  String toString() => 'TabItem(name: $name, path: $path, label: $label)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TabItem && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  /// Create a copy with modified properties
  TabItem copyWith({
    String? name,
    String? path,
    String? label,
    Widget? icon,
    Widget? selectedIcon,
    bool? initial,
    String? restorationId,
    List<JetPage>? routes,
    Widget? badge,
    String? tooltip,
  }) {
    return TabItem(
      name: name ?? this.name,
      path: path ?? this.path,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      initial: initial ?? this.initial,
      restorationId: restorationId ?? this.restorationId,
      routes: routes ?? this.routes,
      badge: badge ?? this.badge,
      tooltip: tooltip ?? this.tooltip,
    );
  }
}
