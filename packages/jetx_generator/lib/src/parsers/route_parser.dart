import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:source_gen/source_gen.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import '../models/route_config.dart';

class RouteParser {
  static RouteConfig? parseClass(ClassElement element) {
    // Check for @RoutePage annotation
    final annotation =
        TypeChecker.fromRuntime(RoutePage).firstAnnotationOf(element);

    if (annotation == null) return null;

    // Extract path or generate from class name
    final customPath = annotation.getField('path')?.toStringValue();
    final generatedPath = _generatePathFromClassName(element.name);
    final routePath = customPath ?? generatedPath;

    // Parse constructor parameters
    final constructor = element.unnamedConstructor;
    final parameters = <ParamConfig>[];

    if (constructor != null) {
      for (final param in constructor.parameters) {
        // Skip 'key' parameter
        if (param.name == 'key') continue;
        parameters.add(_parseParameter(param, routePath));
      }
    }

    // Parse transition
    final transition = _parseTransition(annotation);

    return RouteConfig(
      className: element.name,
      routeName: routePath,
      routePath: routePath,
      parameters: parameters,
      bindings: [],
      middlewares: [],
      transition: transition,
      fullscreenDialog:
          annotation.getField('fullscreenDialog')?.toBoolValue() ?? false,
      maintainState:
          annotation.getField('maintainState')?.toBoolValue() ?? true,
      preventDuplicates:
          annotation.getField('preventDuplicates')?.toBoolValue() ?? true,
    );
  }

  static String _generatePathFromClassName(String className) {
    // UserDetailPage -> /user-detail
    // HomePage -> /home
    // Convert PascalCase to kebab-case, remove 'Page' suffix
    final withoutPage = className.endsWith('Page')
        ? className.substring(0, className.length - 4)
        : className;

    if (withoutPage.isEmpty) return '/';

    return '/${withoutPage.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '-${m[0]!.toLowerCase()}').substring(1)}'; // Remove leading dash
  }

  static ParamConfig _parseParameter(
    ParameterElement param,
    String routePath,
  ) {
    final paramName = param.name;
    final paramType = param.type.getDisplayString(withNullability: true);

    // Check for explicit @ArgumentParam annotation
    final argAnnotation =
        TypeChecker.fromRuntime(ArgumentParam).firstAnnotationOf(param);
    final hasArgAnnotation = argAnnotation != null;

    // Check if parameter is in path (exact match with word boundaries)
    final isPath = RegExp(r':' + paramName + r'(?:/|$|\?)').hasMatch(routePath);

    // Auto-detect if type is complex (not primitive)
    final isComplex = !_isPrimitiveType(paramType);

    // If has @ArgumentParam or is complex (and not in path), mark as argument
    final isArgument = hasArgAnnotation || (isComplex && !isPath);

    // Check for @QueryParam annotation
    final queryAnnotation =
        TypeChecker.fromRuntime(QueryParam).firstAnnotationOf(param);

    return ParamConfig(
      name: paramName,
      type: paramType,
      isRequired:
          param.isRequiredNamed || (param.isRequired && !param.hasDefaultValue),
      isPath: isPath,
      isArgument: isArgument,
      defaultValue: queryAnnotation?.getField('defaultValue')?.toStringValue(),
    );
  }

  static bool _isPrimitiveType(String type) {
    final baseType = type.replaceAll('?', '').trim();
    return const [
      'int',
      'double',
      'bool',
      'String',
      'num',
      'DateTime',
    ].contains(baseType);
  }

  static TransitionConfig? _parseTransition(DartObject annotation) {
    final transition = annotation.getField('transition')?.toStringValue();
    if (transition == null) return null;

    return TransitionConfig(
      type: transition,
      durationMs: annotation.getField('transitionDurationMs')?.toIntValue(),
    );
  }
}
