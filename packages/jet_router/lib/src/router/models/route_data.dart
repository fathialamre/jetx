/// Provides access to route information including path parameters,
/// query parameters, and arguments passed during navigation.
class RouteData {
  /// Path parameters extracted from the route path.
  /// Example: For route '/user/:id', accessing '/user/123' gives {'id': '123'}
  final Map<String, String> pathParams;

  /// Query parameters from the URL.
  /// Example: For '/search?q=flutter&sort=date', gives {'q': 'flutter', 'sort': 'date'}
  final Map<String, String> queryParams;

  /// Optional arguments passed during navigation.
  final Object? arguments;

  /// The full route path that was matched.
  final String path;

  const RouteData({
    required this.pathParams,
    required this.queryParams,
    required this.path,
    this.arguments,
  });

  /// Creates an empty RouteData instance.
  const RouteData.empty()
    : pathParams = const {},
      queryParams = const {},
      arguments = null,
      path = '';

  /// Gets a path parameter by key, or returns null if not found.
  String? getPathParam(String key) => pathParams[key];

  /// Gets a query parameter by key, or returns null if not found.
  String? getQueryParam(String key) => queryParams[key];

  /// Gets arguments cast to the specified type.
  T? getArguments<T>() => arguments as T?;

  @override
  String toString() {
    return 'RouteData(path: $path, pathParams: $pathParams, queryParams: $queryParams, arguments: $arguments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteData &&
        other.path == path &&
        _mapEquals(other.pathParams, pathParams) &&
        _mapEquals(other.queryParams, queryParams) &&
        other.arguments == arguments;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        pathParams.hashCode ^
        queryParams.hashCode ^
        arguments.hashCode;
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}
