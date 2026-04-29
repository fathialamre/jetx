import 'package:jetx/jetx.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.lazyPut<DashboardController>(
        () => DashboardController(),
      )
    ];
  }
}
