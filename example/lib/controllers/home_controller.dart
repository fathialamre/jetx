import 'package:jetx/jet_rx/src/rx_types/rx_types.dart';
import 'package:jetx/jet_state_manager/src/simple/jet_controllers.dart';

class HomeController extends JetxController {
  RxInt count = 0.obs;

  void increment() {
    count.value++;
  }

  void decrement() {
    count.value--;
  }
}
