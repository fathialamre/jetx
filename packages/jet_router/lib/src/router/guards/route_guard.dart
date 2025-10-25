import 'package:flutter/widgets.dart';
import '../config/jet_route.dart';

/// Abstract base class for route guards.
///
/// Route guards are used to protect routes from unauthorized access.
/// They can either allow navigation, prevent it, or redirect to another route.
abstract class RouteGuard {
  const RouteGuard();

  /// Determines if the route can be activated.
  ///
  /// Returns `true` to allow navigation, `false` to prevent it.
  /// If this returns `false`, [redirect] will be called to determine
  /// where to navigate instead.
  Future<bool> canActivate(BuildContext context, JetRoute route);

  /// Returns a route to redirect to if [canActivate] returns `false`.
  ///
  /// Return `null` to stay on the current route (no navigation occurs).
  String? redirect(BuildContext context, JetRoute route) => null;
}
