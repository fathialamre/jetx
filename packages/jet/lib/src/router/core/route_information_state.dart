import '../models/route_data.dart';

/// Represents the state of route information for navigation.
class RouteInformationState {
  /// The current path.
  final String path;

  /// The route data including parameters and arguments.
  final RouteData? data;

  /// Optional state object.
  final Object? state;

  const RouteInformationState({required this.path, this.data, this.state});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteInformationState &&
        other.path == path &&
        other.data == data &&
        other.state == state;
  }

  @override
  int get hashCode => path.hashCode ^ data.hashCode ^ state.hashCode;

  @override
  String toString() {
    return 'RouteInformationState(path: $path, data: $data, state: $state)';
  }
}
