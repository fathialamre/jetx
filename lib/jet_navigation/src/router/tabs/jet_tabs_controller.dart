import 'package:flutter/widgets.dart';
import 'tab_item.dart';
import 'tabs_route.dart';

/// Controller for managing tab state and navigation within tabs
///
/// Provides APIs to:
/// - Switch between tabs
/// - Navigate within the active tab
/// - Check if a tab can pop
/// - Access tab-specific navigators
class JetTabsController extends ChangeNotifier {
  /// The TabsRoute configuration
  final TabsRoute tabsRoute;

  /// Current active tab index
  int _currentIndex;

  /// Navigator keys for each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys;

  /// History of tab switches (for back navigation)
  final List<int> _tabHistory = [];

  /// Whether to preserve tab history for back navigation
  final bool preserveTabHistory;

  JetTabsController({
    required this.tabsRoute,
    int? initialIndex,
    this.preserveTabHistory = true,
  })  : _currentIndex = initialIndex ?? tabsRoute.tabs.indexOf(tabsRoute.initialTab),
        _navigatorKeys = List.generate(
          tabsRoute.tabs.length,
          (index) => GlobalKey<NavigatorState>(
            debugLabel: 'TabNavigator_${tabsRoute.tabs[index].name}',
          ),
        ) {
    // Initialize tab history with the initial tab
    if (preserveTabHistory) {
      _tabHistory.add(_currentIndex);
    }
  }

  /// Current active tab index
  int get currentIndex => _currentIndex;

  /// Current active tab
  TabItem get currentTab => tabsRoute.tabs[_currentIndex];

  /// Current tab name
  String get currentTabName => currentTab.name;

  /// Get all tabs
  List<TabItem> get tabs => tabsRoute.tabs;

  /// Get navigator key for a specific tab index
  GlobalKey<NavigatorState>? getNavigatorKey(int index) {
    if (index >= 0 && index < _navigatorKeys.length) {
      return _navigatorKeys[index];
    }
    return null;
  }

  /// Get navigator key for the current tab
  GlobalKey<NavigatorState>? get currentNavigatorKey {
    return getNavigatorKey(_currentIndex);
  }

  /// Get the navigator state for the current tab
  NavigatorState? get currentNavigator {
    return currentNavigatorKey?.currentState;
  }

  /// Switch to a tab by index
  void switchToIndex(int index) {
    if (index < 0 || index >= tabsRoute.tabs.length) {
      throw ArgumentError('Tab index $index is out of range');
    }

    if (_currentIndex != index) {
      final oldIndex = _currentIndex;
      _currentIndex = index;

      if (preserveTabHistory) {
        // Remove the tab from history if it exists
        _tabHistory.remove(index);
        // Add it to the end (most recent)
        _tabHistory.add(index);
      }

      notifyListeners();
      onTabChanged?.call(oldIndex, index);
    }
  }

  /// Switch to a tab by name
  void switchToName(String name) {
    final index = tabsRoute.getTabIndexByName(name);
    if (index == null) {
      throw ArgumentError('No tab found with name: $name');
    }
    switchToIndex(index);
  }

  /// Switch to a tab by its path
  void switchToPath(String path) {
    final tab = tabsRoute.findTabByPath(path);
    if (tab == null) {
      throw ArgumentError('No tab found with path: $path');
    }
    final index = tabsRoute.tabs.indexOf(tab);
    switchToIndex(index);
  }

  /// Check if the current tab can pop
  bool get canPopCurrentTab {
    final navigator = currentNavigator;
    return navigator?.canPop() ?? false;
  }

  /// Pop the current tab's navigation stack
  Future<bool> popCurrentTab() async {
    final navigator = currentNavigator;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return true;
    }
    return false;
  }

  /// Handle system back button
  /// Returns true if the back was handled, false if it should bubble up
  Future<bool> handleSystemBack() async {
    // Try to pop within the current tab first
    if (canPopCurrentTab) {
      await popCurrentTab();
      return true;
    }

    // If we can't pop and tab history is enabled, go to previous tab
    if (preserveTabHistory && _tabHistory.length > 1) {
      // Remove current tab from history
      _tabHistory.removeLast();
      // Switch to the previous tab
      final previousIndex = _tabHistory.last;
      _currentIndex = previousIndex;
      notifyListeners();
      return true;
    }

    // Can't handle the back, let it bubble up
    return false;
  }

  /// Push a named route in the current tab
  Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
  }) async {
    final navigator = currentNavigator;
    if (navigator == null) {
      throw StateError('No navigator found for current tab');
    }
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace the current route in the active tab
  Future<T?> replaceNamed<T>(
    String routeName, {
    Object? arguments,
  }) async {
    final navigator = currentNavigator;
    if (navigator == null) {
      throw StateError('No navigator found for current tab');
    }
    return navigator.pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  /// Pop until a specific route in the current tab
  void popUntil(bool Function(Route<dynamic>) predicate) {
    final navigator = currentNavigator;
    if (navigator == null) {
      throw StateError('No navigator found for current tab');
    }
    navigator.popUntil(predicate);
  }

  /// Callback when tab changes
  void Function(int oldIndex, int newIndex)? onTabChanged;

  /// Clear tab history
  void clearTabHistory() {
    _tabHistory.clear();
    _tabHistory.add(_currentIndex);
  }

  /// Get tab history (for debugging/testing)
  List<int> get tabHistory => List.unmodifiable(_tabHistory);

  @override
  void dispose() {
    _tabHistory.clear();
    super.dispose();
  }

  @override
  String toString() {
    return 'JetTabsController(currentIndex: $_currentIndex, '
        'currentTab: ${currentTab.name}, '
        'canPop: $canPopCurrentTab)';
  }
}
