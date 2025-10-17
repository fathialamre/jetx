import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import '../models/route_config.dart';

class RouteCodeGenerator {
  static String generate(RouteConfig config) {
    final library = Library((b) => b.body.addAll([
          _generateRouteClass(config),
          _generateJetPageTopLevelGetter(config),
        ]));

    final emitter = DartEmitter(
      allocator: Allocator.simplePrefixing(),
      useNullSafetySyntax: true,
    );

    return DartFormatter().format('${library.accept(emitter)}');
  }

  static Class _generateRouteClass(RouteConfig config) {
    return Class((b) {
      b.name = '${config.className}Route';

      // Add fields
      for (final param in config.parameters) {
        b.fields.add(Field((f) {
          f.name = param.name;
          f.type = refer(param.type);
          f.modifier = FieldModifier.final$;
        }));
      }

      // Add constructor
      b.constructors.add(_generateConstructor(config));

      // Add path getter
      b.methods.add(_generatePathGetter(config));

      // Add navigation methods
      b.methods.addAll(_generateNavigationMethods());
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

  static Method _generatePathGetter(RouteConfig config) {
    // Generate path with interpolated path params and query string
    final pathParams = config.parameters.where((p) => p.isPath).toList();
    final queryParams = config.parameters.where((p) => !p.isPath).toList();

    String pathExpression = "'${config.routePath}'";

    // Replace :paramName with $paramName
    for (final param in pathParams) {
      pathExpression = pathExpression.replaceAll(
        ':${param.name}',
        '\$${param.name}',
      );
    }

    if (queryParams.isNotEmpty) {
      // Build query string
      final queryParts = <String>[];
      for (final param in queryParams) {
        queryParts.add(
            "if (${param.name} != null) '${param.name}=\$${param.name}' else ''");
      }
      pathExpression +=
          " + ([ ${queryParts.join(', ')} ].where((e) => e.isNotEmpty).isEmpty ? '' : '?' + [ ${queryParts.join(', ')} ].where((e) => e.isNotEmpty).join('&'))";
    }

    return Method((b) {
      b.name = 'path';
      b.type = MethodType.getter;
      b.returns = refer('String');
      b.lambda = true;
      b.body = Code(pathExpression);
    });
  }

  static List<Method> _generateNavigationMethods() {
    return [
      // push() method
      Method((b) {
        b.name = 'push';
        b.returns = refer('Future<T?>?');
        b.types.add(refer('T'));
        b.lambda = true;
        b.body = Code('Jet.toNamed<T>(path)');
      }),

      // pushReplacement() method
      Method((b) {
        b.name = 'pushReplacement';
        b.returns = refer('Future<T?>?');
        b.types.add(refer('T'));
        b.lambda = true;
        b.body = Code('Jet.offNamed<T>(path)');
      }),

      // pushAndRemoveUntil() method
      Method((b) {
        b.name = 'pushAndRemoveUntil';
        b.returns = refer('Future<T?>?');
        b.types.add(refer('T'));
        b.requiredParameters.add(Parameter((p) {
          p.name = 'predicate';
          p.type = refer('bool Function(JetPage)?');
        }));
        b.lambda = true;
        b.body = Code('Jet.offNamedUntil<T>(path, predicate)');
      }),
    ];
  }

  static Method _generateJetPageTopLevelGetter(RouteConfig config) {
    // Generate a camelCase name from the class name (e.g., UserPage -> userPageJetPage)
    final getterName =
        '${config.className[0].toLowerCase()}${config.className.substring(1)}JetPage';

    return Method((b) {
      b.name = getterName;
      b.type = MethodType.getter;
      b.returns = refer('JetPage');
      b.lambda = false;
      b.body = _generateJetPageBody(config);
    });
  }

  static Code _generateJetPageBody(RouteConfig config) {
    // Generate JetPage instantiation with all parameters
    final buffer = StringBuffer();
    buffer.writeln('return JetPage(');
    buffer.writeln("  name: '${config.routePath}',");
    buffer.writeln('  page: () {');

    // Extract parameters from Jet.parameters
    for (final param in config.parameters) {
      if (param.isPath) {
        buffer.writeln(
            "    final ${param.name} = ${_getParameterExtraction(param)};");
      } else {
        // Query parameters
        if (param.isRequired) {
          buffer.writeln(
              "    final ${param.name} = ${_getParameterExtraction(param)};");
        } else {
          // Optional query parameter
          buffer.writeln(
              "    final ${param.name}Str = Jet.parameters['${param.name}'];");
          buffer.writeln(
              "    final ${param.name} = ${param.name}Str != null ? ${_getParameterConversion(param, '${param.name}Str')} : null as ${param.type};");
        }
      }
    }

    // Instantiate page
    buffer.write('    return ${config.className}(');
    for (final param in config.parameters) {
      buffer.write('${param.name}: ${param.name}, ');
    }
    buffer.writeln(');');
    buffer.writeln('  },');

    // Add bindings if any
    if (config.bindings.isNotEmpty) {
      buffer.writeln('  binding: BindingsBuilder(() {');
      for (final binding in config.bindings) {
        if (binding.lazy) {
          buffer.writeln('    Jet.lazyPut(() => ${binding.controllerType}());');
        } else {
          buffer.writeln('    Jet.put(${binding.controllerType}());');
        }
      }
      buffer.writeln('  }),');
    }

    // Add middlewares if any
    if (config.middlewares.isNotEmpty) {
      buffer.write('  middlewares: [');
      buffer.write(config.middlewares.map((m) => '$m()').join(', '));
      buffer.writeln('],');
    }

    // Add other properties
    buffer.writeln('  fullscreenDialog: ${config.fullscreenDialog},');
    buffer.writeln('  maintainState: ${config.maintainState},');
    buffer.writeln('  preventDuplicates: ${config.preventDuplicates},');

    buffer.writeln(');');

    return Code(buffer.toString());
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
}
