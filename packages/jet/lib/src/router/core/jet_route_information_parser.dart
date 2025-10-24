import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'route_information_state.dart';

/// Parses route information from the operating system.
class JetRouteInformationParser
    extends RouteInformationParser<RouteInformationState> {
  final String initialRoute;

  JetRouteInformationParser({this.initialRoute = '/'});

  @override
  Future<RouteInformationState> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final uri = routeInformation.uri;
    var path = uri.path;

    // Handle empty path
    if (path.isEmpty) {
      path = initialRoute;
    }

    // Ensure path starts with '/'
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    return SynchronousFuture(
      RouteInformationState(path: path, state: routeInformation.state),
    );
  }

  @override
  RouteInformation? restoreRouteInformation(
    RouteInformationState configuration,
  ) {
    return RouteInformation(
      uri: Uri.parse(configuration.path),
      state: configuration.state,
    );
  }
}
