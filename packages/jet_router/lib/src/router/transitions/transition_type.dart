import 'package:flutter/widgets.dart';

/// Enum representing different page transition types.
enum TransitionStyle {
  fade,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  rotation,
  custom,
  none,
}

/// Configuration for page transitions.
class TransitionType {
  final TransitionStyle style;
  final Duration? duration;
  final Curve? curve;
  final CustomTransitionBuilder? customBuilder;

  const TransitionType({
    required this.style,
    this.duration,
    this.curve,
    this.customBuilder,
  });

  /// Fade transition.
  const TransitionType.fade({Duration? duration, Curve? curve})
    : style = TransitionStyle.fade,
      duration = duration,
      curve = curve,
      customBuilder = null;

  /// Slide up transition.
  const TransitionType.slideUp({Duration? duration, Curve? curve})
    : style = TransitionStyle.slideUp,
      duration = duration,
      curve = curve,
      customBuilder = null;

  /// Slide down transition.
  const TransitionType.slideDown({Duration? duration, Curve? curve})
    : style = TransitionStyle.slideDown,
      duration = duration,
      curve = curve,
      customBuilder = null;

  /// Slide left transition.
  const TransitionType.slideLeft({Duration? duration, Curve? curve})
    : style = TransitionStyle.slideLeft,
      duration = duration,
      curve = curve,
      customBuilder = null;

  /// Slide right transition.
  const TransitionType.slideRight({Duration? duration, Curve? curve})
    : style = TransitionStyle.slideRight,
      duration = duration,
      curve = curve,
      customBuilder = null;

  /// Scale transition.
  const TransitionType.scale({Duration? duration, Curve? curve})
    : style = TransitionStyle.scale,
      duration = duration,
      curve = curve,
      customBuilder = null;

  /// Rotation transition.
  const TransitionType.rotation({Duration? duration, Curve? curve})
    : style = TransitionStyle.rotation,
      duration = duration,
      curve = curve,
      customBuilder = null;

  /// Custom transition with a builder function.
  const TransitionType.custom({
    required CustomTransitionBuilder builder,
    Duration? duration,
    Curve? curve,
  }) : style = TransitionStyle.custom,
       customBuilder = builder,
       duration = duration,
       curve = curve;

  /// No transition.
  const TransitionType.none()
    : style = TransitionStyle.none,
      duration = null,
      curve = null,
      customBuilder = null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransitionType &&
        other.style == style &&
        other.duration == duration &&
        other.curve == curve;
  }

  @override
  int get hashCode => style.hashCode ^ duration.hashCode ^ curve.hashCode;
}

/// Builder function for custom page transitions.
typedef CustomTransitionBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    );
