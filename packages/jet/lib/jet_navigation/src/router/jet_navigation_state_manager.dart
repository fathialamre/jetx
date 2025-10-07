import 'dart:async';
import 'package:flutter/foundation.dart';
import 'jet_navigation_state.dart';
import 'tabs/jet_tabs_controller.dart';

/// Callback type for navigation events
typedef NavigationCallback = void Function(JetNavigationState state);

/// Manages the navigation state in a reactive way
///
/// This class is the heart of the declarative Navigator 2.0 implementation.
/// It manages the navigation stack and notifies listeners when the state changes.
class JetNavigationStateManager extends ChangeNotifier {
  /// Singleton instance
  static JetNavigationStateManager? _instance;

  /// Get the singleton instance
  static JetNavigationStateManager get instance {
    _instance ??= JetNavigationStateManager();
    return _instance!;
  }

  /// Initialize the singleton with a specific state
  static void initialize({
    JetNavigationState? initialState,
    int maxHistorySize = 50,
    bool enableHistory = true,
  }) {
    _instance = JetNavigationStateManager(
      initialState: initialState,
      maxHistorySize: maxHistorySize,
      enableHistory: enableHistory,
    );
  }

  JetNavigationState _state;

  /// History of navigation states for undo/redo functionality
  final List<JetNavigationState> _history = [];

  /// Maximum history size (default: 50)
  final int maxHistorySize;

  /// Whether to record navigation history
  final bool enableHistory;

  /// Callbacks for navigation events
  final List<NavigationCallback> _onNavigationCallbacks = [];

  /// Stream controller for navigation events
  final StreamController<JetNavigationState> _navigationStream =
      StreamController<JetNavigationState>.broadcast();

  /// Stream of navigation state changes
  Stream<JetNavigationState> get navigationStream => _navigationStream.stream;

  /// Tab controller for managing bottom navigation tabs
  JetTabsController? _tabsController;

  JetNavigationStateManager({
    JetNavigationState? initialState,
    this.maxHistorySize = 50,
    this.enableHistory = true,
  }) : _state = initialState ?? JetNavigationState.initial('/');

  /// Get the current navigation state
  JetNavigationState get state => _state;

  /// Get the current page path
  String get currentPath => _state.currentPage?.path ?? '/';

  /// Get the current page name
  String? get currentName => _state.currentPage?.name;

  /// Get navigation history
  List<JetNavigationState> get history =>
      enableHistory ? List.unmodifiable(_history) : [];

  /// Check if we can go back in history
  bool get canGoBack => _state.canPop;

  /// Register a callback for navigation events
  void addNavigationCallback(NavigationCallback callback) {
    _onNavigationCallbacks.add(callback);
  }

  /// Unregister a navigation callback
  void removeNavigationCallback(NavigationCallback callback) {
    _onNavigationCallbacks.remove(callback);
  }

  /// Push a new page onto the stack
  void push(JetPageConfiguration config) {
    final newPages = [..._state.pages, config];
    _updateState(_state.copyWith(
      pages: newPages,
      currentIndex: newPages.length - 1,
      historyId: _generateHistoryId(),
    ));
  }

