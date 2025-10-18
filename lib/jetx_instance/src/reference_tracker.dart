/// Tracks widget references for automatic lifecycle management
class InstanceReferenceTracker {
  static final Map<String, Set<int>> _references = {};
  static int _widgetIdCounter = 0;

  /// Track a widget usage for a dependency key
  static int trackWidget(String key) {
    final widgetId = ++_widgetIdCounter;
    _references[key] ??= {};
    _references[key]!.add(widgetId);
    return widgetId;
  }

  /// Untrack a widget when it's disposed
  static void untrackWidget(String key, int widgetId) {
    _references[key]?.remove(widgetId);
    if (_references[key]?.isEmpty ?? false) {
      _references.remove(key);
    }
  }

  /// Check if any widgets are still using this dependency
  static bool hasActiveReferences(String key) {
    return _references[key]?.isNotEmpty ?? false;
  }

  /// Get the number of widgets using this dependency
  static int getReferenceCount(String key) {
    return _references[key]?.length ?? 0;
  }

  /// Clear all references (for testing or app shutdown)
  static void clear() {
    _references.clear();
    _widgetIdCounter = 0;
  }

  /// Get all tracked keys (for debugging)
  static Set<String> getTrackedKeys() {
    return _references.keys.toSet();
  }
}
