import 'package:flutter/material.dart';
import 'jet_tabs_controller.dart';
import 'tab_item.dart';
import 'tabs_route.dart';
import 'jet_tab_router_scope.dart';
import 'jet_tab_navigation_delegate.dart';

/// Callback for building custom navigation bar
typedef NavigationBarBuilder = Widget Function(
  BuildContext context,
  JetTabsController controller,
  List<TabItem> tabs,
  int currentIndex,
);

/// A shell widget that displays a bottom navigation bar with multiple tabs
///
/// Each tab has its own navigation stack, and switching between tabs
/// preserves the navigation state of each tab.
///
/// Example:
/// ```dart
/// JetTabsShell(
///   tabsRoute: myTabsRoute,
///   navigationBarBuilder: (context, controller, tabs, currentIndex) {
///     return NavigationBar(
///       selectedIndex: currentIndex,
///       onDestinationSelected: controller.switchToIndex,
///       destinations: tabs
///           .map((t) => NavigationDestination(
///                 icon: t.icon,
///                 label: t.label,
///               ))
///           .toList(),
///     );
///   },
/// )
/// ```
class JetTabsShell extends StatefulWidget {
  /// The tabs route configuration
  final TabsRoute tabsRoute;

  /// Builder for the navigation bar
  final NavigationBarBuilder? navigationBarBuilder;

  /// Whether to show the navigation bar
  final bool showNavigationBar;

  /// Initial tab index
  final int? initialIndex;

  /// Restoration ID for state restoration
  final String? restorationId;

  /// Callback when tab changes
  final void Function(int oldIndex, int newIndex)? onTabChanged;

  const JetTabsShell({
    super.key,
    required this.tabsRoute,
    this.navigationBarBuilder,
    this.showNavigationBar = true,
    this.initialIndex,
    this.restorationId,
    this.onTabChanged,
  });

  @override
  State<JetTabsShell> createState() => _JetTabsShellState();
}

class _JetTabsShellState extends State<JetTabsShell>
    with WidgetsBindingObserver {
  late JetTabsController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = JetTabsController(
      tabsRoute: widget.tabsRoute,
      initialIndex: widget.initialIndex,
      preserveTabHistory: true,
    );

    _controller.onTabChanged = _handleTabChanged;
    _controller.addListener(_onControllerChanged);
  }

  void _handleTabChanged(int oldIndex, int newIndex) {
    widget.onTabChanged?.call(oldIndex, newIndex);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when controller state changes
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    // Handle back button
    return await _controller.handleSystemBack();
  }

  Widget _buildDefaultNavigationBar(
    BuildContext context,
    JetTabsController controller,
    List<TabItem> tabs,
    int currentIndex,
  ) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: controller.switchToIndex,
      destinations: tabs
          .map((tab) => NavigationDestination(
                icon: tab.icon,
                selectedIcon: tab.selectedIcon ?? tab.icon,
                label: tab.label,
                tooltip: tab.tooltip,
              ))
          .toList(),
    );
  }

  Widget _buildTabNavigator(TabItem tab, int index) {
    // If no routes defined, show placeholder
    if (tab.routes.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('No routes configured for tab: ${tab.name}'),
        ),
      );
    }

    // Create a navigation delegate for this tab
    final navigatorKey = _controller.getNavigatorKey(index)!;
    final tabRouter = JetTabNavigationDelegate(navigatorKey: navigatorKey);

    // Wrap the Navigator with a router scope so context.router finds this tab's router
    return JetTabRouterScope(
      router: tabRouter,
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          final routeName = settings.name;

          // If no route name specified, use the first route
          if (routeName == null || routeName == Navigator.defaultRouteName) {
            return tab.routes.first.createRoute(context);
          }

          // Find matching route
          for (final route in tab.routes) {
            if (route.name == routeName) {
              return route.createRoute(context);
            }
          }

          // Fallback to first route
          return tab.routes.first.createRoute(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _controller.currentIndex;
    final tabs = widget.tabsRoute.tabs;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs
            .asMap()
            .entries
            .map((entry) => _buildTabNavigator(entry.value, entry.key))
            .toList(),
      ),
      bottomNavigationBar: widget.showNavigationBar
          ? (widget.navigationBarBuilder?.call(
                context,
                _controller,
                tabs,
                currentIndex,
              ) ??
              _buildDefaultNavigationBar(
                context,
                _controller,
                tabs,
                currentIndex,
              ))
          : null,
    );
  }
}
