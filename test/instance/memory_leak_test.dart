import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

/// Tests to verify proper memory management and prevent leaks
/// These tests ensure controllers, dependencies, and resources are properly disposed

class TestController extends JetxController {
  int disposalCount = 0;

  @override
  void onClose() {
    disposalCount++;
    super.onClose();
  }
}

class TestControllerWithCustomCallbacks extends JetxController {
  int disposalCount = 0;
  VoidCallback? customOnClose;

  @override
  void onClose() {
    disposalCount++;
    customOnClose?.call();
    super.onClose();
  }
}

class TestControllerWithInitCallbacks extends JetxController {
  bool initCalled = false;
  bool readyCalled = false;
  VoidCallback? customOnInit;
  VoidCallback? customOnReady;

  @override
  void onInit() {
    initCalled = true;
    customOnInit?.call();
    super.onInit();
  }

  @override
  void onReady() {
    readyCalled = true;
    customOnReady?.call();
    super.onReady();
  }
}

class TestScrollController extends JetxController with ScrollMixin {
  @override
  Future<void> onEndScroll() async {
    // Simulate loading more data
  }

  @override
  Future<void> onTopScroll() async {
    // Simulate refreshing data
  }
}

class TestService extends JetxService {
  int initCount = 0;

  @override
  void onInit() {
    super.onInit();
    initCount++;
  }
}

