import 'dart:developer' as developer;
import 'jet_main.dart';

///VoidCallback from logs
typedef LogWriterCallback = void Function(String text, {bool isError});

/// default logger from JetX
void defaultLogWriterCallback(String value, {bool isError = false}) {
  if (isError || Jet.isLogEnable) developer.log(value, name: 'JETX');
}
