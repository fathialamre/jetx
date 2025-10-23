import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../models/route_config.dart';
import '../models/route_parameter.dart';

const _jetParamsChecker = TypeChecker.fromRuntime(_JetParams);
const _jetArgsChecker = TypeChecker.fromRuntime(_JetArgs);

// Marker classes for type checking
class _JetParams {
  const _JetParams();
}

class _JetArgs {
  const _JetArgs();
}

/// Resolves route configuration from annotated classes.
class RouteConfigResolver {
  /// Resolves a class element into a route configuration.
  RouteConfig resolve(
    ClassElement classElement,
    ConstantReader annotation,
    String filePath,
  ) {
    final className = classElement.name;
    final routeClassName = '${className}Route';

    // Get custom path or generate from class name
    final customPath = annotation.peek('path')?.stringValue;
    final path = customPath ?? _generatePath(className);

    // Get constructor parameters
    final constructor = _findMainConstructor(classElement);
    final parameters = constructor != null
        ? _extractParameters(constructor)
        : <RouteParameter>[];

    // Generate import statement
    final import = "import '${_getRelativeImport(filePath)}';";

    return RouteConfig(
      className: className,
      routeClassName: routeClassName,
      path: path,
      filePath: filePath,
      parameters: parameters,
      import: import,
    );
  }

  /// Generates a path from class name (e.g., HomePage -> /home-page)
  String _generatePath(String className) {
    // Remove 'Page' suffix if present
    var name = className;
    if (name.endsWith('Page')) {
      name = name.substring(0, name.length - 4);
    }

    // Convert PascalCase to kebab-case
    final kebabCase = name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '-${match.group(0)!.toLowerCase()}',
    );

    // Remove leading dash and add leading slash
    return '/${kebabCase.substring(1)}';
  }

  /// Finds the main constructor (unnamed or first named constructor)
  ConstructorElement? _findMainConstructor(ClassElement classElement) {
    if (classElement.constructors.isEmpty) return null;

    // Try unnamed constructor first
    try {
      return classElement.constructors.firstWhere((c) => c.name == '');
    } catch (e) {
      // If no unnamed constructor, return the first one
      return classElement.constructors.first;
    }
  }

  /// Extracts parameters from a constructor
  List<RouteParameter> _extractParameters(ConstructorElement constructor) {
    final parameters = <RouteParameter>[];

    for (final param in constructor.parameters) {
      // Skip 'key' parameter as it's a Flutter framework parameter
      if (param.name == 'key') continue;

      final type = param.type;
      final typeName = _getTypeName(type);
      final isPrimitive = _isPrimitiveType(type);

      // Check for @JetParams or @JetArgs annotations
      bool? explicitIsParam;
      for (final annotation in param.metadata) {
        final annotationElement = annotation.element;
        if (annotationElement != null) {
          if (_jetParamsChecker.isExactlyType(
                annotationElement.library!.typeProvider.dynamicType,
              ) ||
              annotation.toSource().contains('JetParams')) {
            explicitIsParam = true;
            break;
          }
          if (_jetArgsChecker.isExactlyType(
                annotationElement.library!.typeProvider.dynamicType,
              ) ||
              annotation.toSource().contains('JetArgs')) {
            explicitIsParam = false;
            break;
          }
        }
      }

      // Determine if this should be a param or arg
      // If explicitly annotated, use that; otherwise use auto-detection
      final isParam = explicitIsParam ?? isPrimitive;

      final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
      final hasDefaultValue = param.defaultValueCode != null;
      final isRequired = param.isRequired || (!isNullable && !hasDefaultValue);

      parameters.add(
        RouteParameter(
          name: param.name,
          type: typeName,
          isRequired: isRequired,
          isNamed: param.isNamed,
          defaultValue: param.defaultValueCode,
          isParam: isParam,
          isPrimitive: isPrimitive,
        ),
      );
    }

    return parameters;
  }

  /// Gets the string representation of a type
  String _getTypeName(DartType type) {
    return type.getDisplayString(withNullability: true);
  }

  /// Checks if a type is primitive (can be passed as URL parameter)
  bool _isPrimitiveType(DartType type) {
    final typeName = type.element?.name;
    return typeName == 'String' ||
        typeName == 'int' ||
        typeName == 'double' ||
        typeName == 'bool' ||
        typeName == 'num';
  }

  /// Gets relative import path
  String _getRelativeImport(String filePath) {
    // Remove 'lib/' prefix if present
    if (filePath.startsWith('lib/')) {
      return filePath.substring(4);
    }
    return filePath;
  }
}
