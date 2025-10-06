import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../jet_instance/src/bindings_interface.dart';
import '../../../../jet_state_manager/src/simple/jet_state.dart';
import '../../router_report.dart';
import '../transitions/default_transitions.dart';
import '../transitions/transitions_type.dart';
import '../transitions/custom_transition.dart';

@optionalTypeArgs
mixin RouteReportMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  @override
  void dispose() {
    super.dispose();
    RouterReportManager.instance.reportRouteDispose(this);
  }
}

mixin PageRouteReportMixin<T> on Route<T> {
  @override
  void install() {
    super.install();
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  @override
  void dispose() {
    super.dispose();
    RouterReportManager.instance.reportRouteDispose(this);
  }
}

class JetPageRoute<T> extends PageRoute<T> with PageRouteReportMixin {
  /// Creates a page route for use in an iOS designed app.
  ///
  /// The [builder], [maintainState], and [fullscreenDialog] arguments must not
  /// be null.
  JetPageRoute({
    super.settings,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.parameter,
    this.gestureWidth,
    this.curve,
    this.alignment,
    this.transition,
    this.popGesture,
    this.customTransition,
    this.barrierDismissible = false,
    this.barrierColor,
    BindingsInterface? binding,
    List<BindingsInterface> bindings = const [],
    this.binds,
    this.routeName,
    this.page,
    this.title,
    this.showCupertinoParallax = true,
    this.barrierLabel,
    this.maintainState = true,
    super.fullscreenDialog,
  }) : bindings = (binding == null) ? bindings : [...bindings, binding];

  @override
  final Duration transitionDuration;
  @override
  final Duration reverseTransitionDuration;

  final JetPageBuilder? page;
  final String? routeName;
  //final String reference;
  final CustomTransition? customTransition;
  final List<BindingsInterface> bindings;
  final Map<String, String>? parameter;
  final List<Bind>? binds;

  final bool showCupertinoParallax;

  @override
  final bool opaque;
  final bool? popGesture;

  @override
  final bool barrierDismissible;
  final Transition? transition;
  final Curve? curve;
  final Alignment? alignment;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  @override
  void dispose() {
    super.dispose();
    // No middleware in Navigator 2.0
    _child = null;
  }

  Widget? _child;

  Widget _getChild() {
    if (_child != null) return _child!;

    final localBinds = [if (binds != null) ...binds!];
    final bindingsToBind = bindings.isNotEmpty ? bindings : localBinds;
    final pageToBuild = page!;

    if (bindingsToBind.isNotEmpty) {
      if (bindingsToBind is List<BindingsInterface>) {
        for (final item in bindingsToBind) {
          final dep = item.dependencies();
          if (dep is List<Bind>) {
            _child = Binds(
              binds: dep,
              child: pageToBuild(),
            );
          }
        }
      } else if (bindingsToBind is List<Bind>) {
        _child = Binds(
          binds: bindingsToBind,
          child: pageToBuild(),
        );
      }
    }

    return _child ??= pageToBuild();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    return _getChild();
  }

  final String? title;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  final double Function(BuildContext context)? gestureWidth;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // If custom transition is provided, use it
    if (customTransition != null) {
      return customTransition!.buildTransition(
        context,
        curve,
        alignment,
        animation,
        secondaryAnimation,
        child,
      );
    }

    // Apply curve to animation if provided
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve!)
        : animation;

    // Build transition based on the transition type
    switch (transition) {
      case Transition.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case Transition.fadeIn:
        return FadeInTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.rightToLeft:
        return SlideRightTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.leftToRight:
        return SlideLeftTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.upToDown:
        return SlideTopTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.downToUp:
        return SlideDownTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.rightToLeftWithFade:
        return RightToLeftFadeTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.leftToRightWithFade:
        return LeftToRightFadeTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.zoom:
        return ZoomInTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.size:
        return SizeTransitions().buildTransitions(
          context,
          curve ?? Curves.linear,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.circularReveal:
        return CircularRevealTransition().buildTransitions(
          context,
          curve,
          alignment,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      case Transition.noTransition:
        return child;

      case Transition.cupertino:
        return CupertinoPageTransition(
          primaryRouteAnimation: curvedAnimation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: false,
          child: child,
        );

      case Transition.cupertinoDialog:
        return CupertinoPageTransition(
          primaryRouteAnimation: curvedAnimation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: true,
          child: child,
        );

      case Transition.native:
        return _buildNativeTransition(
          context,
          curvedAnimation,
          secondaryAnimation,
          child,
        );

      default:
        // Default to fade transition
        return FadeTransition(opacity: curvedAnimation, child: child);
    }
  }

  Widget _buildNativeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Use platform-specific transition
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: false,
        child: child,
      );
    } else {
      // Material transition for Android and others
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    }
  }
}
