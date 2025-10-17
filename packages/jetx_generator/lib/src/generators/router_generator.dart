import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import '../models/router_config.dart';
import '../models/route_config.dart';

class RouterCodeGenerator {
  static String generate(RouterConfig config) {
    final library = Library((b) {
      // Add necessary imports
      b.directives.add(Directive.import('package:flutter/material.dart'));

      // Generate all route classes
      for (final route in config.routes) {
        b.body.add(_generateRouteClass(route));
      }

      // DON'T generate AppRouter class - user defines it manually
      // b.body.add(_generateAppRouterClass(config.routes));
    });

    final emitter = DartEmitter(
      allocator: Allocator.simplePrefixing(),
      useNullSafetySyntax: true,
    );

    return DartFormatter().format('${library.accept(emitter)}');
  }

  static Class _generateRouteClass(RouteConfig config) {
    final hasArguments = config.parameters.any((p) => p.isArgument);

    return Class((b) {
      b.name = '${config.className}Route';
      b.extend = refer('NavigableRoute');

      // Add fields for parameters
      for (final param in config.parameters) {
        b.fields.add(Field((f) {
          f.name = param.name;
          f.type = refer(param.type);
          f.modifier = FieldModifier.final$;
        }));
      }

      // Add constructor
      b.constructors.add(_generateConstructor(config));

      // Add static path getter
      b.methods.add(_generateStaticPathGetter(config));

      // Add static page builder
      b.methods.add(_generateStaticPageBuilder(config));

      // Add instance path getter with @override annotation
      b.methods.add(_generatePathGetter(config));

      // Override navigation methods if has arguments
      if (hasArguments) {
        b.methods.add(_generatePushOverride(config));
        b.methods.add(_generatePushReplacementOverride(config));
        b.methods.add(_generatePushAndRemoveUntilOverride(config));
        b.methods.add(_generatePushAndRemoveAllOverride(config));
      }
    });
  }

  static Constructor _generateConstructor(RouteConfig config) {
    return Constructor((b) {
      b.constant = true;

      for (final param in config.parameters) {
        b.optionalParameters.add(Parameter((p) {
          p.name = param.name;
          p.named = true;
          p.toThis = true;
          p.required = param.isRequired;
        }));
      }
    });
  }

  /// Generate static path getter - returns the route's base path
  static Method _generateStaticPathGetter(RouteConfig config) {
    return Method((b) {
      b.name = 'routePath';
      b.type = MethodType.getter;
      b.static = true;
      b.returns = refer('String');
      b.lambda = true;
      b.body = Code("'${config.routePath}'");
    });
  }

  /// Generate static page builder - returns a function that extracts params and returns page widget
  static Method _generateStaticPageBuilder(RouteConfig config) {
    return Method((m) {
      m.name = 'page';
      m.type = MethodType.getter;
      m.static = true;
      m.returns = refer('Widget Function()');
      m.lambda = true;
      m.body = Code('() { ${_generatePageBuilderCode(config)} }');
    });
  }

  /// Generate the code for the static page builder
  static String _generatePageBuilderCode(RouteConfig config) {
    final buffer = StringBuffer();

    final urlParams = config.parameters.where((p) => !p.isArgument).toList();
    final argumentParams =
        config.parameters.where((p) => p.isArgument).toList();

    // Extract URL parameters (path + query params)
    for (final param in urlParams) {
      if (param.isPath) {
        // Path parameters
        buffer.writeln(
            "final ${param.name} = ${_getParameterExtraction(param)};");
      } else {
        // Query parameters
        if (param.isRequired) {
          buffer.writeln(
              "final ${param.name} = ${_getParameterExtraction(param)};");
        } else {
          // Optional query parameter
          final conversion =
              _getParameterConversion(param, "Jet.parameters['${param.name}']");
          final needsConversion =
              conversion != "Jet.parameters['${param.name}']";

          if (needsConversion) {
            buffer.writeln(
                "final ${param.name}Str = Jet.parameters['${param.name}'];");
            buffer.writeln(
                "final ${param.name} = ${param.name}Str != null ? ${_getParameterConversion(param, '${param.name}Str')} : null;");
          } else {
            buffer.writeln(
                "final ${param.name} = Jet.parameters['${param.name}'];");
          }
        }
      }
    }

    // Extract arguments (complex objects from Jet.arguments)
    if (argumentParams.isNotEmpty) {
      final hasRequiredArg = argumentParams.any((p) => p.isRequired);

      if (hasRequiredArg) {
        buffer.writeln('final args = Jet.arguments as Map;');
      } else {
        buffer.writeln('final args = Jet.arguments as Map?;');
      }

      for (final param in argumentParams) {
        if (param.isRequired) {
          buffer.writeln(
              "final ${param.name} = args['${param.name}'] as ${param.type};");
        } else {
          buffer.writeln(
              "final ${param.name} = args?['${param.name}'] as ${param.type};");
        }
      }
    }

    // Instantiate and return page
    buffer.write('return ${config.className}(');
    for (final param in config.parameters) {
      buffer.write('${param.name}: ${param.name}, ');
    }
    buffer.writeln(');');

    return buffer.toString();
  }

