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

void main() {
  group('Phase 3.1 — reverseCurve', () {
    test('JetPage stores reverseCurve', () {
      final p = JetPage(
        name: '/x',
        page: () => const _A(),
        curve: Curves.easeOut,
        reverseCurve: Curves.easeInCubic,
      );
      expect(p.curve, Curves.easeOut);
      expect(p.reverseCurve, Curves.easeInCubic);
    });

    test('copyWith preserves and updates reverseCurve', () {
      final base = JetPage(
        name: '/x',
        page: () => const _A(),
        reverseCurve: Curves.easeIn,
      );
      final next = base.copyWith(reverseCurve: Curves.easeOut);
      expect(next.reverseCurve, Curves.easeOut);
      final preserved = base.copyWith(curve: Curves.linear);
      expect(preserved.reverseCurve, Curves.easeIn,
          reason: 'reverseCurve unchanged when copyWith does not pass it');
    });

    testWidgets('push and back render normally with reverseCurve set',
        (tester) async {
      // Smoke test only: assert the route still pushes/pops cleanly
      // when reverseCurve is non-null. Frame-by-frame curve sampling
      // would be flaky across Flutter releases.
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _A()),
          JetPage(
            name: '/b',
            page: () => const _B(),
            curve: Curves.easeOut,
            reverseCurve: Curves.easeInCubic,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      Jet.toNamed('/b');
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);

      Jet.back();
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
    });
  });

  group('Phase 3.4 — transitionResolver', () {
    testWidgets('resolver is invoked with (from, to) on each push',
        (tester) async {
      final pairs = <(String?, String)>[];

      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        transitionResolver: (from, to) {
          pairs.add((from?.name, to.name));
          return Transition.fade;
        },
        getPages: [
          JetPage(name: '/', page: () => const _A()),
          JetPage(name: '/b', page: () => const _B()),
        ],
      ));
      await tester.pumpAndSettle();

      Jet.toNamed('/b');
      await tester.pumpAndSettle();

      expect(pairs, isNotEmpty,
          reason: 'resolver runs at least once on the /b push');
      expect(pairs.last.$2, '/b');
    });

    testWidgets('returning null falls through to route default',
        (tester) async {
      var calls = 0;
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        transitionResolver: (from, to) {
          calls++;
          return null;
        },
        getPages: [
          JetPage(name: '/', page: () => const _A()),
          JetPage(
            name: '/b',
            page: () => const _B(),
            transition: Transition.fade,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      Jet.toNamed('/b');
      await tester.pumpAndSettle();

      expect(calls, greaterThan(0));
      expect(find.text('B'), findsOneWidget,
          reason: 'navigation succeeds even when resolver returns null');
    });
  });
}
