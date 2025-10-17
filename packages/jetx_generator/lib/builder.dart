import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'jetx_generator.dart';

Builder jetxRouteBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [JetXRouterGenerator()],
    'jetx_route',
  );
}
