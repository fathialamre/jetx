import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home')));
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('loading...')),
      );
}

void main() {
  testWidgets('pageTimeout swaps to onTimeout after deadline', (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(
          name: '/slow',
          page: () => const _Loading(),
          // Use a deadline larger than the route push transition
          // (~300ms) so pumpAndSettle does not advance the fake clock
          // past the timer.
          pageTimeout: const Duration(seconds: 5),
          onTimeout: (_) => const Scaffold(
            body: Center(child: Text('timed out')),
          ),
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/slow');
    await tester.pumpAndSettle();

    expect(find.text('loading...'), findsOneWidget);
    expect(find.text('timed out'), findsNothing);

    // Advance past the deadline explicitly.
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('timed out'), findsOneWidget);
    expect(find.text('loading...'), findsNothing);
  });

  testWidgets('popping before timeout cancels the swap', (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(
          name: '/slow',
          page: () => const _Loading(),
          pageTimeout: const Duration(seconds: 5),
          onTimeout: (_) => const Scaffold(
            body: Center(child: Text('timed out')),
          ),
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/slow');
    await tester.pumpAndSettle();
    expect(find.text('loading...'), findsOneWidget);

    Jet.back();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);

    // Past the deadline; nothing should be timed-out anywhere.
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('timed out'), findsNothing);
  });

  testWidgets('pageTimeout without onTimeout is a no-op', (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(
          name: '/slow',
          page: () => const _Loading(),
          pageTimeout: const Duration(seconds: 1),
          // no onTimeout supplied
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/slow');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('loading...'), findsOneWidget,
        reason: 'no swap when onTimeout is absent');
  });
}
