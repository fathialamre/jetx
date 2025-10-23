import 'route_config.dart';

/// A list of routes for caching.
class RoutesList {
  /// Creates a routes list.
  const RoutesList({required this.routes, required this.filePath});

  /// All routes in this file
  final List<RouteConfig> routes;

  /// The file path this was generated from
  final String filePath;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'routes': routes.map((r) => r.toJson()).toList(),
      'filePath': filePath,
    };
  }

  /// Creates from JSON
  factory RoutesList.fromJson(Map<String, dynamic> json) {
    return RoutesList(
      routes: (json['routes'] as List)
          .map((r) => RouteConfig.fromJson(r as Map<String, dynamic>))
          .toList(),
      filePath: json['filePath'] as String,
    );
  }
}
