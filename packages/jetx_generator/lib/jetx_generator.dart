import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import 'src/parsers/router_parser.dart';
import 'src/generators/router_generator.dart';

class JetXRouterGenerator extends GeneratorForAnnotation<JetRouter> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@JetRouter can only be applied to classes',
        element: element,
      );
    }

    // Scan the library and all imported libraries recursively
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

    final config = await RouterParser.parseRouter(element, buildStep.resolver);
    if (config == null) {
      throw InvalidGenerationSourceError(
        'Failed to parse router configuration',
        element: element,
      );
    }

    return RouterCodeGenerator.generate(config, librariesToScan);
  }
}
