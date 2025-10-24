import 'package:flutter/widgets.dart';
import '../transitions/transition_builder.dart';
import 'jet_page.dart';

/// A page route that uses Jet's transition system.
class JetPageRoute<T> extends PageRoute<T> {
  final JetPage<T> page;
  final JetTransitionBuilder _transitionBuilder = const JetTransitionBuilder();

  JetPageRoute({required this.page, super.settings});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => page.route.maintainState;

  @override
  Duration get transitionDuration =>
      page.route.transitionDuration ?? const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration =>
      page.route.reverseTransitionDuration ?? transitionDuration;

  @override
  bool get fullscreenDialog => page.route.fullscreenDialog;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page.buildPage(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _transitionBuilder.buildTransition(
      context,
      animation,
      secondaryAnimation,
      child,
      page.route.transition,
    );
  }
}
