import 'package:jetx/jetx.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut(() => LoginController()),
    ];
  }
}