  static Method _generatePathGetter(RouteConfig config) {
    // Only include URL parameters (not arguments) in the path
    final pathParams =
        config.parameters.where((p) => p.isPath && !p.isArgument).toList();
    final queryParams =
        config.parameters.where((p) => !p.isPath && !p.isArgument).toList();

    // Choose strategy based on query param count
    if (queryParams.isEmpty) {
      return _generatePathGetterNoQuery(config, pathParams);
    } else if (queryParams.length == 1) {
      return _generatePathGetterOneQuery(config, pathParams, queryParams.first);
    } else {
      return _generatePathGetterMultiQuery(config, pathParams, queryParams);
    }
  }

  /// Generate path string with regex-based parameter replacement
  static String _buildPathString(
      String routePath, List<ParamConfig> pathParams) {
    if (pathParams.isEmpty) {
      return routePath;
    }

    // Use regex replacement for cleaner code - replaces :paramName with $paramName
    return routePath.replaceAllMapped(
      RegExp(r':(\w+)'),
      (match) => '\$${match.group(1)}',
    );
  }

  /// Generate path getter for routes with no query parameters (inline lambda)
  static Method _generatePathGetterNoQuery(
      RouteConfig config, List<ParamConfig> pathParams) {
    final pathExpression = _buildPathString(config.routePath, pathParams);

    return Method((b) {
      b.name = 'path';
      b.type = MethodType.getter;
      b.returns = refer('String');
      b.annotations.add(refer('override'));
      b.lambda = true;
      b.body = Code("'$pathExpression'");
    });
  }

  /// Generate path getter for routes with one query parameter (inline ternary)
  static Method _generatePathGetterOneQuery(
    RouteConfig config,
    List<ParamConfig> pathParams,
    ParamConfig queryParam,
  ) {
    final basePath = _buildPathString(config.routePath, pathParams);
    final paramName = queryParam.name;

    // Only add null check for optional (nullable) parameters
    final expression = queryParam.isRequired
        ? "'$basePath?$paramName=\$$paramName'"
        : "'$basePath' + ($paramName != null ? '?$paramName=\$$paramName' : '')";

    return Method((b) {
      b.name = 'path';
      b.type = MethodType.getter;
      b.returns = refer('String');
      b.annotations.add(refer('override'));
      b.lambda = true;
      b.body = Code(expression);
    });
  }

  /// Generate path getter for routes with multiple query parameters (method body)
  static Method _generatePathGetterMultiQuery(
    RouteConfig config,
    List<ParamConfig> pathParams,
    List<ParamConfig> queryParams,
  ) {
    final basePath = _buildPathString(config.routePath, pathParams);
    final buffer = StringBuffer();

    buffer.writeln('final queryParams = <String>[];');
    for (final param in queryParams) {
      // Only add null check for optional (nullable) parameters
      if (param.isRequired) {
        buffer.writeln("queryParams.add('${param.name}=\$${param.name}');");
      } else {
        buffer.writeln(
            "if (${param.name} != null) queryParams.add('${param.name}=\$${param.name}');");
      }
    }
    buffer.writeln(
        "return queryParams.isEmpty ? '$basePath' : '$basePath?\${queryParams.join('&')}';");

    return Method((b) {
      b.name = 'path';
      b.type = MethodType.getter;
      b.returns = refer('String');
      b.annotations.add(refer('override'));
      b.body = Code(buffer.toString());
    });
  }

  /// Generate AppRouter class with empty getPages for manual registration
  static Class _generateAppRouterClass(List<RouteConfig> routes) {
    return Class((b) {
      b.name = 'AppRouter';

      // Add static getPages getter
      b.methods.add(Method((m) {
        m.name = 'getPages';
        m.type = MethodType.getter;
        m.static = true;
        m.returns = refer('List<JetPage>');
        m.body = Code(_buildAppRouterGetPagesCode(routes));
      }));
    });
  }

