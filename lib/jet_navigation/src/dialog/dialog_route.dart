import 'package:flutter/widgets.dart';

import '../router_report.dart';
import '../snackbar/snackbar_controller.dart' show kDialogTransitionDuration;

class JetDialogRoute<T> extends PopupRoute<T> {
  JetDialogRoute({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = true,
    String? barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = kDialogTransitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
    super.settings,
  })  : widget = pageBuilder,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _barrierColor = barrierColor,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder {
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  final RoutePageBuilder widget;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  void dispose() {
    // Report disposal first so route-bound dependencies can run their
    // `onClose`/`Jet.markAsDirty` cleanup before the framework tears
    // the route down.
    RouterReportManager.instance.reportRouteWillDispose(this);
    RouterReportManager.instance.reportRouteDispose(this);
    super.dispose();
  }

  @override
  String? get barrierLabel => _barrierLabel;
  final String? _barrierLabel;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final RouteTransitionsBuilder? _transitionBuilder;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: widget(context, animation, secondaryAnimation),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (_transitionBuilder == null) {
      return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child);
    } // Some default transition
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}
