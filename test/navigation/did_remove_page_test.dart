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

class _BlockedDetail extends StatelessWidget {
  const _BlockedDetail();
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: const Scaffold(body: Center(child: Text('blocked'))),
      );
}

void main() {
  group('JetDelegate.onDidRemovePage reconciliation', () {
    testWidgets(
        'framework-driven pop (maybePop) shrinks _activePages and resolves completer',
        (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _Home()),
          JetPage(name: '/detail', page: () => const _Detail()),
        ],
      ));
      await tester.pumpAndSettle();

      final delegate = Jet.rootController.rootDelegate;

      final pushFuture = Jet.toNamed('/detail');
      await tester.pumpAndSettle();
      expect(delegate.activePages.length, 2);
      expect(find.text('detail'), findsOneWidget);

      // Same path the system back gesture / AppBar back button take.
      await Jet.key.currentState!.maybePop();
      await tester.pumpAndSettle();

      expect(delegate.activePages.length, 1,
          reason: 'onDidRemovePage must drop entry from _activePages');
      expect(find.text('home'), findsOneWidget);
      // Completer for the popped page resolves so awaiters wake up.
      await expectLater(pushFuture, completes);
    });

    testWidgets('PopScope(canPop: false) leaves _activePages untouched',
        (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _Home()),
          JetPage(name: '/blocked', page: () => const _BlockedDetail()),
        ],
      ));
      await tester.pumpAndSettle();

      final delegate = Jet.rootController.rootDelegate;
      Jet.toNamed('/blocked');
      await tester.pumpAndSettle();
      expect(delegate.activePages.length, 2);

      await Jet.key.currentState!.maybePop();
      await tester.pumpAndSettle();

      // maybePop's return value varies across Flutter versions; the contract
      // we care about is that the framework did NOT remove the page, so
      // _activePages must stay at 2 and the blocked screen must remain.
      expect(delegate.activePages.length, 2,
          reason: '_activePages must not shrink when PopScope refuses pop');
      expect(find.text('blocked'), findsOneWidget);
    });

    testWidgets('imperative Jet.back still works (idempotent path)',
        (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/',
        getPages: [
          JetPage(name: '/', page: () => const _Home()),
          JetPage(name: '/detail', page: () => const _Detail()),
        ],
      ));
      await tester.pumpAndSettle();

      final delegate = Jet.rootController.rootDelegate;
      Jet.toNamed('/detail');
      await tester.pumpAndSettle();
      expect(delegate.activePages.length, 2);

      Jet.back();
      await tester.pumpAndSettle();

      expect(delegate.activePages.length, 1);
      expect(find.text('home'), findsOneWidget);
    });
  });
}
