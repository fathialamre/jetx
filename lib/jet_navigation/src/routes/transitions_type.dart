import 'package:flutter/widgets.dart';

import 'default_route.dart';

enum Transition {
  fade,
  fadeIn,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  rightToLeftWithFade,
  leftToRightWithFade,
  zoom,
  topLevel,
  noTransition,
  cupertino,
  cupertinoDialog,
  size,
  circularReveal,
  native,

  /// Android 14+ predictive back gesture transition. On other platforms
  /// (or older Android) Flutter's [PredictiveBackPageTransitionsBuilder]
  /// degrades gracefully to the platform default, so it is safe to set
  /// app-wide.
  predictiveBack,
}

typedef JetPageBuilder = Widget Function();
typedef JetRouteAwarePageBuilder<T> = Widget Function([JetPageRoute<T>? route]);
