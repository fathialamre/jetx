import '../models/route_config.dart';
import '../models/router_config.dart';
import 'route_class_generator.dart';

/// Generates the complete library file.
class LibraryGenerator {
  final _routeClassGenerator = RouteClassGenerator();

  /// Generates the complete .g.dart file content.
  String generate(RouterConfig router, List<RouteConfig> routes) {
    final buffer = StringBuffer();

    // Header
    _writeHeader(buffer);

    // Part of statement
    _writePartOf(buffer, router);

    // Route classes (no imports in part files)
    _writeRouteClasses(buffer, routes);

    return buffer.toString();
  }

  void _writeHeader(StringBuffer buffer) {
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln(
      '// **************************************************************************',
    );
    buffer.writeln('// JetX Route Generator');
    buffer.writeln(
      '// **************************************************************************',
    );
    buffer.writeln();
    buffer.writeln("// ignore_for_file: type=lint");
    buffer.writeln("// coverage:ignore-file");
    buffer.writeln();
  }

  void _writePartOf(StringBuffer buffer, RouterConfig router) {
    final fileName = router.filePath.split('/').last.replaceAll('.dart', '');
    buffer.writeln("part of '$fileName.dart';");
    buffer.writeln();
  }

  void _writeImports(StringBuffer buffer, List<RouteConfig> routes) {
    buffer.writeln("import 'package:jetx/jet.dart';");

    // Add unique imports from routes
    final imports = routes.map((r) => r.import).toSet().toList();
    imports.sort();

    for (final import in imports) {
      buffer.writeln(import);
    }

    buffer.writeln();
  }

  void _writeRouteClasses(StringBuffer buffer, List<RouteConfig> routes) {
    for (var i = 0; i < routes.length; i++) {
      buffer.writeln(_routeClassGenerator.generate(routes[i]));

      if (i < routes.length - 1) {
        buffer.writeln();
      }
    }
  }
}
