import 'package:jetx/jetx.dart';

class SettingsController extends JetxController {
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {}
  void increment() => count.value++;
}
