/// Public entry point used by `build.yaml`. Wraps [JetRouteGenerator]
/// in a [SharedPartBuilder] so the emitted code lands in `*.g.dart`
/// alongside any other generators in the consuming project.
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/jet_route_generator.dart';

Builder jetxBuilder(BuilderOptions options) =>
    SharedPartBuilder([JetRouteGenerator()], 'jetx_builder');
