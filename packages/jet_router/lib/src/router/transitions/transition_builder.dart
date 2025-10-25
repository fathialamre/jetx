import 'package:flutter/widgets.dart';
import 'transition_type.dart';

/// Builds page transitions based on the transition type.
class JetTransitionBuilder {
  const JetTransitionBuilder();

  /// Builds a transition widget based on the [transitionType].
  Widget buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType? transitionType,
  ) {
    if (transitionType == null ||
        transitionType.style == TransitionStyle.none) {
      return child;
    }

    final curve = transitionType.curve ?? Curves.easeInOut;
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (transitionType.style) {
      case TransitionStyle.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case TransitionStyle.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionStyle.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionStyle.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionStyle.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionStyle.scale:
        return ScaleTransition(scale: curvedAnimation, child: child);

      case TransitionStyle.rotation:
        return RotationTransition(turns: curvedAnimation, child: child);

      case TransitionStyle.custom:
        if (transitionType.customBuilder != null) {
          return transitionType.customBuilder!(
            context,
            animation,
            secondaryAnimation,
            child,
          );
        }
        return child;

      case TransitionStyle.none:
        return child;
    }
  }
}
