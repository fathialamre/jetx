@TestOn('browser')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

void main() {
  test('Platform test', () {
    expect(JetPlatform.isAndroid, Platform.isAndroid);
    expect(JetPlatform.isIOS, Platform.isIOS);
    expect(JetPlatform.isFuchsia, Platform.isFuchsia);
    expect(JetPlatform.isLinux, Platform.isLinux);
    expect(JetPlatform.isMacOS, Platform.isMacOS);
    expect(JetPlatform.isWindows, Platform.isWindows);
    expect(JetPlatform.isWeb, true);
  });
}
