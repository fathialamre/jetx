/// Represents a parameter in a route's constructor.
class RouteParameter {
  /// Creates a route parameter.
  const RouteParameter({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.isNamed,
    required this.defaultValue,
    required this.isParam,
    required this.isPrimitive,
  });

  /// Parameter name
  final String name;

  /// Parameter type as string (e.g., 'String', 'int', 'User')
  final String type;

  /// Whether this parameter is required (non-nullable and no default)
  final bool isRequired;

  /// Whether this is a named parameter
  final bool isNamed;

  /// Default value if any
  final String? defaultValue;

  /// Whether this should be passed as a URL parameter (via Jet.parameters)
  final bool isParam;

  /// Whether this is a primitive type
  final bool isPrimitive;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'isRequired': isRequired,
      'isNamed': isNamed,
      'defaultValue': defaultValue,
      'isParam': isParam,
      'isPrimitive': isPrimitive,
    };
  }

  /// Creates from JSON
  factory RouteParameter.fromJson(Map<String, dynamic> json) {
    return RouteParameter(
      name: json['name'] as String,
      type: json['type'] as String,
      isRequired: json['isRequired'] as bool,
      isNamed: json['isNamed'] as bool,
      defaultValue: json['defaultValue'] as String?,
      isParam: json['isParam'] as bool,
      isPrimitive: json['isPrimitive'] as bool,
    );
  }
}
