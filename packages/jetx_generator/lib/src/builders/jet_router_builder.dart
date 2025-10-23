import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import 'package:source_gen/source_gen.dart';

import '../code_builder/library_generator.dart';
import '../models/route_config.dart';
import '../models/router_config.dart';
import '../models/routes_list.dart';
import '../resolvers/router_config_resolver.dart';

/// Builder that generates the final .g.dart file with all routes.
class JetRouterBuilder implements Builder {
  final _routerResolver = RouterConfigResolver();
  final _libraryGenerator = LibraryGenerator();
  final _formatter = DartFormatter();

  static final _typeChecker = TypeChecker.fromRuntime(JetRouteConfig);

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;

    final library = await resolver.libraryFor(buildStep.inputId);
    final reader = LibraryReader(library);

    final annotatedElements = reader.annotatedWith(_typeChecker);
    if (annotatedElements.isEmpty) return;

    final element = annotatedElements.first.element;
    if (element is! ClassElement) {
      log.warning(
        'JetRouteConfig can only be used on classes. '
        'Found on ${element.displayName}',
      );
      return;
    }

    final annotation = annotatedElements.first.annotation;

    // Check if class uses part directive
    final usesPartBuilder = _hasPartDirective(library, buildStep.inputId);

    final routerConfig = _routerResolver.resolve(
      element,
      annotation,
      buildStep.inputId.path,
      usesPartBuilder,
    );

    // Collect all routes from .route.json files
    final routes = await _collectRoutes(buildStep, routerConfig);

    if (routes.isEmpty) {
      log.info('No routes found for ${routerConfig.routerClassName}');
      // Still generate an empty file
    }

    // Generate the library
    final generatedContent = _libraryGenerator.generate(routerConfig, routes);

    // Format the code
    String formatted;
    try {
      formatted = _formatter.format(generatedContent);
    } catch (e) {
      log.warning('Failed to format generated code: $e');
      formatted = generatedContent;
    }

    // Write the output
    final outputId = buildStep.inputId.changeExtension('.g.dart');
    await buildStep.writeAsString(outputId, formatted);
  }

  /// Checks if the library has a part directive for the generated file.
  bool _hasPartDirective(LibraryElement library, AssetId inputId) {
    final fileName = inputId.path.split('/').last;
    final expectedPart = fileName.replaceAll('.dart', '.g.dart');

    final parts = library.parts;
    return parts.any((part) {
      return part.source.fullName.endsWith(expectedPart);
    });
  }

  /// Collects all routes from .route.json files in specified directories.
  Future<List<RouteConfig>> _collectRoutes(
    BuildStep buildStep,
    RouterConfig routerConfig,
  ) async {
    final routes = <RouteConfig>[];
    final glob = Glob('**.route.json');

    log.info(
      'Scanning for route.json files in directories: ${routerConfig.generateForDir}',
    );

    await for (final asset in buildStep.findAssets(glob)) {
      log.info('Found asset: ${asset.path}');

      final shouldInclude = routerConfig.generateForDir.any(
        (dir) => asset.path.startsWith(dir),
      );

      log.info('Should include ${asset.path}: $shouldInclude');

      if (!shouldInclude) continue;

      try {
        final jsonString = await buildStep.readAsString(asset);
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final routesList = RoutesList.fromJson(json);
        log.info(
          'Loaded ${routesList.routes.length} routes from ${asset.path}',
        );
        routes.addAll(routesList.routes);
      } catch (e) {
        log.warning('Failed to read route file ${asset.path}: $e');
      }
    }

    log.info('Total routes collected: ${routes.length}');

    // Sort routes by class name for consistent output
    routes.sort((a, b) => a.className.compareTo(b.className));

    return routes;
  }
}

/// Factory function for build_runner.
Builder jetRouterBuilder(BuilderOptions options) => JetRouterBuilder();
