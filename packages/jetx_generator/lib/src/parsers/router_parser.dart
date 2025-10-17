import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import '../models/router_config.dart';
import '../models/route_config.dart';
import 'route_parser.dart';

class RouterParser {
  static Future<RouterConfig?> parseRouter(
    ClassElement element,
    Resolver resolver,
  ) async {
    // Find @JetRouter annotation
    final annotation =
        TypeChecker.fromRuntime(JetRouter).firstAnnotationOf(element);

    if (annotation == null) return null;

    // Extract list of route types
    final routesField = annotation.getField('routes');
    if (routesField == null || routesField.isNull) {
      return null;
    }

    final routesList = routesField.toListValue();
    if (routesList == null || routesList.isEmpty) {
      return null;
    }

    final routes = <RouteConfig>[];
    final imports = <String, String>{};

    // Parse each route type
    for (final routeType in routesList) {
      final type = routeType.toTypeValue();
      if (type == null) continue;

      final routeConfig = await _parseRouteType(type, resolver);
      if (routeConfig != null) {
        routes.add(routeConfig);

        // Store import path for this route
        final typeElement = type.element;
        if (typeElement != null) {
          final importPath = _getImportPath(typeElement);
          if (importPath != null) {
            imports[routeConfig.className] = importPath;
          }
        }

        // Store import paths for bindings
        await _collectBindingImports(routeConfig, resolver, imports);
      }
    }

    return RouterConfig(
      className: element.name,
      routes: routes,
      imports: imports,
    );
  }

  static Future<RouteConfig?> _parseRouteType(
    DartType type,
    Resolver resolver,
  ) async {
    final element = type.element;
    if (element is! ClassElement) return null;

    // Use existing RouteParser
    return RouteParser.parseClass(element);
  }

  static String? _getImportPath(Element element) {
    final uri = element.source?.uri;
    if (uri == null) return null;

    // Convert to package import format
    if (uri.scheme == 'package') {
      return uri.toString();
    } else if (uri.scheme == 'file') {
      // For local files, try to convert to relative import
      final path = uri.path;
      if (path.contains('/lib/')) {
        final libIndex = path.indexOf('/lib/');
        final relativePath = path.substring(libIndex + 5); // Skip '/lib/'
        // Extract package name from path
        final segments = path.split('/');
        for (int i = 0; i < segments.length; i++) {
          if (segments[i] == 'lib' && i > 0) {
            final packageName = segments[i - 1];
            return 'package:$packageName/$relativePath';
          }
        }
      }
    }

    return null;
  }

  /// Collects import paths for all binding types in a route
  static Future<void> _collectBindingImports(
    RouteConfig routeConfig,
    Resolver resolver,
    Map<String, String> imports,
  ) async {
    for (final binding in routeConfig.bindings) {
      final bindingTypeName = binding.controllerType;

      // Use the import path stored in the binding config
      if (binding.importPath != null && !imports.containsKey(bindingTypeName)) {
        imports[bindingTypeName] = binding.importPath!;
      }
    }
  }
}
