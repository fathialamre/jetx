import 'package:flutter/widgets.dart';
import '../config/route_config.dart';
import '../core/jet_route_information_parser.dart';
import '../core/jet_router_delegate.dart';
import '../deep_linking/url_strategy.dart';

/// A widget that configures and provides the Jet router.
class JetRouterWidget extends StatefulWidget {
  /// The route configuration.
  final RouteConfig config;

  /// The initial route path.
  final String? initialRoute;

  /// Whether to use hash-based URLs on web (default: false, uses path-based).
  final bool useHashUrl;

  /// Callback for handling deep links.
  final Future<void> Function(Uri uri)? onDeepLink;

  const JetRouterWidget({
    super.key,
    required this.config,
    this.initialRoute,
    this.useHashUrl = false,
    this.onDeepLink,
  });

  @override
  State<JetRouterWidget> createState() => _JetRouterWidgetState();
}

class _JetRouterWidgetState extends State<JetRouterWidget> {
  late final JetRouterDelegate _routerDelegate;
  late final JetRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();

    // Set URL strategy for web
    if (!widget.useHashUrl) {
      setPathUrlStrategy();
    } else {
      setHashUrlStrategy();
    }

    _routerDelegate = JetRouterDelegate(config: widget.config);
    _routeInformationParser = JetRouteInformationParser(
      initialRoute: widget.initialRoute ?? widget.config.initialRoute ?? '/',
    );
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}
