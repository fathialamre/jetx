import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../jetx.dart';

class JetInformationParser extends RouteInformationParser<RouteDecoder> {
  factory JetInformationParser.createInformationParser(
      {String initialRoute = '/'}) {
    return JetInformationParser(initialRoute: initialRoute);
  }

  final String initialRoute;

  JetInformationParser({
    required this.initialRoute,
  }) {
    Jet.log('JetInformationParser is created !');
  }
  @override
  SynchronousFuture<RouteDecoder> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final uri = routeInformation.uri;
    var location = uri.toString();
    if (location == '/') {
      //check if there is a corresponding page
      //if not, relocate to initialRoute
      if (!(Jet.rootController.rootDelegate)
          .registeredRoutes
          .any((element) => element.name == '/')) {
        location = initialRoute;
      }
    } else if (location.isEmpty) {
      location = initialRoute;
    }

    Jet.log('JetInformationParser: route location: $location');

    return SynchronousFuture(RouteDecoder.fromRoute(location));
  }

  @override
  RouteInformation restoreRouteInformation(RouteDecoder configuration) {
    return RouteInformation(
      uri: Uri.tryParse(configuration.pageSettings?.name ?? ''),
      state: null,
    );
  }
}
