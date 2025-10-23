import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import '../models/router_config.dart';

/// Resolves router configuration from annotated classes.
class RouterConfigResolver {
  /// Resolves a router class into configuration.
  RouterConfig resolve(
    ClassElement classElement,
    ConstantReader annotation,
    String filePath,
    bool usesPartBuilder,
  ) {
    final routerClassName = classElement.name;

    // Get generateForDir from annotation
    final generateForDirReader = annotation.peek('generateForDir');
    final generateForDir = generateForDirReader != null
        ? generateForDirReader.listValue.map((e) => e.toStringValue()!).toList()
        : <String>['lib'];

    return RouterConfig(
      routerClassName: routerClassName,
      generateForDir: generateForDir,
      filePath: filePath,
      usesPartBuilder: usesPartBuilder,
    );
  }
}
