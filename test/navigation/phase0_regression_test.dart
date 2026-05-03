import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class _A extends StatelessWidget {
  const _A();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('A')));
}

class _B extends StatelessWidget {
  const _B();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('B')));
}

class _C extends StatelessWidget {
  const _C();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('C')));
}

class _D extends StatelessWidget {
  const _D();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('D')));
}

class _CtrlA extends JetxController {}

class _CtrlB extends JetxController {}

class _CtrlC extends JetxController {}

class _PageWithCtrl<T> extends StatelessWidget {
  const _PageWithCtrl(this.factory, this.label);
  final T Function() factory;
  final String label;
  @override
  Widget build(BuildContext context) {
    Jet.put<T>(factory());
    return Scaffold(body: Center(child: Text(label)));
  }
}

class _CancelMiddleware extends JetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async => null;
}

void main() {
  tearDown(() => Jet.reset());

  group('Phase 0 — bug regressions', () {
    testWidgets(
        '0.1 offUntil disposes intermediate controllers (no longer bypasses cleanup)',
        (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _A()),
        ],
      ));
      await tester.pumpAndSettle();

      Jet.to(() => _PageWithCtrl<_CtrlA>(_CtrlA.new, 'a'));
      await tester.pumpAndSettle();
      Jet.to(() => _PageWithCtrl<_CtrlB>(_CtrlB.new, 'b'));
      await tester.pumpAndSettle();
      Jet.to(() => _PageWithCtrl<_CtrlC>(_CtrlC.new, 'c'));
      await tester.pumpAndSettle();

      expect(Jet.isRegistered<_CtrlA>(), isTrue);
      expect(Jet.isRegistered<_CtrlB>(), isTrue);
      expect(Jet.isRegistered<_CtrlC>(), isTrue);

      // Pop everything above '/' and push _D. Before fix, intermediate
      // controllers leaked because removeLast was used directly.
      Jet.offUntil(() => const _D(), (route) => route.name == '/');
      await tester.pumpAndSettle();

      expect(find.text('D'), findsOneWidget);
      expect(Jet.isRegistered<_CtrlB>(), isFalse,
          reason: 'middle controller must be disposed by offUntil');
      expect(Jet.isRegistered<_CtrlC>(), isFalse,
          reason: 'top controller must be disposed by offUntil');
    });

    testWidgets(
        '0.1 offNamedUntil disposes intermediate controllers',
        (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _A()),
          JetPage(
              name: '/b',
              page: () => _PageWithCtrl<_CtrlB>(_CtrlB.new, 'b')),
          JetPage(
              name: '/c',
              page: () => _PageWithCtrl<_CtrlC>(_CtrlC.new, 'c')),
          JetPage(name: '/d', page: () => const _D()),
        ],
      ));
      await tester.pumpAndSettle();

      Jet.toNamed('/b');
      await tester.pumpAndSettle();
      Jet.toNamed('/c');
      await tester.pumpAndSettle();
      expect(Jet.isRegistered<_CtrlB>(), isTrue);
      expect(Jet.isRegistered<_CtrlC>(), isTrue);

      Jet.offNamedUntil('/d', (route) => route.name == '/');
      await tester.pumpAndSettle();

      expect(find.text('D'), findsOneWidget);
      expect(Jet.isRegistered<_CtrlB>(), isFalse);
      expect(Jet.isRegistered<_CtrlC>(), isFalse);
    });

    testWidgets(
        '0.2 concurrent navigations preserve call order via _push lock',
        (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _A()),
          JetPage(name: '/b', page: () => const _B()),
          JetPage(name: '/c', page: () => const _C()),
          JetPage(name: '/d', page: () => const _D()),
        ],
      ));
      await tester.pumpAndSettle();

      // Fire three pushes back-to-back without awaiting. Without the lock,
      // any async middleware step could interleave and produce a stack out
      // of call order. With the lock the final stack must be /, /b, /c, /d.
      final futures = <Future<void>>[
        if (Jet.toNamed<void>('/b') case final f?) f,
        if (Jet.toNamed<void>('/c') case final f?) f,
        if (Jet.toNamed<void>('/d') case final f?) f,
      ];
      await tester.pumpAndSettle();

      final delegate = Jet.rootController.rootDelegate;
      expect(delegate.activePages.map((e) => e.route?.name).toList(),
          ['/', '/b', '/c', '/d']);

      // Drain pending futures so test doesn't leak unawaited completers.
      Jet.back();
      Jet.back();
      Jet.back();
      await tester.pumpAndSettle();
      await Future.wait(futures);
    });

    testWidgets(
        '0.3 cancelled middleware completes the awaiting future to null',
        (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _A()),
          JetPage(
              name: '/blocked',
              page: () => const _B(),
              middlewares: [_CancelMiddleware()]),
        ],
      ));
      await tester.pumpAndSettle();

      // Before fix: this future never resolved.
      final pending = Jet.toNamed<String>('/blocked');
      expect(pending, isNotNull,
          reason: 'toNamed must return a future for an existing route');
      final result =
          await pending!.timeout(const Duration(seconds: 2));

      expect(result, isNull,
          reason:
              'cancelled-by-middleware navigation must resolve to null, not hang');
      expect(Jet.currentRoute, '/');
    });

    test('0.4 RouteDecoder is value-equal and replaceLast yields a new instance',
        () {
      final p = JetPage(name: '/x', page: () => const _A());
      final d1 = RouteDecoder([p], null);
      final d2 = RouteDecoder([p], null);
      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));

      final replacement = p.copyWith(name: '/y');
      final d3 = d1.replaceLast(replacement);
      expect(identical(d1, d3), isFalse,
          reason: 'replaceLast must produce a new instance');
      expect(d3.route?.name, '/y');
      expect(d1.route?.name, '/x',
          reason: 'original must remain unchanged (immutability)');
    });
  });
}
