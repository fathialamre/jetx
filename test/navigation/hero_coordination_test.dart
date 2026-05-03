import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

const _heroTag = 'shared-image';

class _Source extends StatelessWidget {
  const _Source();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Hero(
            tag: _heroTag,
            child: Container(width: 50, height: 50, color: Colors.red),
          ),
        ),
      );
}

class _Destination extends StatelessWidget {
  const _Destination();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Hero(
            tag: _heroTag,
            child: Container(width: 200, height: 200, color: Colors.red),
          ),
        ),
      );
}

void main() {
  testWidgets(
      'Hero animates across declarative push (HeroController in JetNavigator)',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Source()),
        JetPage(name: '/dest', page: () => const _Destination()),
      ],
    ));
    await tester.pumpAndSettle();

    // Source hero present.
    expect(find.byType(Hero), findsOneWidget);

    Jet.toNamed('/dest');
    // Pump mid-flight: during the flight the framework inserts a flying
    // Hero widget into the overlay. There should be at least one Hero
    // visible above and beyond the source/destination's static Hero.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Settle the transition completely.
    await tester.pumpAndSettle();
    expect(find.byType(Hero), findsOneWidget,
        reason: 'destination Hero remains after flight settles');

    // Pop back — flight runs in reverse.
    Jet.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.byType(Hero), findsOneWidget,
        reason: 'source Hero is back after reverse flight settles');
  });
}
