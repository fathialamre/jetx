import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home')));
}

/// Throws inside the JetPage factory itself — the scope JetX's per-route
/// errorBuilder targets. (Errors thrown deeper in the descendant build
/// tree fall through to Flutter's `ErrorWidget.builder` and are out of
/// scope.)
Widget _throwingFactory() {
  throw StateError('synthetic page builder failure');
}

void main() {
  testWidgets('per-route errorBuilder renders when page() throws',
      (tester) async {
    Object? captured;
    StackTrace? capturedStack;

    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      onException: (e, s) {
        captured = e;
        capturedStack = s;
      },
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(
          name: '/boom',
          page: _throwingFactory,
          errorBuilder: (ctx, err, stack) => Scaffold(
            body: Center(child: Text('caught: $err')),
          ),
        ),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/boom');
    await tester.pumpAndSettle();

    expect(find.textContaining('caught: '), findsOneWidget,
        reason: 'errorBuilder must render in place of the failing page');
    expect(captured, isA<StateError>());
    expect((captured as StateError).message,
        'synthetic page builder failure');
    expect(capturedStack, isNotNull);
  });

  testWidgets('default fallback renders when no errorBuilder is supplied',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(name: '/boom', page: _throwingFactory),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/boom');
    await tester.pumpAndSettle();

    expect(find.textContaining('Error building page'), findsOneWidget,
        reason: 'default Material fallback must render');
  });

  testWidgets('onException fires even when no per-route errorBuilder is set',
      (tester) async {
    var called = 0;
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      onException: (_, __) => called++,
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(name: '/boom', page: _throwingFactory),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/boom');
    await tester.pumpAndSettle();

    expect(called, 1);
  });
}
