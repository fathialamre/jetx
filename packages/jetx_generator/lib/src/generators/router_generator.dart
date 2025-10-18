import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:analyzer/dart/element/element.dart';
import '../models/router_config.dart';
import '../models/route_config.dart';

class RouterCodeGenerator {
  static String generate(
    RouterConfig config,
    Set<LibraryElement> libraries,
  ) {
    final library = Library((b) {
      // Generate all route classes
      for (final route in config.routes) {
        b.body.add(_generateRouteClass(route, libraries));
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

  static Class _generateRouteClass(
    RouteConfig config,
    Set<LibraryElement> libraries,
  ) {
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

      // Add static binding getter (always, null if no bindings)
      b.methods.add(_generateStaticBindingGetter(config));

      // Add static page builder
      b.methods.add(_generateStaticPageBuilder(config, libraries));

      // Add static build() method
      b.methods.add(_generateStaticBuildMethod(config));

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
  static Method _generateStaticPageBuilder(
    RouteConfig config,
    Set<LibraryElement> libraries,
  ) {
    return Method((m) {
      m.name = 'page';
      m.type = MethodType.getter;
      m.static = true;
      m.returns = refer('Widget Function()');
      m.lambda = true;
      m.body = Code('() { ${_generatePageBuilderCode(config, libraries)} }');
    });
  }

  /// Generate the code for the static page builder
  static String _generatePageBuilderCode(
    RouteConfig config,
    Set<LibraryElement> libraries,
  ) {
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

  // ==================== JetPage Builder Methods ====================

  /// Generate static binding getter - returns BindingsBuilder or null
  static Method _generateStaticBindingGetter(RouteConfig config) {
    return Method((m) {
      m.name = 'binding';
      m.type = MethodType.getter;
      m.static = true;
      m.returns = refer('BindingsBuilder?');
      m.lambda = true;

      if (config.bindings.isEmpty) {
        m.body = Code('null');
      } else {
        final buffer = StringBuffer();
        buffer.write('BindingsBuilder(() {');
        for (final binding in config.bindings) {
          buffer.writeln();
          final putMethod = binding.lazy ? 'Jet.lazyPut' : 'Jet.put';
          final constructor = _buildBindingConstructor(binding);
          buffer.write('        $putMethod(() => $constructor);');
        }
        buffer.writeln();
        buffer.write('      })');
        m.body = Code(buffer.toString());
      }
    });
  }

  /// Build constructor call with dependencies using Jet.find
  static String _buildBindingConstructor(BindingConfig binding) {
    if (binding.dependencies.isEmpty) {
      return '${binding.controllerType}()';
    }

    final params = binding.dependencies.map((dep) {
      final tag = dep.tag != null ? ", tag: '${dep.tag}'" : '';
      return 'Jet.find<${dep.typeName}>($tag)';
    }).join(', ');

    return '${binding.controllerType}($params)';
  }

  /// Generates: static JetPage build({binding, transition, ...}) => JetPage(...)
  static Method _generateStaticBuildMethod(RouteConfig config) {
    return Method((m) {
      m.name = 'build';
      m.static = true;
      m.returns = refer('JetPage');

      // Add all optional parameters
      m.optionalParameters.addAll([
        Parameter((p) {
          p.name = 'binding';
          p.named = true;
          p.type = refer('BindingsInterface?');
        }),
        Parameter((p) {
          p.name = 'bindings';
          p.named = true;
          p.type = refer('List<BindingsInterface>?');
        }),
        Parameter((p) {
          p.name = 'binds';
          p.named = true;
          p.type = refer('List<Bind>?');
        }),
        Parameter((p) {
          p.name = 'transition';
          p.named = true;
          p.type = refer('Transition?');
        }),
        Parameter((p) {
          p.name = 'customTransition';
          p.named = true;
          p.type = refer('CustomTransition?');
        }),
        Parameter((p) {
          p.name = 'transitionDuration';
          p.named = true;
          p.type = refer('Duration?');
        }),
        Parameter((p) {
          p.name = 'reverseTransitionDuration';
          p.named = true;
          p.type = refer('Duration?');
        }),
        Parameter((p) {
          p.name = 'middlewares';
          p.named = true;
          p.type = refer('List<JetMiddleware>?');
        }),
        Parameter((p) {
          p.name = 'title';
          p.named = true;
          p.type = refer('String?');
        }),
        Parameter((p) {
          p.name = 'fullscreenDialog';
          p.named = true;
          p.type = refer('bool?');
        }),
        Parameter((p) {
          p.name = 'maintainState';
          p.named = true;
          p.type = refer('bool?');
        }),
        Parameter((p) {
          p.name = 'preventDuplicates';
          p.named = true;
          p.type = refer('bool?');
        }),
        Parameter((p) {
          p.name = 'popGesture';
          p.named = true;
          p.type = refer('bool?');
        }),
        Parameter((p) {
          p.name = 'opaque';
          p.named = true;
          p.type = refer('bool?');
        }),
        Parameter((p) {
          p.name = 'curve';
          p.named = true;
          p.type = refer('Curve?');
        }),
        Parameter((p) {
          p.name = 'alignment';
          p.named = true;
          p.type = refer('Alignment?');
        }),
        Parameter((p) {
          p.name = 'participatesInRootNavigator';
          p.named = true;
          p.type = refer('bool?');
        }),
        Parameter((p) {
          p.name = 'gestureWidth';
          p.named = true;
          p.type = refer('double Function(BuildContext)?');
        }),
        Parameter((p) {
          p.name = 'showCupertinoParallax';
          p.named = true;
          p.type = refer('bool?');
        }),
      ]);

      m.body = Code(_buildJetPageWithParams(config));
    });
  }

  /// Helper to generate JetPage constructor code with parameters and annotation defaults
  static String _buildJetPageWithParams(RouteConfig config) {
    final buffer = StringBuffer();
    buffer.writeln('return JetPage(');
    buffer.writeln('  name: routePath,');
    buffer.writeln('  page: page,');

    // Use passed parameter or default from annotation/binding
    if (config.bindings.isNotEmpty) {
      buffer.writeln('  binding: binding ?? binding,');
    } else {
      buffer.writeln('  binding: binding,');
    }
    buffer.writeln('  bindings: bindings ?? const [],');
    buffer.writeln('  binds: binds ?? const [],');

    // Transition - parameter overrides annotation
    if (config.transition != null) {
      buffer.writeln(
          '  transition: transition ?? Transition.${config.transition!.type},');
      if (config.transition!.durationMs != null) {
        buffer.writeln(
            '  transitionDuration: transitionDuration ?? Duration(milliseconds: ${config.transition!.durationMs}),');
      } else {
        buffer.writeln('  transitionDuration: transitionDuration,');
      }
    } else {
      buffer.writeln('  transition: transition,');
      buffer.writeln('  transitionDuration: transitionDuration,');
    }

    buffer.writeln('  customTransition: customTransition,');
    buffer.writeln('  reverseTransitionDuration: reverseTransitionDuration,');
    buffer.writeln('  middlewares: middlewares ?? const [],');
    buffer.writeln('  title: title,');

    // Bool properties - parameter overrides annotation default
    buffer.writeln(
        '  fullscreenDialog: fullscreenDialog ?? ${config.fullscreenDialog},');
    buffer
        .writeln('  maintainState: maintainState ?? ${config.maintainState},');
    buffer.writeln(
        '  preventDuplicates: preventDuplicates ?? ${config.preventDuplicates},');

    buffer.writeln('  popGesture: popGesture,');
    buffer.writeln('  opaque: opaque ?? true,');
    buffer.writeln('  curve: curve ?? Curves.linear,');
    buffer.writeln('  alignment: alignment,');
    buffer
        .writeln('  participatesInRootNavigator: participatesInRootNavigator,');
    buffer.writeln('  gestureWidth: gestureWidth,');
    buffer.writeln('  showCupertinoParallax: showCupertinoParallax ?? true,');
    buffer.writeln(');');

    return buffer.toString();
  }
}
