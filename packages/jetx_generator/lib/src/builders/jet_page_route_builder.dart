import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import 'package:source_gen/source_gen.dart';

import '../models/routes_list.dart';
import '../resolvers/route_config_resolver.dart';

/// Builder that scans for @RoutablePage annotations and generates cache files.
class JetPageRouteBuilder implements Builder {
  final _resolver = RouteConfigResolver();
  static final _typeChecker = TypeChecker.fromRuntime(RoutablePage);

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.route.json'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;

    final library = await resolver.libraryFor(buildStep.inputId);
    final reader = LibraryReader(library);

    final annotatedElements = reader.annotatedWith(_typeChecker);
    if (annotatedElements.isEmpty) return;

    final routes = [];

    for (final element in annotatedElements) {
      if (element.element is! ClassElement) {
        log.warning(
          'RoutablePage can only be used on classes. '
          'Found on ${element.element.displayName}',
        );
        continue;
      }

      final classElement = element.element as ClassElement;
      final annotation = element.annotation;

      try {
        final route = _resolver.resolve(
          classElement,
          annotation,
          buildStep.inputId.path,
        );
        routes.add(route.toJson());
      } catch (e, stackTrace) {
        log.severe(
          'Error resolving route for ${classElement.displayName}: $e',
          e,
          stackTrace,
        );
      }
    }

    if (routes.isNotEmpty) {
      final routesList = RoutesList(
        routes: routes
            .map(
              (json) => _resolver.resolve(
                library.topLevelElements.whereType<ClassElement>().firstWhere(
                  (e) => e.displayName == json['className'],
                ),
                annotatedElements
                    .firstWhere(
                      (e) => e.element.displayName == json['className'],
                    )
                    .annotation,
                buildStep.inputId.path,
              ),
            )
            .toList(),
        filePath: buildStep.inputId.path,
      );

      final outputId = buildStep.inputId.changeExtension('.route.json');
      await buildStep.writeAsString(outputId, jsonEncode(routesList.toJson()));
    }
  }
}

/// Factory function for build_runner.
Builder jetPageRouteBuilder(BuilderOptions options) => JetPageRouteBuilder();
