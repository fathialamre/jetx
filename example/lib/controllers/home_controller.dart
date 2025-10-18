import 'package:jetx/jetx.dart';

class HomeController extends JetxController {
  var message = ''.obs;

  void printJetX() {
    message.value = 'Jet X';
  }
}
