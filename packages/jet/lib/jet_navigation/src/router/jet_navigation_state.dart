import 'package:flutter/foundation.dart';

/// Configuration for a single page in the navigation stack
@immutable
class JetPageConfiguration {
  /// The path for this page (e.g., '/users/123')
  final String path;

  /// Optional route name (e.g., 'userDetail')
  final String? name;

  /// Arguments to pass to the page
  final Object? arguments;

  /// Path parameters extracted from the URL (e.g., {'id': '123'})
  final Map<String, String> parameters;

  /// Unique key for this page instance
  final String? key;

  /// Optional title for this page
  final String? title;

  /// Optional metadata for custom use
  final Map<String, dynamic>? metadata;

  const JetPageConfiguration({
    required this.path,
    this.name,
    this.arguments,
    this.parameters = const {},
    this.key,
    this.title,
    this.metadata,
  });

  /// Create a copy of this configuration with updated fields
  JetPageConfiguration copyWith({
    String? path,
    String? name,
    Object? arguments,
    Map<String, String>? parameters,
    String? key,
    String? title,
    Map<String, dynamic>? metadata,
  }) {
    return JetPageConfiguration(
      path: path ?? this.path,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      parameters: parameters ?? this.parameters,
      key: key ?? this.key,
      title: title ?? this.title,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      if (name != null) 'name': name,
      'parameters': parameters,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (metadata != null) 'metadata': metadata,
      // Note: arguments are not serialized as they might not be JSON-serializable
    };
  }

  /// Create from JSON
  factory JetPageConfiguration.fromJson(Map<String, dynamic> json) {
    return JetPageConfiguration(
      path: json['path'] as String,
      name: json['name'] as String?,
      parameters: Map<String, String>.from(json['parameters'] as Map? ?? {}),
      key: json['key'] as String?,
      title: json['title'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JetPageConfiguration &&
        other.path == path &&
        other.name == name &&
        other.key == key &&
        other.title == title &&
        mapEquals(other.parameters, parameters) &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return path.hashCode ^
        name.hashCode ^
        key.hashCode ^
        title.hashCode ^
        parameters.hashCode ^
        metadata.hashCode;
  }

  @override
  String toString() {
    return 'JetPageConfiguration(path: $path, name: $name, key: $key, parameters: $parameters)';
  }
}

/// Represents the complete app navigation state
///
/// This is the single source of truth for the navigation state in a
/// declarative Navigator 2.0 architecture.
@immutable
class JetNavigationState {
  /// The stack of pages currently active
  final List<JetPageConfiguration> pages;

  /// The index of the current page in the stack
  final int currentIndex;

  /// Query parameters from the current URL
  final Map<String, dynamic> queryParameters;

  /// Path parameters extracted from the current URL
  final Map<String, String> pathParameters;

  /// Support for nested navigation states
  /// Key is the nested router identifier
  final Map<String, JetNavigationState> nestedStates;

  /// Unique identifier for browser history management
  final String? historyId;

  /// Optional metadata for custom use
  final Map<String, dynamic>? metadata;

  const JetNavigationState({
    required this.pages,
    this.currentIndex = 0,
    this.queryParameters = const {},
    this.pathParameters = const {},
    this.nestedStates = const {},
    this.historyId,
    this.metadata,
  }) : assert(currentIndex >= 0, 'currentIndex must be non-negative');

  /// Get the current page configuration
  JetPageConfiguration? get currentPage {
    if (pages.isEmpty) return null;
    if (currentIndex >= pages.length) return pages.last;
    return pages[currentIndex];
  }

  /// Get the previous page configuration
  JetPageConfiguration? get previousPage {
    if (pages.length < 2) return null;
    final prevIndex = currentIndex - 1;
    if (prevIndex < 0 || prevIndex >= pages.length) return null;
    return pages[prevIndex];
  }

  /// Check if we can go back
  bool get canPop => pages.length > 1;

  /// Get the full path including query parameters
  String get fullPath {
    final currentPath = currentPage?.path ?? '/';
    if (queryParameters.isEmpty) return currentPath;

    final queryString = queryParameters.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return '$currentPath?$queryString';
  }

  /// Create a copy of this state with updated fields
  JetNavigationState copyWith({
    List<JetPageConfiguration>? pages,
    int? currentIndex,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? pathParameters,
    Map<String, JetNavigationState>? nestedStates,
    String? historyId,
    Map<String, dynamic>? metadata,
  }) {
    return JetNavigationState(
      pages: pages ?? this.pages,
      currentIndex: currentIndex ?? this.currentIndex,
      queryParameters: queryParameters ?? this.queryParameters,
      pathParameters: pathParameters ?? this.pathParameters,
      nestedStates: nestedStates ?? this.nestedStates,
      historyId: historyId ?? this.historyId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for serialization and state restoration
  Map<String, dynamic> toJson() {
    return {
      'pages': pages.map((p) => p.toJson()).toList(),
      'currentIndex': currentIndex,
      'queryParameters': queryParameters,
      'pathParameters': pathParameters,
      'nestedStates':
          nestedStates.map((key, value) => MapEntry(key, value.toJson())),
      if (historyId != null) 'historyId': historyId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from JSON
  factory JetNavigationState.fromJson(Map<String, dynamic> json) {
    return JetNavigationState(
      pages: (json['pages'] as List<dynamic>)
          .map((p) => JetPageConfiguration.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentIndex: json['currentIndex'] as int? ?? 0,
      queryParameters:
          Map<String, dynamic>.from(json['queryParameters'] as Map? ?? {}),
      pathParameters:
          Map<String, String>.from(json['pathParameters'] as Map? ?? {}),
      nestedStates: (json['nestedStates'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                  key,
                  JetNavigationState.fromJson(
                      value as Map<String, dynamic>))) ??
          const {},
      historyId: json['historyId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JetNavigationState &&
        listEquals(other.pages, pages) &&
        other.currentIndex == currentIndex &&
        mapEquals(other.queryParameters, queryParameters) &&
        mapEquals(other.pathParameters, pathParameters) &&
        mapEquals(other.nestedStates, nestedStates) &&
        other.historyId == historyId &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return pages.hashCode ^
        currentIndex.hashCode ^
        queryParameters.hashCode ^
        pathParameters.hashCode ^
        nestedStates.hashCode ^
        historyId.hashCode ^
        metadata.hashCode;
  }

  @override
  String toString() {
    return 'JetNavigationState(pages: ${pages.length}, currentIndex: $currentIndex, currentPage: ${currentPage?.path})';
  }

  /// Create an initial navigation state with a single page
  factory JetNavigationState.initial(String initialRoute) {
    return JetNavigationState(
      pages: [
        JetPageConfiguration(path: initialRoute),
      ],
      currentIndex: 0,
    );
  }

  /// Create a navigation state from a URI
  factory JetNavigationState.fromUri(Uri uri) {
    final path = uri.path.isEmpty ? '/' : uri.path;
    return JetNavigationState(
      pages: [
        JetPageConfiguration(path: path),
      ],
      currentIndex: 0,
      queryParameters: uri.queryParameters,
    );
  }
}