  /// Generate the body of the getPages getter with TODO comments
  static String _buildAppRouterGetPagesCode(List<RouteConfig> routes) {
    final buffer = StringBuffer();
    buffer.writeln('return [');
    buffer.writeln('  // TODO: Register your routes here');
    buffer.writeln('  // Use the static helpers on route classes:');
    buffer.writeln('  //');

    // Add example for first route if available
    if (routes.isNotEmpty) {
      final exampleRoute = routes.first;
      buffer.writeln('  // Example for ${exampleRoute.className}:');
      buffer.writeln('  // JetPage(');
      buffer.writeln('  //   name: ${exampleRoute.className}Route.routePath,');
      buffer.writeln('  //   page: ${exampleRoute.className}Route.page,');
      buffer.writeln('  //   binding: BindingsBuilder(() {');
      buffer.writeln('  //     // Add your bindings here');
      buffer.writeln('  //     // Jet.lazyPut(() => YourController());');
      buffer.writeln('  //   }),');
      if (exampleRoute.middlewares.isNotEmpty) {
        buffer.writeln(
            '  //   middlewares: [${exampleRoute.middlewares.map((m) => '$m()').join(', ')}],');
      }
      buffer.writeln(
          '  //   fullscreenDialog: ${exampleRoute.fullscreenDialog},');
      buffer.writeln('  //   maintainState: ${exampleRoute.maintainState},');
      buffer.writeln(
          '  //   preventDuplicates: ${exampleRoute.preventDuplicates},');
      buffer.writeln('  // ),');
    }

    buffer.writeln('];');
    return buffer.toString();
  }

  static String _getParameterExtraction(ParamConfig param) {
    final paramAccess = "Jet.parameters['${param.name}']!";
    return _getParameterConversion(param, paramAccess);
  }

  static String _getParameterConversion(ParamConfig param, String accessor) {
    // Type-safe parameter extraction based on type
    final typeWithoutNullability = param.type.replaceAll('?', '');

    if (typeWithoutNullability == 'int') {
      return "int.parse($accessor)";
    } else if (typeWithoutNullability == 'double') {
      return "double.parse($accessor)";
    } else if (typeWithoutNullability == 'bool') {
      return "$accessor == 'true'";
    } else if (typeWithoutNullability == 'num') {
      return "num.parse($accessor)";
    }
    return accessor;
  }

  // ==================== Navigation Method Overrides ====================

  static Method _generatePushOverride(RouteConfig config) {
    final argumentParams =
        config.parameters.where((p) => p.isArgument).toList();

    return Method((b) {
      b.name = 'push';
      b.returns = refer('Future<T?>?');
      b.types.add(refer('T'));
      b.annotations.add(refer('override'));
      b.body = Code('''
return Jet.toNamed<T>(
  path,
  arguments: ${_buildArgumentsMap(argumentParams)},
);
''');
    });
  }

  static Method _generatePushReplacementOverride(RouteConfig config) {
    final argumentParams =
        config.parameters.where((p) => p.isArgument).toList();

    return Method((b) {
      b.name = 'pushReplacement';
      b.returns = refer('Future<T?>?');
      b.types.add(refer('T'));
      b.annotations.add(refer('override'));
      b.body = Code('''
return Jet.offNamed<T>(
  path,
  arguments: ${_buildArgumentsMap(argumentParams)},
);
''');
    });
  }

  static Method _generatePushAndRemoveUntilOverride(RouteConfig config) {
    final argumentParams =
        config.parameters.where((p) => p.isArgument).toList();

    return Method((b) {
      b.name = 'pushAndRemoveUntil';
      b.returns = refer('Future<T?>?');
      b.types.add(refer('T'));
      b.requiredParameters.add(Parameter((p) {
        p.name = 'predicate';
        p.type = refer('bool Function(JetPage)?');
      }));
      b.annotations.add(refer('override'));
      b.body = Code('''
return Jet.offNamedUntil<T>(
  path,
  predicate,
  arguments: ${_buildArgumentsMap(argumentParams)},
);
''');
    });
  }

  static Method _generatePushAndRemoveAllOverride(RouteConfig config) {
    final argumentParams =
        config.parameters.where((p) => p.isArgument).toList();

    return Method((b) {
      b.name = 'pushAndRemoveAll';
      b.returns = refer('Future<T?>?');
      b.types.add(refer('T'));
      b.annotations.add(refer('override'));
      b.body = Code('''
return Jet.offAllNamed<T>(
  path,
  arguments: ${_buildArgumentsMap(argumentParams)},
);
''');
    });
  }

  static String _buildArgumentsMap(List<ParamConfig> argumentParams) {
    if (argumentParams.isEmpty) return 'null';

    final entries =
        argumentParams.map((p) => "'${p.name}': ${p.name}").join(', ');
    return '{$entries}';
  }
}