  /// Push a page by path
  void pushNamed(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
    String? name,
  }) {
    push(JetPageConfiguration(
      path: path,
      arguments: arguments,
      parameters: parameters ?? {},
      name: name,
    ));
  }

  /// Replace the current page with a new one
  void replace(JetPageConfiguration config) {
    if (_state.pages.isEmpty) {
      push(config);
      return;
    }

    final newPages = [..._state.pages];
    newPages[_state.currentIndex] = config;
    _updateState(_state.copyWith(
      pages: newPages,
      historyId: _generateHistoryId(),
    ));
  }

  /// Replace the current page by path
  void replaceNamed(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
    String? name,
  }) {
    replace(JetPageConfiguration(
      path: path,
      arguments: arguments,
      parameters: parameters ?? {},
      name: name,
    ));
  }

  /// Remove the top page from the stack
  bool pop<T>([T? result]) {
    if (!_state.canPop) return false;

    final newPages = _state.pages.sublist(0, _state.pages.length - 1);
    _updateState(_state.copyWith(
      pages: newPages,
      currentIndex: newPages.length - 1,
      historyId: _generateHistoryId(),
    ));
    return true;
  }

  /// Pop until a specific page
  bool popUntil(bool Function(JetPageConfiguration) predicate) {
    if (_state.pages.length <= 1) return false;

    final newPages = <JetPageConfiguration>[];
    bool found = false;

    for (final page in _state.pages) {
      newPages.add(page);
      if (predicate(page)) {
        found = true;
        break;
      }
    }

    if (!found || newPages.isEmpty) return false;

    _updateState(_state.copyWith(
      pages: newPages,
      currentIndex: newPages.length - 1,
      historyId: _generateHistoryId(),
    ));
    return true;
  }

  /// Pop until a specific path
  bool popUntilPath(String path) {
    return popUntil((page) => page.path == path);
  }

  /// Pop until a specific name
  bool popUntilName(String name) {
    return popUntil((page) => page.name == name);
  }

  /// Remove a specific page from the stack
  bool removePage(JetPageConfiguration page) {
    if (_state.pages.length <= 1) return false;

    final newPages = _state.pages.where((p) => p != page).toList();
    if (newPages.length == _state.pages.length) return false;

    final newIndex = newPages.length - 1;
    _updateState(_state.copyWith(
      pages: newPages,
      currentIndex: newIndex.clamp(0, newPages.length - 1),
      historyId: _generateHistoryId(),
    ));
    return true;
  }

  /// Navigate to a specific path
  void navigateTo(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
    Map<String, dynamic>? queryParameters,
    String? name,
  }) {
    // Check if the page already exists in the stack
    final existingIndex = _state.pages.indexWhere((p) => p.path == path);

    if (existingIndex != -1) {
      // Page exists, navigate to it
      _updateState(_state.copyWith(
        currentIndex: existingIndex,
        queryParameters: queryParameters ?? _state.queryParameters,
        historyId: _generateHistoryId(),
      ));
    } else {
      // Page doesn't exist, push it
      final config = JetPageConfiguration(
        path: path,
        arguments: arguments,
        parameters: parameters ?? {},
        name: name,
      );
      push(config);

      if (queryParameters != null) {
        _updateState(_state.copyWith(queryParameters: queryParameters));
      }
    }
  }

  /// Clear the entire stack and navigate to a new page
  void offAll(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
    String? name,
  }) {
    final config = JetPageConfiguration(
      path: path,
      arguments: arguments,
      parameters: parameters ?? {},
      name: name,
    );

    _updateState(JetNavigationState(
      pages: [config],
      currentIndex: 0,
      historyId: _generateHistoryId(),
    ));
  }

  /// Clear stack except the first page and navigate to a new page
  void offAllNamed(String path, {String? until}) {
    final firstPage = _state.pages.isNotEmpty
        ? _state.pages.first
        : JetPageConfiguration(path: '/');

    List<JetPageConfiguration> newPages = [firstPage];

    // Add pages up to the 'until' page if specified
    if (until != null) {
      final untilIndex = _state.pages.indexWhere((p) => p.path == until);
      if (untilIndex > 0) {
        newPages = _state.pages.sublist(0, untilIndex + 1);
      }
    }

    // Add the new page
    newPages.add(JetPageConfiguration(path: path));

    _updateState(_state.copyWith(
      pages: newPages,
      currentIndex: newPages.length - 1,
      historyId: _generateHistoryId(),
    ));
  }

  /// Navigate to a page and remove the current page
  void off(
    String path, {
    Object? arguments,
    Map<String, String>? parameters,
    String? name,
  }) {
    if (_state.pages.isEmpty) {
      navigateTo(path,
          arguments: arguments, parameters: parameters, name: name);
      return;
    }

    final newPages = _state.pages.sublist(0, _state.pages.length - 1);
    newPages.add(JetPageConfiguration(
      path: path,
      arguments: arguments,
      parameters: parameters ?? {},
      name: name,
    ));

    _updateState(_state.copyWith(
      pages: newPages,
      currentIndex: newPages.length - 1,
      historyId: _generateHistoryId(),
    ));
  }

  /// Update query parameters without changing the page
  void updateQueryParameters(Map<String, dynamic> queryParameters) {
    _updateState(_state.copyWith(
      queryParameters: {..._state.queryParameters, ...queryParameters},
      historyId: _generateHistoryId(),
    ));
  }

  /// Update path parameters without changing the page
  void updatePathParameters(Map<String, String> pathParameters) {
    _updateState(_state.copyWith(
      pathParameters: {..._state.pathParameters, ...pathParameters},
      historyId: _generateHistoryId(),
    ));
  }

  /// Update the arguments of the current page
  void updateCurrentArguments(Object? arguments) {
    final currentPage = _state.currentPage;
    if (currentPage == null) return;

    final updatedPage = currentPage.copyWith(arguments: arguments);
    replace(updatedPage);
  }

  /// Set a completely new navigation state
  void setState(JetNavigationState newState) {
    _updateState(newState);
  }

  /// Update nested navigation state
  void updateNestedState(String key, JetNavigationState nestedState) {
    final newNestedStates = {..._state.nestedStates};
    newNestedStates[key] = nestedState;
    _updateState(_state.copyWith(nestedStates: newNestedStates));
  }

  /// Remove nested navigation state
  void removeNestedState(String key) {
    final newNestedStates = {..._state.nestedStates};
    newNestedStates.remove(key);
    _updateState(_state.copyWith(nestedStates: newNestedStates));
  }

  /// Clear all navigation state (reset to initial)
  void clear([String? initialRoute]) {
    _updateState(JetNavigationState.initial(initialRoute ?? '/'));
    if (enableHistory) {
      _history.clear();
    }
  }

  /// Internal method to update state and notify listeners
  void _updateState(JetNavigationState newState) {
    if (_state == newState) return;

    // Add current state to history before updating
    if (enableHistory) {
      _history.add(_state);
      if (_history.length > maxHistorySize) {
        _history.removeAt(0);
      }
    }

    _state = newState;

    // Notify all callbacks
    for (final callback in _onNavigationCallbacks) {
      callback(newState);
    }

    // Add to stream
    _navigationStream.add(newState);

    // Notify ChangeNotifier listeners
    notifyListeners();
  }

  /// Generate a unique history ID for browser history
  String _generateHistoryId() {
    return '${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Restore state from history (undo functionality)
  bool restoreFromHistory(int index) {
    if (!enableHistory || index < 0 || index >= _history.length) {
      return false;
    }

    _state = _history[index];
    notifyListeners();
    return true;
  }

  // ========================================================================
  // Tabs Navigation Support
  // ========================================================================

  /// Set the tabs controller for tab-based navigation
  void setTabsController(JetTabsController controller) {
    _tabsController?.dispose();
    _tabsController = controller;
    _tabsController!.addListener(_onTabsControllerChanged);
  }

  /// Get the current tabs controller
  JetTabsController? get tabsController => _tabsController;

  /// Check if tabs are active
  bool get hasActiveTabs => _tabsController != null;

  /// Get the current active tab index (if tabs are active)
  int? get currentTabIndex => _tabsController?.currentIndex;

  /// Get the current active tab name (if tabs are active)
  String? get currentTabName => _tabsController?.currentTabName;

  /// Switch to a tab by index
  void switchTab({int? index, String? name}) {
    if (_tabsController == null) {
      throw StateError(
          'No tabs controller is set. Use setTabsController() first.');
    }

    if (index != null) {
      _tabsController!.switchToIndex(index);
    } else if (name != null) {
      _tabsController!.switchToName(name);
    } else {
      throw ArgumentError('Either index or name must be provided');
    }
  }

  /// Push a route in the active tab
  Future<T?> pushInActiveTab<T>(
    String path, {
    Object? arguments,
  }) async {
    if (_tabsController == null) {
      throw StateError('No tabs controller is set');
    }
    return _tabsController!.pushNamed<T>(path, arguments: arguments);
  }

  /// Pop the active tab's navigation stack
  Future<bool> popActiveTab() async {
    if (_tabsController == null) {
      throw StateError('No tabs controller is set');
    }
    return _tabsController!.popCurrentTab();
  }

  /// Check if the active tab can pop
  bool get canPopActiveTab {
    return _tabsController?.canPopCurrentTab ?? false;
  }

  /// Handle system back button (works with tabs)
  Future<bool> handleSystemBack() async {
    if (_tabsController != null) {
      return _tabsController!.handleSystemBack();
    }
    // Fallback to regular pop
    return pop();
  }

  /// Clear the tabs controller
  void clearTabsController() {
    _tabsController?.removeListener(_onTabsControllerChanged);
    _tabsController?.dispose();
    _tabsController = null;
  }

  /// Called when tabs controller state changes
  void _onTabsControllerChanged() {
    // Notify listeners that tab state has changed
    notifyListeners();
  }

  @override
  void dispose() {
    clearTabsController();
    _navigationStream.close();
    _onNavigationCallbacks.clear();
    if (enableHistory) {
      _history.clear();
    }
    super.dispose();
  }

  @override
  String toString() {
    return 'JetNavigationStateManager(currentPath: $currentPath, pages: ${_state.pages.length})';
  }
}
