import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends JetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'SettingsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
