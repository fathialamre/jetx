import 'package:example/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

void main() {
  group('JetPage Builder API', () {
    test('build() returns JetPage with default properties', () {
      final page = HomePageRoute.build();

      expect(page.name, equals(HomePageRoute.routePath));
      expect(page.page, isNotNull);
      expect(page.fullscreenDialog, equals(false));
      expect(page.maintainState, equals(true));
      expect(page.preventDuplicates, equals(true));
    });

    test('build() allows customization with named parameters', () {
      final page = HomePageRoute.build(
        fullscreenDialog: true,
        maintainState: false,
        title: 'Custom Title',
      );

      expect(page.fullscreenDialog, equals(true));
      expect(page.maintainState, equals(false));
      expect(page.title, equals('Custom Title'));
      expect(page.name, equals(HomePageRoute.routePath));
    });

    test('build() can set multiple properties at once', () {
      final page = ProfilePageRoute.build(
        transition: Transition.fadeIn,
        opaque: false,
        popGesture: true,
        curve: Curves.easeInOut,
      );

      expect(page.transition, equals(Transition.fadeIn));
      expect(page.opaque, equals(false));
      expect(page.popGesture, equals(true));
      expect(page.curve, equals(Curves.easeInOut));
    });

    test('build() can set custom binding', () {
      final customBinding = BindingsBuilder(() {
        // Custom bindings
      });

      final page = SettingsPageRoute.build(binding: customBinding);

      expect(page.binding, equals(customBinding));
    });

    test('build() works without customization', () {
      final page1 = HomePageRoute.build();
      final page2 = ProfilePageRoute.build();

      expect(page1.name, equals('/home'));
      expect(page2.name, equals('/profile'));
    });
  });
}
