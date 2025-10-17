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

    final config = await RouterParser.parseRouter(element, buildStep.resolver);
    if (config == null) {
      throw InvalidGenerationSourceError(
        'Failed to parse router configuration',
        element: element,
      );
    }

    return RouterCodeGenerator.generate(config);
  }
}
