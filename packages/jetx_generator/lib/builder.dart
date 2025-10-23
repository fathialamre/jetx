import 'package:build/build.dart';

import 'src/builders/jet_page_route_builder.dart';
import 'src/builders/jet_router_builder.dart';

/// Builder that scans for @JetPageRoute annotations and generates cache files.
Builder jetPageRouteBuilder(BuilderOptions options) => JetPageRouteBuilder();

/// Builder that generates the final .g.dart file with all routes.
Builder jetRouterBuilder(BuilderOptions options) => JetRouterBuilder();
