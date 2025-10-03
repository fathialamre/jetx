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
}

typedef JetPageBuilder = Widget Function();
typedef GetRouteAwarePageBuilder<T> = Widget Function([JetPageRoute<T>? route]);
