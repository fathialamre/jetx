import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

const _routeAnnotationChecker = TypeChecker.fromUrl(
  'package:jetx/jet_navigation/src/routes/jet_route_annotation.dart#JetRoute',
);

const _routerAnnotationChecker = TypeChecker.fromUrl(
  'package:jetx/jet_navigation/src/routes/jet_route_annotation.dart#JetXRouter',
);

const _widgetChecker = TypeChecker.fromUrl(
  'package:flutter/src/widgets/framework.dart#Widget',
);

/// Aggregator generator triggered by `@JetXRouter()` on a host class.
/// Walks every `.dart` file in the consuming package's `lib/`,
/// collects `@JetRoute(...)` annotated widget classes, and emits a
/// single `<host>.g.dart` with:
///
/// 1. One `<ClassName>Route` typed [JetRouteData] subclass per page,
///    derived from its constructor params, for compile-time-safe
///    navigation: `Jet.go(ProductDetailPageRoute(id: '42'))`.
///
/// 2. A `_$<HostClassName>Pages` final `List<JetPage>` constant
///    aggregating every page's registration. Bindings, middlewares,
///    transition, and fullscreenDialog declared on the page's
///    annotation flow through to the corresponding `JetPage` field.
///
/// Inspired by `auto_route`'s `@AutoRouterConfig` host pattern. One
/// generated file, one app-wide table — pages stay annotation-only,
/// no `part` directive on the page side.
class JetXRouterGenerator extends GeneratorForAnnotation<Object> {
  @override
  TypeChecker get typeChecker => _routerAnnotationChecker;

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@JetXRouter must be applied to a class, not ${element.runtimeType}.',
        element: element,
      );
    }

    final hostName = element.name;
    final hostInputId = buildStep.inputId;

    // Walk every .dart in the host package's lib/, resolve, collect
    // every @JetRoute-annotated widget class.
    final pages = <_PageInfo>[];
    await for (final asset in buildStep.findAssets(Glob('lib/**.dart'))) {
      // Skip generated parts and the host file itself.
      if (asset.path.endsWith('.g.dart')) continue;
      if (!await buildStep.resolver.isLibrary(asset)) continue;
      final lib = await buildStep.resolver.libraryFor(asset);
      final reader = LibraryReader(lib);
      for (final cls in reader.classes) {
        final ann = _routeAnnotationChecker.firstAnnotationOf(cls);
        if (ann == null) continue;
        if (!_widgetChecker.isAssignableFrom(cls)) {
          throw InvalidGenerationSourceError(
            '${cls.name}: @JetXRouter aggregator only supports widget '
            'pages. For standalone JetRouteData specs, use the legacy '
            'per-file pattern.',
            element: cls,
          );
        }
        pages.add(_PageInfo.from(cls, ConstantReader(ann)));
      }
    }
    // Stable order so re-runs don't churn the diff.
    pages.sort((a, b) => a.className.compareTo(b.className));

    return _emit(hostName, pages, hostInputId);
  }

  String _emit(
      String hostName, List<_PageInfo> pages, AssetId hostInputId) {
    final buf = StringBuffer();
    buf.writeln('// ignore_for_file: type=lint');
    buf.writeln();

    // Typed route classes.
    for (final p in pages) {
      buf.writeln(p.emitTypedRoute());
      buf.writeln();
    }

    // Aggregated pages list.
    buf.writeln(
        '/// Auto-aggregated route table for [$hostName]. Wire into ');
    buf.writeln(
        '/// `JetMaterialApp(getPages: $hostName.pages)`.');
    buf.writeln('final List<JetPage> _\$${hostName}Pages = <JetPage>[');
    for (final p in pages) {
      buf.writeln(p.emitPageRegistration());
    }
    buf.writeln('];');

    return buf.toString();
  }
}

// --------------------------------------------------------------------
// Per-page metadata extracted once during scan, used twice during emit.
// --------------------------------------------------------------------

class _PageInfo {
  _PageInfo({
    required this.className,
    required this.path,
    required this.params,
    required this.bindingTypes,
    required this.middlewareTypes,
    required this.transitionLiteral,
    required this.fullscreenDialog,
  });

  final String className;
  final String path;
  final List<ParameterElement> params;
  final List<String> bindingTypes;
  final List<String> middlewareTypes;
  final String? transitionLiteral;
  final bool fullscreenDialog;

