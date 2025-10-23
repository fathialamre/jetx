import '../models/route_config.dart';
import '../models/route_parameter.dart';

/// Generates route class code.
class RouteClassGenerator {
  /// Generates the full route class code.
  String generate(RouteConfig config) {
    final buffer = StringBuffer();

    // Class declaration and documentation
    buffer.writeln('/// Route class for [${config.className}].');
    buffer.writeln('class ${config.routeClassName} {');
    buffer.writeln('  ${config.routeClassName}._();');
    buffer.writeln();

    // Path constant
    buffer.writeln("  /// Route path: '${config.path}'");
    buffer.writeln("  static const String path = '${config.path}';");
    buffer.writeln();

    // Page factory method
    _generatePageMethod(buffer, config);

    // Helper methods for parameters and arguments
    _generateBuildParametersMethod(buffer, config);
    _generateBuildArgumentsMethod(buffer, config);

    // Navigation helper methods
    _generatePushMethod(buffer, config);
    _generateOffMethod(buffer, config);
    _generateOffAllMethod(buffer, config);

    buffer.writeln('}');

    return buffer.toString();
  }

  void _generatePageMethod(StringBuffer buffer, RouteConfig config) {
    buffer.writeln('  /// Creates an instance of [${config.className}].');
    buffer.writeln('  static ${config.className} page() {');

    if (!config.hasParameters) {
      buffer.writeln('    return ${config.className}();');
    } else {
      // Extract parameters from Jet.parameters and Jet.arguments
      for (final param in config.urlParameters) {
        _writeParameterExtraction(buffer, param);
      }

      if (config.hasArgumentParameters) {
        buffer.writeln('    final args = Jet.arguments;');
      }

      // Call constructor with extracted parameters
      buffer.writeln('    return ${config.className}(');
      for (final param in config.parameters) {
        if (param.isParam) {
          buffer.writeln('      ${param.name}: ${param.name}Value,');
        } else {
          if (param.type.contains('<') && param.type.contains('>')) {
            // Generic type, use 'as' cast
            buffer.writeln('      ${param.name}: args as ${param.type},');
          } else {
            buffer.writeln('      ${param.name}: args as ${param.type},');
          }
        }
      }
      buffer.writeln('    );');
    }

    buffer.writeln('  }');
    buffer.writeln();
  }

  void _generatePushMethod(StringBuffer buffer, RouteConfig config) {
    _generateNavigationMethod(
      buffer,
      config,
      'push',
      'Pushes [${config.className}] onto the navigation stack.',
      'Jet.toNamed<T>',
    );
  }

  void _generateReplaceMethod(StringBuffer buffer, RouteConfig config) {
    _generateNavigationMethod(
      buffer,
      config,
      'replace',
      'Replaces the current route with [${config.className}].',
      'Jet.offNamed<T>',
    );
  }

  void _generateOffMethod(StringBuffer buffer, RouteConfig config) {
    _generateNavigationMethod(
      buffer,
      config,
      'off',
      'Replaces the current route with [${config.className}].',
      'Jet.offNamed<T>',
    );
  }

  void _generateOffAllMethod(StringBuffer buffer, RouteConfig config) {
    _generateNavigationMethod(
      buffer,
      config,
      'offAll',
      'Removes all routes and pushes [${config.className}].',
      'Jet.offAllNamed<T>',
    );
  }

  void _generateToNamedMethod(StringBuffer buffer, RouteConfig config) {
    _generateNavigationMethod(
      buffer,
      config,
      'toNamed',
      'Navigates to [${config.className}] using named route.',
      'Jet.toNamed<T>',
    );
  }

  void _generateOffNamedMethod(StringBuffer buffer, RouteConfig config) {
    _generateNavigationMethod(
      buffer,
      config,
      'offNamed',
      'Replaces route with [${config.className}] using named route.',
      'Jet.offNamed<T>',
    );
  }

  void _generateOffAllNamedMethod(StringBuffer buffer, RouteConfig config) {
    _generateNavigationMethod(
      buffer,
      config,
      'offAllNamed',
      'Clears stack and navigates to [${config.className}].',
      'Jet.offAllNamed<T>',
    );
  }

  /// Helper method to generate navigation methods with reduced duplication
  void _generateNavigationMethod(
    StringBuffer buffer,
    RouteConfig config,
    String methodName,
    String description,
    String jetMethod,
  ) {
    buffer.writeln('  /// $description');
    buffer.write('  static Future<T?>? $methodName<T>(');
    _writeMethodParameters(buffer, config);
    buffer.writeln(') {');
    _writeNavigationCall(buffer, config, jetMethod);
    buffer.writeln('  }');
    buffer.writeln();
  }

  void _writeMethodParameters(StringBuffer buffer, RouteConfig config) {
    if (!config.hasParameters) {
      return;
    }

    buffer.writeln('{');
    for (final param in config.parameters) {
      if (param.isRequired) {
        buffer.write('    required ');
      } else {
        buffer.write('    ');
      }
      buffer.write('${param.type} ${param.name}');
      if (param.defaultValue != null) {
        buffer.write(' = ${param.defaultValue}');
      }
      buffer.writeln(',');
    }
    buffer.write('  }');
  }

