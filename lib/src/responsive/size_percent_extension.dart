import '../../jetx.dart';

//Converts a double value to a percentage
extension PercentSized on double {
  // height: 50.0.hp = 50%
  @Deprecated(
      'Use context-aware sizes (e.g. `MediaQuery.sizeOf(context).height * (this / 100)` '
      'or `context.heightTransformer(reducedBy: ...)`). `Jet.height` reads the root window '
      'and breaks inside split panes, side sheets, dialogs, embedded views and multi-window '
      'desktop/tablet layouts.')
  double get hp => (Jet.height * (this / 100));

  // width: 30.0.wp = 30%
  @Deprecated(
      'Use context-aware sizes (e.g. `MediaQuery.sizeOf(context).width * (this / 100)` '
      'or `context.widthTransformer(reducedBy: ...)`). `Jet.width` reads the root window '
      'and breaks inside split panes, side sheets, dialogs, embedded views and multi-window '
      'desktop/tablet layouts.')
  double get wp => (Jet.width * (this / 100));
}
