import 'package:flutter/widgets.dart';
import '../core/jet_router_delegate.dart';
import 'jet_router_extension.dart';

/// Extension on BuildContext for type-safe navigation using Jet router.
extension JetNavigation on BuildContext {
  /// Gets the router delegate from the current context.
  JetRouterDelegate get _delegate {
    return Router.of(this).routerDelegate as JetRouterDelegate;
  }

  /// Gets the router extension that provides navigation methods and state access.
  ///
  /// This provides a clean API for all router functionality:
  /// ```dart
  /// // Navigation
  /// context.router.push('/profile/123');
  /// context.router.replace('/login');
  /// context.router.pop();
  ///
  /// // Navigation with results (like go_router and auto_route)
  /// final result = await context.router.push<String>('/edit-profile');
  /// if (result != null) {
  ///   print('Received: $result');
  /// }
  ///
  /// // Return a result when popping
  /// context.router.pop('user_updated');
  ///
  /// // State access
  /// final userId = context.router.pathParam('userId');
  /// final query = context.router.queryParam('search');
  /// final args = context.router.routeArguments<MyArguments>();
  ///
  /// // Advanced access
  /// final delegate = context.router.delegate;
  /// ```
  JetRouterExtension get router => JetRouterExtension(_delegate);
}