  void _writeNavigationCall(
    StringBuffer buffer,
    RouteConfig config,
    String method,
  ) {
    buffer.writeln('    return $method(');
    buffer.writeln('      path,');

    if (config.hasUrlParameters) {
      buffer.write('      parameters: _buildParameters(');
      for (int i = 0; i < config.urlParameters.length; i++) {
        final param = config.urlParameters[i];
        buffer.write('${param.name}: ${param.name}');
        if (i < config.urlParameters.length - 1) {
          buffer.write(', ');
        }
      }
      buffer.writeln('),');
    }

    if (config.hasArgumentParameters) {
      buffer.write('      arguments: _buildArguments(');
      for (int i = 0; i < config.argumentParameters.length; i++) {
        final param = config.argumentParameters[i];
        buffer.write('${param.name}: ${param.name}');
        if (i < config.argumentParameters.length - 1) {
          buffer.write(', ');
        }
      }
      buffer.writeln('),');
    }

    buffer.writeln('    );');
  }

  void _writeParameterSerialization(StringBuffer buffer, RouteParameter param) {
    if (param.isRequired) {
      buffer.write("        '${param.name}': ");
      _writeToString(buffer, param);
      buffer.writeln(',');
    } else {
      buffer.write("        if (${param.name} != null) '${param.name}': ");
      _writeToString(buffer, param);
      buffer.writeln(',');
    }
  }

  void _writeToString(StringBuffer buffer, RouteParameter param) {
    if (param.type == 'String' || param.type == 'String?') {
      buffer.write(param.name);
    } else {
      buffer.write('${param.name}.toString()');
    }
  }

  /// Generates the _buildParameters helper method
  void _generateBuildParametersMethod(StringBuffer buffer, RouteConfig config) {
    if (!config.hasUrlParameters) return;

    buffer.writeln('  static Map<String, String> _buildParameters({');
    for (final param in config.urlParameters) {
      if (param.isRequired) {
        buffer.write('    required ');
      } else {
        buffer.write('    ');
      }
      buffer.write('${param.type} ${param.name}');
      if (param.defaultValue != null) {
        buffer.write(' = ${param.defaultValue}');
      }
      buffer.writeln(',');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return {');
    for (final param in config.urlParameters) {
      if (param.isRequired) {
        buffer.writeln("      '${param.name}': ${param.name},");
      } else {
        buffer.writeln(
          "      if (${param.name} != null) '${param.name}': ${param.name},",
        );
      }
    }
    buffer.writeln('    };');
    buffer.writeln('  }');
    buffer.writeln();
  }

  /// Generates the _buildArguments helper method
  void _generateBuildArgumentsMethod(StringBuffer buffer, RouteConfig config) {
    if (!config.hasArgumentParameters) return;

    buffer.writeln('  static dynamic _buildArguments({');
    for (final param in config.argumentParameters) {
      if (param.isRequired) {
        buffer.write('    required ');
      } else {
        buffer.write('    ');
      }
      buffer.write('${param.type} ${param.name}');
      if (param.defaultValue != null) {
        buffer.write(' = ${param.defaultValue}');
      }
      buffer.writeln(',');
    }
    buffer.writeln('  }) {');

    if (config.argumentParameters.length == 1) {
      // Single argument - return directly
      final param = config.argumentParameters.first;
      buffer.writeln('    return ${param.name};');
    } else {
      // Multiple arguments - return as map
      buffer.writeln('    return {');
      for (final param in config.argumentParameters) {
        buffer.writeln("      '${param.name}': ${param.name},");
      }
      buffer.writeln('    };');
    }

    buffer.writeln('  }');
    buffer.writeln();
  }

  void _writeParameterExtraction(StringBuffer buffer, RouteParameter param) {
    final varName = '${param.name}Value';

    if (param.type == 'String' || param.type == 'String?') {
      if (param.isRequired) {
        buffer.writeln(
          "    final $varName = Jet.parameters['${param.name}']!;",
        );
      } else {
        buffer.writeln("    final $varName = Jet.parameters['${param.name}'];");
      }
    } else if (param.type == 'int' || param.type == 'int?') {
      if (param.isRequired) {
        buffer.writeln(
          "    final $varName = int.parse(Jet.parameters['${param.name}']!);",
        );
      } else {
        buffer.writeln(
          "    final ${varName}Str = Jet.parameters['${param.name}'];",
        );
        buffer.writeln(
          "    final $varName = ${varName}Str != null ? int.tryParse(${varName}Str) : null;",
        );
      }
    } else if (param.type == 'double' || param.type == 'double?') {
      if (param.isRequired) {
        buffer.writeln(
          "    final $varName = double.parse(Jet.parameters['${param.name}']!);",
        );
      } else {
        buffer.writeln(
          "    final ${varName}Str = Jet.parameters['${param.name}'];",
        );
        buffer.writeln(
          "    final $varName = ${varName}Str != null ? double.tryParse(${varName}Str) : null;",
        );
      }
    } else if (param.type == 'bool' || param.type == 'bool?') {
      if (param.isRequired) {
        buffer.writeln(
          "    final $varName = Jet.parameters['${param.name}'] == 'true';",
        );
      } else {
        buffer.writeln(
          "    final ${varName}Str = Jet.parameters['${param.name}'];",
        );
        buffer.writeln(
          "    final $varName = ${varName}Str != null ? ${varName}Str == 'true' : null;",
        );
      }
    }
  }
}
