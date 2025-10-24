import 'package:flutter/widgets.dart';
import '../guards/route_guard.dart';
import '../models/route_data.dart';
import '../transitions/transition_type.dart';

/// Represents a route configuration in the Jet router.
class JetRoute {
  /// The path pattern for this route.
  /// Can include path parameters using ':' notation (e.g., '/user/:id').
  final String path;

  /// Builder function that creates the widget for this route.
  final Widget Function(BuildContext context, RouteData data) builder;

  /// List of guards that must pass before this route can be activated.
  final List<RouteGuard> guards;

  /// The transition animation to use when navigating to this route.
  final TransitionType? transition;

  /// Duration of the transition animation.
  final Duration? transitionDuration;

  /// Duration of the reverse transition animation.
  final Duration? reverseTransitionDuration;

  /// The curve to use for the transition animation.
  final Curve curve;

  /// Whether this is the initial route of the application.
  final bool initialRoute;

  /// Whether this route should be presented as a fullscreen dialog.
  final bool fullscreenDialog;

  /// Whether the route should maintain its state when inactive.
  final bool maintainState;

  /// Additional metadata associated with this route.
  final Map<String, dynamic>? meta;

  /// Optional name for this route (used for named navigation).
  final String? name;

  /// Whether to allow gesture-based pop on iOS.
  final bool? popGesture;

  const JetRoute({
    required this.path,
    required this.builder,
    this.guards = const [],
    this.transition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.curve = Curves.linear,
    this.initialRoute = false,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.meta,
    this.name,
    this.popGesture,
  });

  /// Returns the route name (uses [name] if provided, otherwise uses [path]).
  String get routeName => name ?? path;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JetRoute && other.path == path && other.name == name;
  }

  @override
  int get hashCode => path.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'JetRoute(path: $path, name: $name, initialRoute: $initialRoute)';
  }
}
