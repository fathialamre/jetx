import 'dart:async';

import 'package:flutter/widgets.dart';
import '../config/jet_route.dart';
import '../models/route_data.dart';
import 'jet_page_route.dart';

/// A page that uses the Jet router for navigation.
class JetPage<T> extends Page<T> {
  /// The route configuration for this page.
  final JetRoute route;

  /// The route data including path and query parameters.
  final RouteData data;

  /// Completer for returning results when this page is popped.
  final Completer<T?>? completer;

  /// Creates a JetPage.
  const JetPage({
    required this.route,
    required this.data,
    this.completer,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return JetPageRoute<T>(page: this, settings: this);
  }

  /// Builds the widget for this page.
  Widget buildPage(BuildContext context) {
    return route.builder(context, data);
  }

  @override
  String toString() {
    return 'JetPage(route: ${route.path}, data: $data)';
  }
}
