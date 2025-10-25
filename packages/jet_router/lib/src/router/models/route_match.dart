import '../config/jet_route.dart';
import 'route_data.dart';

/// Represents a matched route with its associated data.
class RouteMatch {
  /// The matched route configuration.
  final JetRoute route;

  /// The route data including path and query parameters.
  final RouteData data;

  const RouteMatch({required this.route, required this.data});

  @override
  String toString() {
    return 'RouteMatch(route: ${route.path}, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteMatch && other.route == route && other.data == data;
  }

  @override
  int get hashCode => route.hashCode ^ data.hashCode;
}
