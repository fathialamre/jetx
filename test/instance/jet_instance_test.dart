// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

import 'util/matcher.dart' as m;

class Mock {
  static Future<String> test() async {
    await Future.delayed(Duration.zero);
    return 'test';
  }
}

abstract class MyController with JetLifeCycleMixin {}

class DisposableController extends MyController {}

// ignore: one_member_abstracts
abstract class Service {
  String post();
}

class Api implements Service {
  @override
  String post() {
    return 'test';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Jet.put test', () async {
    final instance = Jet.put<Controller>(Controller());
    expect(instance, Jet.find<Controller>());
    Jet.reset();
  });

  test('Jet start and delete called just one time', () async {
    Jet
      ..put(Controller())
      ..put(Controller());

    final controller = Jet.find<Controller>();
    expect(controller.init, 1);

    Jet
      ..delete<Controller>()
      ..delete<Controller>();
    expect(controller.close, 1);
    Jet.reset();
  });

  test('Jet.put tag test', () async {
    final instance = Jet.put<Controller>(Controller(), tag: 'one');
    final instance2 = Jet.put<Controller>(Controller(), tag: 'two');
    expect(instance == instance2, false);
    expect(Jet.find<Controller>(tag: 'one') == Jet.find<Controller>(tag: 'two'),
        false);
    expect(Jet.find<Controller>(tag: 'one') == Jet.find<Controller>(tag: 'one'),
        true);
    expect(Jet.find<Controller>(tag: 'two') == Jet.find<Controller>(tag: 'two'),
        true);
    Jet.reset();
  });

  test('Jet.lazyPut tag test', () async {
    Jet.lazyPut<Controller>(() => Controller(), tag: 'one');
    Jet.lazyPut<Controller>(() => Controller(), tag: 'two');

    expect(Jet.find<Controller>(tag: 'one') == Jet.find<Controller>(tag: 'two'),
        false);
    expect(Jet.find<Controller>(tag: 'one') == Jet.find<Controller>(tag: 'one'),
        true);
    expect(Jet.find<Controller>(tag: 'two') == Jet.find<Controller>(tag: 'two'),
        true);
    Jet.reset();
  });

  test('Jet.lazyPut test', () async {
    final controller = Controller();
    Jet.lazyPut<Controller>(() => controller);
    final ct1 = Jet.find<Controller>();
    expect(ct1, controller);
    Jet.reset();
  });

  test('Jet.lazyPut fenix test', () async {
    Jet.lazyPut<Controller>(() => Controller(), fenix: true);
    Jet.find<Controller>().increment();

    expect(Jet.find<Controller>().count, 1);
    Jet.delete<Controller>();
    expect(Jet.find<Controller>().count, 0);
    Jet.reset();
  });

  test('Jet.lazyPut without fenix', () async {
    Jet.lazyPut<Controller>(() => Controller());
    Jet.find<Controller>().increment();

    expect(Jet.find<Controller>().count, 1);
    Jet.delete<Controller>();
    expect(
        () => Jet.find<Controller>(), throwsA(const m.TypeMatcher<String>()));
    Jet.reset();
  });

  test('Jet.reloadInstance test', () async {
    Jet.lazyPut<Controller>(() => Controller());
    var ct1 = Jet.find<Controller>();
    ct1.increment();
    expect(ct1.count, 1);
    ct1 = Jet.find<Controller>();
    expect(ct1.count, 1);
    Jet.reload<Controller>();
    ct1 = Jet.find<Controller>();
    expect(ct1.count, 0);
    Jet.reset();
  });

  test('JetxService test', () async {
    Jet.lazyPut<PermanentService>(() => PermanentService());
    var sv1 = Jet.find<PermanentService>();
    var sv2 = Jet.find<PermanentService>();
    expect(sv1, sv2);
    expect(Jet.isRegistered<PermanentService>(), true);
    Jet.delete<PermanentService>();
    expect(Jet.isRegistered<PermanentService>(), true);
    Jet.delete<PermanentService>(force: true);
    expect(Jet.isRegistered<PermanentService>(), false);
    Jet.reset();
  });

  test('Jet.lazyPut with abstract class test', () async {
    final api = Api();
    Jet.lazyPut<Service>(() => api);
    final ct1 = Jet.find<Service>();
    expect(ct1, api);
    Jet.reset();
  });

  test('Jet.create with abstract class test', () async {
    Jet.spawn<Service>(() => Api());
    final ct1 = Jet.find<Service>();
    final ct2 = Jet.find<Service>();
    // expect(ct1 is Service, true);
    // expect(ct2 is Service, true);
    expect(ct1 == ct2, false);
    Jet.reset();
  });

  group('test put, delete and check onInit execution', () {
    tearDownAll(Jet.reset);

    test('Jet.put test with init check', () async {
      final instance = Jet.put(DisposableController());
      expect(instance, Jet.find<DisposableController>());
      expect(instance.initialized, true);
    });

    test('Jet.delete test with disposable controller', () async {
      // Jet.put(DisposableController());
      expect(Jet.delete<DisposableController>(), true);
      expect(() => Jet.find<DisposableController>(),
          throwsA(const m.TypeMatcher<String>()));
    });

    test('Jet.put test after delete with disposable controller and init check',
        () async {
      final instance = Jet.put<DisposableController>(DisposableController());
      expect(instance, Jet.find<DisposableController>());
      expect(instance.initialized, true);
    });
  });

  group('Jet.replace test for replacing parent instance that is', () {
    tearDown(Jet.reset);
    test('temporary', () async {
      Jet.put(DisposableController());
      Jet.replace<DisposableController>(Controller());
      final instance = Jet.find<DisposableController>();
      expect(instance is Controller, isTrue);
      expect((instance as Controller).init, greaterThan(0));
    });

    test('permanent', () async {
      Jet.put(DisposableController(), permanent: true);
      Jet.replace<DisposableController>(Controller());
      final instance = Jet.find<DisposableController>();
      expect(instance is Controller, isTrue);
      expect((instance as Controller).init, greaterThan(0));
    });

    test('tagged temporary', () async {
      const tag = 'tag';
      Jet.put(DisposableController(), tag: tag);
      Jet.replace<DisposableController>(Controller(), tag: tag);
      final instance = Jet.find<DisposableController>(tag: tag);
      expect(instance is Controller, isTrue);
      expect((instance as Controller).init, greaterThan(0));
    });

    test('tagged permanent', () async {
      const tag = 'tag';
      Jet.put(DisposableController(), permanent: true, tag: tag);
      Jet.replace<DisposableController>(Controller(), tag: tag);
      final instance = Jet.find<DisposableController>(tag: tag);
      expect(instance is Controller, isTrue);
      expect((instance as Controller).init, greaterThan(0));
    });

    test('a generic parent type', () async {
      const tag = 'tag';
      Jet.put<MyController>(DisposableController(), permanent: true, tag: tag);
      Jet.replace<MyController>(Controller(), tag: tag);
      final instance = Jet.find<MyController>(tag: tag);
      expect(instance is Controller, isTrue);
      expect((instance as Controller).init, greaterThan(0));
    });
  });

  group('Jet.lazyReplace replaces parent instance', () {
    tearDown(Jet.reset);
    test('without fenix', () async {
      Jet.put(DisposableController());
      Jet.lazyReplace<DisposableController>(() => Controller());
      final instance = Jet.find<DisposableController>();
      expect(instance, isA<Controller>());
      expect((instance as Controller).init, greaterThan(0));
    });

    test('with fenix', () async {
      Jet.put(DisposableController());
      Jet.lazyReplace<DisposableController>(() => Controller(), fenix: true);
      expect(Jet.find<DisposableController>(), isA<Controller>());
      (Jet.find<DisposableController>() as Controller).increment();

      expect((Jet.find<DisposableController>() as Controller).count, 1);
      Jet.delete<DisposableController>();
      expect((Jet.find<DisposableController>() as Controller).count, 0);
    });

    test('with fenix when parent is permanent', () async {
      Jet.put(DisposableController(), permanent: true);
      Jet.lazyReplace<DisposableController>(() => Controller());
      final instance = Jet.find<DisposableController>();
      expect(instance, isA<Controller>());
      (instance as Controller).increment();

      expect((Jet.find<DisposableController>() as Controller).count, 1);
      Jet.delete<DisposableController>();
      expect((Jet.find<DisposableController>() as Controller).count, 0);
    });
  });

  group('Jet.findOrNull test', () {
    tearDown(Jet.reset);
    test('checking results', () async {
      Jet.put<int>(1);
      int? result = Jet.findOrNull<int>();
      expect(result, 1);

      Jet.delete<int>();
      result = Jet.findOrNull<int>();
      expect(result, null);
    });
  });
}

class PermanentService extends JetxService {}

class Controller extends DisposableController {
  int init = 0;
  int close = 0;
  int count = 0;
  @override
  void onInit() {
    init++;
    super.onInit();
  }

  @override
  void onClose() {
    close++;
    super.onClose();
  }

  void increment() {
    count++;
  }
}
