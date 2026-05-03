import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home')));
}

class _Detail extends StatelessWidget {
  const _Detail();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('detail')));
}

void main() {
  testWidgets(
      'restorationScopeId on JetMaterialApp is plumbed through without error',
      (tester) async {
    // Smoke coverage of the restoration plumbing. End-to-end process-death
    // round-trip is not feasible in widget tests; this asserts the wire-up
    // doesn't throw and pages still render. Persistence integrity is
    // covered manually + on-device.
    await tester.pumpWidget(JetMaterialApp(
      restorationScopeId: 'jetx-app',
      initialRoute: '/',
      getPages: [
        JetPage(
          name: '/',
          page: () => const _Home(),
          restorationId: 'home-page',
        ),
        JetPage(
          name: '/detail',
          page: () => const _Detail(),
          restorationId: 'detail-page',
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/detail');
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);

    Jet.back();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets(
      'JetPage.copyWith preserves restorationId (regression for self-reference bug)',
      (tester) async {
    // Pre-Phase-3, copyWith's restorationId branch read `restorationId ??
    // restorationId` (the parameter name on both sides), so the field was
    // never actually carried over from `this`. This test guards against
    // a regression of that bug.
    final base = JetPage(
      name: '/x',
      page: () => const _Home(),
      restorationId: 'original',
    );
    final next = base.copyWith(name: '/y');
    expect(next.restorationId, 'original');
  });
}
