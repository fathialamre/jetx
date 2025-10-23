import 'route_parameter.dart';

/// Configuration for a single route.
class RouteConfig {
  /// Creates a route configuration.
  const RouteConfig({
    required this.className,
    required this.routeClassName,
    required this.path,
    required this.filePath,
    required this.parameters,
    required this.import,
  });

  /// The name of the page class (e.g., 'HomePage')
  final String className;

  /// The name of the generated route class (e.g., 'HomePageRoute')
  final String routeClassName;

  /// The route path (e.g., '/home-page')
  final String path;

  /// The file path where the page class is defined
  final String filePath;

  /// Constructor parameters
  final List<RouteParameter> parameters;

  /// Import statement for the page
  final String import;

  /// Gets parameters that should be passed as URL params
  List<RouteParameter> get urlParameters =>
      parameters.where((p) => p.isParam).toList();

  /// Gets parameters that should be passed as arguments
  List<RouteParameter> get argumentParameters =>
      parameters.where((p) => !p.isParam).toList();

  /// Whether this route has any parameters
  bool get hasParameters => parameters.isNotEmpty;

  /// Whether this route has URL parameters
  bool get hasUrlParameters => urlParameters.isNotEmpty;

  /// Whether this route has argument parameters
  bool get hasArgumentParameters => argumentParameters.isNotEmpty;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'routeClassName': routeClassName,
      'path': path,
      'filePath': filePath,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'import': import,
    };
  }

  /// Creates from JSON
  factory RouteConfig.fromJson(Map<String, dynamic> json) {
    return RouteConfig(
      className: json['className'] as String,
      routeClassName: json['routeClassName'] as String,
      path: json['path'] as String,
      filePath: json['filePath'] as String,
      parameters: (json['parameters'] as List)
          .map((p) => RouteParameter.fromJson(p as Map<String, dynamic>))
          .toList(),
      import: json['import'] as String,
    );
  }
}
