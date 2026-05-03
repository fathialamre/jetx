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
  testWidgets('Transition.predictiveBack resolves and renders the page',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      defaultTransition: Transition.predictiveBack,
      getPages: [
        JetPage(name: '/', page: () => const _A()),
        JetPage(
          name: '/b',
          page: () => const _B(),
          transition: Transition.predictiveBack,
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/b');
    await tester.pumpAndSettle();

    // We don't try to assert the gesture preview frame contents — that
    // is platform-channel driven on real Android. The contract here is
    // that the transition path doesn't throw and the destination page
    // renders normally.
    expect(find.text('B'), findsOneWidget);

    Jet.back();
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
  });
}
