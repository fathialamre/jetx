import 'tab_item.dart';

/// A route configuration that represents a tabbed shell with bottom navigation
///
/// Example:
/// ```dart
/// TabsRoute(
///   path: '/app',
///   name: 'app',
///   tabs: [
///     TabItem(
///       name: 'home',
///       path: 'home',
///       label: 'Home',
///       icon: Icon(Icons.home),
///       initial: true,
///       routes: [
///         JetPage(name: '/app/home', page: () => HomePage()),
///         JetPage(name: '/app/home/details', page: () => DetailsPage()),
///       ],
///     ),
///     TabItem(
///       name: 'profile',
///       path: 'profile',
///       label: 'Profile',
///       icon: Icon(Icons.person),
///       routes: [
///         JetPage(name: '/app/profile', page: () => ProfilePage()),
///       ],
///     ),
///   ],
/// )
/// ```
class TabsRoute {
  /// The base path for this tabbed shell (e.g., '/app')
  final String path;

  /// Unique name identifier for this tabs route
  final String name;

  /// List of tabs in this tabbed shell
  final List<TabItem> tabs;

  /// Restoration ID for state restoration
  final String? restorationId;

  /// Whether to show the bottom navigation bar
  final bool showNavigationBar;

  /// Whether tabs should preserve their state when switching
  final bool maintainState;

  TabsRoute({
    required this.path,
    required this.name,
    required this.tabs,
    this.restorationId,
    this.showNavigationBar = true,
    this.maintainState = true,
  })  : assert(tabs.isNotEmpty, 'TabsRoute must have at least one tab'),
        assert(
          tabs.where((tab) => tab.initial).length <= 1,
          'Only one tab can be marked as initial',
        ),
        assert(path.startsWith('/'), 'TabsRoute path must start with /'
);

  /// Get the initial tab (first tab marked as initial, or first tab if none marked)
  TabItem get initialTab {
    final initialTabs = tabs.where((tab) => tab.initial);
    return initialTabs.isNotEmpty ? initialTabs.first : tabs.first;
  }

  /// Find a tab by name
  TabItem? findTabByName(String name) {
    try {
      return tabs.firstWhere((tab) => tab.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Find a tab by path
  TabItem? findTabByPath(String path) {
    try {
      return tabs.firstWhere((tab) => tab.path == path);
    } catch (e) {
      return null;
    }
  }

  /// Get tab index by name
  int? getTabIndexByName(String name) {
    final index = tabs.indexWhere((tab) => tab.name == name);
    return index >= 0 ? index : null;
  }

  /// Get tab by index
  TabItem? getTabByIndex(int index) {
    if (index >= 0 && index < tabs.length) {
      return tabs[index];
    }
    return null;
  }

  @override
  String toString() => 'TabsRoute(path: $path, name: $name, tabs: ${tabs.length})';
}
