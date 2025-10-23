/// Configuration for the router class.
class RouterConfig {
  /// Creates a router configuration.
  const RouterConfig({
    required this.routerClassName,
    required this.generateForDir,
    required this.filePath,
    required this.usesPartBuilder,
  });

  /// The name of the router class (e.g., 'AppRouter')
  final String routerClassName;

  /// Directories to scan for routes
  final List<String> generateForDir;

  /// The file path where the router class is defined
  final String filePath;

  /// Whether the router uses part builder (part 'file.g.dart')
  final bool usesPartBuilder;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'routerClassName': routerClassName,
      'generateForDir': generateForDir,
      'filePath': filePath,
      'usesPartBuilder': usesPartBuilder,
    };
  }

  /// Creates from JSON
  factory RouterConfig.fromJson(Map<String, dynamic> json) {
    return RouterConfig(
      routerClassName: json['routerClassName'] as String,
      generateForDir: List<String>.from(json['generateForDir'] as List),
      filePath: json['filePath'] as String,
      usesPartBuilder: json['usesPartBuilder'] as bool,
    );
  }
}
