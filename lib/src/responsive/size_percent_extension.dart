
//Converts a double value to a percentage
import 'package:jet/jet.dart';

extension PercentSized on double {
  // height: 50.0.hp = 50%
  double get hp => (Jet.height * (this / 100));
  // width: 30.0.hp = 30%
  double get wp => (Jet.width * (this / 100));
}
