import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'jet_route.dart';
import 'new_path_route.dart';

/// Parse Route Tree for matching routes in Navigator 2.0
///
/// This class provides efficient route matching using a tree structure.
class ParseRouteTree {
  final List<JetPage> routes;
  final RouteTree _routeTree = RouteTree.instance;

  ParseRouteTree({required this.routes}) {
    _routeTree.addRoutes(routes);
  }

  /// Match a route path and return the matched route
  RouteTreeResult? matchRoute(String path) {
    return _routeTree.matchRoute(path);
  }

  /// Add a route dynamically
  void addRoute(JetPage route) {
    _routeTree.addRoute(route);
  }

  /// Remove a route dynamically
  void removeRoute(JetPage route) {
    _routeTree.removeRoute(route);
  }

  /// Get all registered routes
  List<JetPage> get registeredRoutes {
    return routes;
  }
}

/// Route Decoder for Navigator 2.0
///
/// Wraps the result of route matching with additional metadata
@immutable
class RouteDecoder {
  final List<JetPage> currentTreeBranch;
  final Map<String, String> parameters;

  const RouteDecoder(
    this.currentTreeBranch,
    this.parameters,
  );

  JetPage? get route =>
      currentTreeBranch.isEmpty ? null : currentTreeBranch.last;

  RouteDecoder copyWith({
    List<JetPage>? currentTreeBranch,
    Map<String, String>? parameters,
  }) {
    return RouteDecoder(
      currentTreeBranch ?? this.currentTreeBranch,
      parameters ?? this.parameters,
    );
  }
}

/// Page Settings for Navigator 2.0
///
/// Enhanced route settings with URI parsing support
class PageSettings extends RouteSettings {
  PageSettings(
    this.uri, [
    Object? arguments,
  ]) : super(arguments: arguments, name: uri.toString());

  final Uri uri;
  final params = <String, String>{};

  String get path => uri.path;
  List<String> get paths => uri.pathSegments;
  Map<String, String> get query => uri.queryParameters;
  Map<String, List<String>> get queries => uri.queryParametersAll;

  @override
  String toString() => name ?? '';

  PageSettings copy({
    Uri? uri,
    Object? arguments,
  }) {
    return PageSettings(
      uri ?? this.uri,
      arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageSettings &&
        other.uri == uri &&
        other.arguments == arguments;
  }

  @override
  int get hashCode => uri.hashCode ^ arguments.hashCode;
}
