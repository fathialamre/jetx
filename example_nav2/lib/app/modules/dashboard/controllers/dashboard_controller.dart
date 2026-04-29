import 'dart:async';

import 'package:jetx/jetx.dart';

class DashboardController extends JetxController {
  final now = DateTime.now().obs;
  @override
  void onReady() {
    super.onReady();
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        now.value = DateTime.now();
      },
    );
  }
}