  static _PageInfo from(ClassElement cls, ConstantReader ann) {
    final path = ann.read('path').stringValue;
    final ctor = cls.unnamedConstructor;
    if (ctor == null) {
      throw InvalidGenerationSourceError(
        '${cls.name} must declare an unnamed constructor for @JetRoute.',
        element: cls,
      );
    }
    final params =
        ctor.parameters.where((p) => p.name != 'key').toList(growable: false);
    // Validate path params have matching ctor params.
    final pathParams = _extractPathParams(path);
    final paramNames = params.map((p) => p.name).toSet();
    for (final pp in pathParams) {
      if (!paramNames.contains(pp)) {
        throw InvalidGenerationSourceError(
          'Path param ":$pp" in "$path" has no matching constructor '
          'param on ${cls.name}',
          element: cls,
        );
      }
    }
    return _PageInfo(
      className: cls.name,
      path: path,
      params: params,
      bindingTypes: ann
          .read('bindings')
          .listValue
          .map((dv) => dv.toTypeValue()!.element!.name!)
          .toList(),
      middlewareTypes: ann
          .read('middlewares')
          .listValue
          .map((dv) => dv.toTypeValue()!.element!.name!)
          .toList(),
      transitionLiteral: _transitionLiteral(ann.read('transition')),
      fullscreenDialog: ann.read('fullscreenDialog').boolValue,
    );
  }

  String emitTypedRoute() {
    final routeClassName = '${className}Route';
    final pathParams = _extractPathParams(path);
    final pathFields =
        params.where((p) => pathParams.contains(p.name)).toList();
    final queryFields =
        params.where((p) => !pathParams.contains(p.name)).toList();

    final ctorParamsBody = params.map((p) {
      final isRequired = !_isNullable(p.type);
      return '${isRequired ? 'required ' : ''}this.${p.name}';
    }).join(', ');
    final ctorParams =
        ctorParamsBody.isEmpty ? '' : '{$ctorParamsBody}';

    final fieldDecls = params.map((p) {
      final type = p.type.getDisplayString(withNullability: true);
      return '  final $type ${p.name};';
    }).join('\n');

    final pathParamMap = pathFields.isEmpty
        ? 'const <String, Object?>{}'
        : '<String, Object?>{${pathFields.map((f) => "'${f.name}': ${f.name}").join(', ')}}';
    final queryParamMap = queryFields.isEmpty
        ? 'const <String, Object?>{}'
        : '<String, Object?>{${queryFields.map((f) => "'${f.name}': ${f.name}").join(', ')}}';

    return '''
/// Generated by jetx_builder for [$className].
class $routeClassName extends JetRouteData {
  const $routeClassName($ctorParams);

$fieldDecls

  @override
  String get location => Jet.buildUrl(
        '$path',
        pathParams: $pathParamMap,
        queryParams: $queryParamMap,
      );
}''';
  }

  String emitPageRegistration() {
    final widgetCtorBody = params.isEmpty
        ? 'const $className()'
        : '$className(\n      ${params.map((p) => '${p.name}: ${_paramExtractor(p)}').join(',\n      ')},\n    )';
    final extras = <String>[];
    if (bindingTypes.isNotEmpty) {
      extras.add('    bindings: [${bindingTypes.map((t) => '$t()').join(', ')}],');
    }
    if (middlewareTypes.isNotEmpty) {
      extras.add(
          '    middlewares: [${middlewareTypes.map((t) => '$t()').join(', ')}],');
    }
    if (transitionLiteral != null) {
      extras.add('    transition: $transitionLiteral,');
    }
    if (fullscreenDialog) {
      extras.add('    fullscreenDialog: true,');
    }
    final extrasBlock = extras.isEmpty ? '' : '\n${extras.join('\n')}';
    return '''  JetPage(
    name: '$path',
    page: () => $widgetCtorBody,$extrasBlock
  ),''';
  }
}

// --------------------------------------------------------------------
// shared helpers
// --------------------------------------------------------------------

List<String> _extractPathParams(String path) =>
    RegExp(r':(\w+)').allMatches(path).map((m) => m.group(1)!).toList();

bool _isNullable(DartType type) =>
    type.nullabilitySuffix.toString().contains('question');

String _paramExtractor(ParameterElement p) {
  final type = p.type.getDisplayString(withNullability: true);
  final lit = "'${p.name}'";
  switch (type) {
    case 'String':
      return 'Jet.parameters[$lit] ?? \'\'';
    case 'String?':
      return 'Jet.parameters[$lit]';
    case 'int':
      return 'int.parse(Jet.parameters[$lit] ?? \'0\')';
    case 'int?':
      return '(Jet.parameters[$lit] == null ? null : int.tryParse(Jet.parameters[$lit]!))';
    case 'double':
      return 'double.parse(Jet.parameters[$lit] ?? \'0\')';
    case 'double?':
      return '(Jet.parameters[$lit] == null ? null : double.tryParse(Jet.parameters[$lit]!))';
    case 'bool':
      return "Jet.parameters[$lit] == 'true'";
    case 'bool?':
      return "(Jet.parameters[$lit] == null ? null : Jet.parameters[$lit] == 'true')";
    default:
      throw InvalidGenerationSourceError(
        'Unsupported @JetRoute constructor param type "$type" on '
        '${p.enclosingElement!.name}.${p.name}. v1 supports '
        'String, int, double, bool (+ nullable variants).',
        element: p,
      );
  }
}

String? _transitionLiteral(ConstantReader reader) {
  if (reader.isNull) return null;
  final name = reader.objectValue.getField('_name')?.toStringValue();
  if (name == null) return null;
  return 'Transition.$name';
}
