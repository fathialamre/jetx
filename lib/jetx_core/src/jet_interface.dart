import 'package:flutter/foundation.dart';

import 'log.dart';
import 'smart_management.dart';

/// JetInterface allows any auxiliary package to be merged into the "Get"
/// class through extensions
abstract class JetInterface {
  SmartManagement smartManagement = SmartManagement.full;
  bool isLogEnable = kDebugMode;
  LogWriterCallback log = defaultLogWriterCallback;
}
