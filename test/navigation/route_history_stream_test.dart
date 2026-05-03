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

void main() {
  // Note: tearDown(Jet.reset) intentionally omitted. Jet.reset()
  // resetInstance() with force:true wipes permanent state including the
  // root delegate registration, which then breaks subsequent tests that
  // assume rootController is live. The next test's pumpWidget rebuilds
  // the JetRoot, which re-registers everything, so cross-test state
  // does not leak even without an explicit reset.

  testWidgets('Jet.history reflects the current page stack', (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _A()),
        JetPage(name: '/b', page: () => const _B()),
        JetPage(name: '/c', page: () => const _C()),
      ],
    ));
    await tester.pumpAndSettle();

    expect(Jet.history.map((r) => r.name).toList(), ['/']);

    Jet.toNamed('/b');
    await tester.pumpAndSettle();
    expect(Jet.history.map((r) => r.name).toList(), ['/', '/b']);

    Jet.toNamed('/c');
    await tester.pumpAndSettle();
    expect(Jet.history.map((r) => r.name).toList(), ['/', '/b', '/c']);

    Jet.back();
    await tester.pumpAndSettle();
    expect(Jet.history.map((r) => r.name).toList(), ['/', '/b']);
  });

  testWidgets(
      'addRouteChangeListener fires once per distinct top-of-stack change',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _A()),
        JetPage(name: '/b', page: () => const _B()),
        JetPage(name: '/c', page: () => const _C()),
      ],
    ));
    await tester.pumpAndSettle();

    final emitted = <String>[];
    final listener = Jet.addRouteChangeListener((r) => emitted.add(r.name));
    addTearDown(() => Jet.removeRouteChangeListener(listener));

    Jet.toNamed('/b');
    await tester.pumpAndSettle();
    Jet.toNamed('/c');
    await tester.pumpAndSettle();
    Jet.back();
    await tester.pumpAndSettle();

    expect(emitted, ['/b', '/c', '/b'],
        reason:
            'one notification per top-of-stack change, no dupes from rebuild churn');
  });

  testWidgets('addRouteChangeListener carries arguments + parameters',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _A()),
        JetPage(name: '/user/:id', page: () => const _B()),
      ],
    ));
    await tester.pumpAndSettle();

    final emitted = <RouteRecord>[];
    final listener = Jet.addRouteChangeListener(emitted.add);
    addTearDown(() => Jet.removeRouteChangeListener(listener));

    Jet.toNamed('/user/42', arguments: {'flavor': 'pro'});
    await tester.pumpAndSettle();

    expect(emitted, hasLength(1));
    final record = emitted.first;
    // After matching, the route name carries the resolved path, not the
    // template. Parameters carry the dynamic segment values.
    expect(record.name, '/user/42');
    expect(record.parameters['id'], '42');
    expect(record.arguments, {'flavor': 'pro'});
  });

  test('RouteRecord equality is value-based (parameters via mapEquals)', () {
    final a = const RouteRecord(
        name: '/x', arguments: 'arg', parameters: {'k': 'v'});
    final b = const RouteRecord(
        name: '/x', arguments: 'arg', parameters: {'k': 'v'});
    final c = a.copyWith(parameters: {'k': 'w'});

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a == c, isFalse);
  });
}