void main() {
  setUp(() {
    // Reset all instances before each test
    Jet.resetInstance();
  });

  tearDown(() {
    // Clean up after each test
    Jet.resetInstance();
  });

  group('Controller Lifecycle Memory Leaks', () {
    test('Controller should be disposed when deleted', () {
      final controller = TestController();
      Jet.put(controller);

      expect(Jet.isRegistered<TestController>(), true);
      expect(controller.disposalCount, 0);

      Jet.delete<TestController>();

      expect(controller.disposalCount, 1);
      expect(Jet.isRegistered<TestController>(), false);
    });

    test('Should prevent double disposal', () {
      final controller = TestController();
      Jet.put(controller);

      Jet.delete<TestController>();
      expect(controller.disposalCount, 1);

      // Try to delete again - should not double-dispose
      Jet.delete<TestController>();
      expect(controller.disposalCount, 1);
    });

    test('LazyPut controller should dispose properly', () {
      var customDisposalCount = 0;

      Jet.lazyPut<TestControllerWithCustomCallbacks>(() {
        final controller = TestControllerWithCustomCallbacks();
        controller.customOnClose = () {
          customDisposalCount++;
        };
        return controller;
      });

      expect(Jet.isRegistered<TestControllerWithCustomCallbacks>(), true);
      expect(Jet.isPrepared<TestControllerWithCustomCallbacks>(), true);

      // Access the controller to initialize it
      final controller = Jet.find<TestControllerWithCustomCallbacks>();

      Jet.delete<TestControllerWithCustomCallbacks>();

      expect(Jet.isRegistered<TestControllerWithCustomCallbacks>(), false);
      expect(controller.disposalCount, 1);
      expect(customDisposalCount, 1);
    });

    test('Fenix mode should clear but not remove builder', () {
      final controller = TestController();
      Jet.lazyPut<TestController>(() => controller, fenix: true);

      final instance1 = Jet.find<TestController>();
      expect(instance1, isNotNull);

      Jet.delete<TestController>();
      expect(controller.disposalCount, 1);

      // Should still be registered due to fenix mode
      expect(Jet.isRegistered<TestController>(), true);
    });
  });

  group('ScrollMixin Disposal', () {
    testWidgets('ScrollMixin should dispose scroll controller', (tester) async {
      final controller = TestScrollController();
      Jet.put(controller);

      expect(controller.isClosed, false);
      expect(() => controller.scroll.hasClients, returnsNormally);

      Jet.delete<TestScrollController>();

      expect(controller.isClosed, true);

      // Verify scroll controller is disposed - hasClients returns false for disposed controllers
      expect(controller.scroll.hasClients, false);
    });

    testWidgets('ScrollMixin should handle multiple disposal attempts',
        (tester) async {
      final controller = TestScrollController();
      Jet.put(controller);

      // First disposal
      Jet.delete<TestScrollController>();
      expect(controller.isClosed, true);

      // Second disposal attempt should not throw
      expect(() => controller.onClose(), returnsNormally);
    });
  });

  group('Service Memory Management', () {
    test('Services should not be deleted without force', () {
      final service = TestService();
      Jet.put<TestService>(service, permanent: true);

      expect(Jet.isRegistered<TestService>(), true);

      // Try to delete without force - should fail
      final deleted = Jet.delete<TestService>();
      expect(deleted, false);
      expect(Jet.isRegistered<TestService>(), true);
    });

    test('Services can be deleted with force flag', () {
      final service = TestService();
      Jet.put<TestService>(service, permanent: true);

      expect(Jet.isRegistered<TestService>(), true);

      // Delete with force
      final deleted = Jet.delete<TestService>(force: true);
      expect(deleted, true);
      expect(Jet.isRegistered<TestService>(), false);
    });
  });

  group('Permanent Instance Management', () {
    test('Permanent instances should not be deleted by SmartManagement', () {
      final controller = TestController();
      Jet.put(controller, permanent: true);

      expect(Jet.isRegistered<TestController>(), true);

      // Try to delete without force
      final deleted = Jet.delete<TestController>();
      expect(deleted, false);
      expect(Jet.isRegistered<TestController>(), true);
      expect(controller.disposalCount, 0);
    });

    test('Permanent instances can be force deleted', () {
      final controller = TestController();
      Jet.put(controller, permanent: true);

      final deleted = Jet.delete<TestController>(force: true);
      expect(deleted, true);
      expect(Jet.isRegistered<TestController>(), false);
      expect(controller.disposalCount, 1);
    });
  });

  group('Tagged Instance Management', () {
    test('Tagged instances should be isolated', () {
      final controller1 = TestController();
      final controller2 = TestController();

      Jet.put(controller1, tag: 'tag1');
      Jet.put(controller2, tag: 'tag2');

      expect(Jet.isRegistered<TestController>(tag: 'tag1'), true);
      expect(Jet.isRegistered<TestController>(tag: 'tag2'), true);

      Jet.delete<TestController>(tag: 'tag1');

      expect(Jet.isRegistered<TestController>(tag: 'tag1'), false);
      expect(Jet.isRegistered<TestController>(tag: 'tag2'), true);
      expect(controller1.disposalCount, 1);
      expect(controller2.disposalCount, 0);
    });
  });

  group('Bulk Operations', () {
    test('deleteAll should clean up all instances', () {
      final controller1 = TestController();
      final controller2 = TestController();
      final controller3 = TestController();

      Jet.put<TestController>(controller1, tag: '1');
      Jet.put<TestController>(controller2, tag: '2', permanent: true);
      Jet.put<TestController>(controller3, tag: '3');

      Jet.deleteAll();

      expect(Jet.isRegistered<TestController>(tag: '1'), false);
      expect(
          Jet.isRegistered<TestController>(tag: '2'), true); // Permanent stays
      expect(Jet.isRegistered<TestController>(tag: '3'), false);

      expect(controller1.disposalCount, 1);
      expect(controller2.disposalCount, 0);
      expect(controller3.disposalCount, 1);
    });

    test('deleteAll with force should clean everything', () {
      final controller1 = TestController();
      final controller2 = TestController();

      Jet.put<TestController>(controller1, tag: '1');
      Jet.put<TestController>(controller2, tag: '2', permanent: true);

      Jet.deleteAll(force: true);

      expect(Jet.isRegistered<TestController>(tag: '1'), false);
      expect(Jet.isRegistered<TestController>(tag: '2'), false);

      expect(controller1.disposalCount, 1);
      expect(controller2.disposalCount, 1);
    });
  });

  group('Lifecycle Order', () {
    testWidgets('onStart should be called before controller is used',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Container(),
        ),
      );

      var initCalledBeforeReady = false;

      final controller = TestControllerWithInitCallbacks();
      controller.customOnInit = () {
        initCalledBeforeReady = !controller.readyCalled;
      };

      Jet.put(controller);

      // Wait for onReady callback
      await tester.pump();

      // onStart is called during put
      expect(controller.initialized, true);
      expect(controller.initCalled, true);
      // onReady should be called after onInit
      expect(initCalledBeforeReady, true);
    });

    test('onClose should be called before instance is removed', () {
      var closeCalled = false;
      var instanceStillExists = false;

      final controller = TestControllerWithCustomCallbacks();
      controller.customOnClose = () {
        closeCalled = true;
        instanceStillExists =
            Jet.isRegistered<TestControllerWithCustomCallbacks>();
      };

      Jet.put(controller);
      Jet.delete<TestControllerWithCustomCallbacks>();

      expect(closeCalled, true);
      // Instance should have existed when onClose was called
      expect(instanceStillExists, true);
    });
  });

  group('Replace Operations', () {
    test('replace should dispose old instance and register new one', () {
      final oldController = TestController();
      final newController = TestController();

      Jet.put<TestController>(oldController, tag: 'test');
      expect(oldController.disposalCount, 0);

      Jet.replace<TestController>(newController, tag: 'test');

      expect(oldController.disposalCount, 1);
      expect(newController.disposalCount, 0);
      expect(Jet.find<TestController>(tag: 'test'), equals(newController));
    });
  });

  group('Reload Operations', () {
    test('reload should reset instance without removing registration', () {
      var buildCount = 0;

      Jet.lazyPut<TestController>(() {
        buildCount++;
        return TestController();
      });

      final instance1 = Jet.find<TestController>();
      expect(buildCount, 1);

      Jet.reload<TestController>();

      final instance2 = Jet.find<TestController>();
      expect(buildCount, 2);
      expect(instance1, isNot(equals(instance2)));
    });
  });
}
