import 'package:analyzer/dart/element/element.dart';
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

    final routes = <RouteConfig>[];
    final imports = <String, String>{};

    // Scan the current library and all imported libraries recursively for @RoutePage classes
    final library = element.library;
    final librariesToScan = <LibraryElement>{};
    final visitedLibraries = <String>{};

    // Recursively collect all imported libraries
    void collectLibraries(LibraryElement lib) {
      final uri = lib.source.uri.toString();
      // Skip already visited libraries and dart/flutter core libraries
      if (visitedLibraries.contains(uri) ||
          uri.startsWith('dart:') ||
          uri.startsWith('package:flutter/')) {
        return;
      }
      visitedLibraries.add(uri);
      librariesToScan.add(lib);

      // Recursively scan imports
      for (final import in lib.libraryImports) {
        final importedLibrary = import.importedLibrary;
        if (importedLibrary != null) {
          collectLibraries(importedLibrary);
        }
      }
    }

    collectLibraries(library);

    // Scan all libraries for @RoutePage classes
    for (final lib in librariesToScan) {
      for (final libraryElement in lib.topLevelElements) {
        if (libraryElement is! ClassElement) continue;

        // Check if class has @RoutePage annotation
        final routePageAnnotation = TypeChecker.fromRuntime(RoutePage)
            .firstAnnotationOf(libraryElement);

        if (routePageAnnotation == null) continue;

        // Parse this route
        final routeConfig = RouteParser.parseClass(libraryElement);
        if (routeConfig != null) {
          routes.add(routeConfig);

          // Store import path for this route
          final importPath = _getImportPath(libraryElement);
          if (importPath != null) {
            imports[routeConfig.className] = importPath;
          }

          // Store import paths for bindings
          await _collectBindingImports(routeConfig, resolver, imports);
        }
      }
    }

    return RouterConfig(
      className: element.name,
      routes: routes,
      imports: imports,
    );
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
