import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class _HomeRoot extends StatelessWidget {
  const _HomeRoot();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home root')));
}

class _HomeDetail extends StatelessWidget {
  const _HomeDetail();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home detail')));
}

class _FeedRoot extends StatelessWidget {
  const _FeedRoot();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('feed root')));
}

class _FeedDetail extends StatelessWidget {
  const _FeedDetail();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('feed detail')));
}

class _ShellHost extends StatefulWidget {
  const _ShellHost();
  @override
  State<_ShellHost> createState() => _ShellHostState();
}

class _ShellHostState extends State<_ShellHost> {
  @override
  Widget build(BuildContext context) {
    return JetStatefulShellRoute(
      branches: [
        JetShellBranch(
          name: 'home',
          pages: [
            JetPage(name: '/', page: () => const _HomeRoot()),
            JetPage(name: '/details', page: () => const _HomeDetail()),
          ],
        ),
        JetShellBranch(
          name: 'feed',
          pages: [
            JetPage(name: '/', page: () => const _FeedRoot()),
            JetPage(name: '/details', page: () => const _FeedDetail()),
          ],
        ),
      ],
      builder: (context, currentIndex, goBranch, body) => Scaffold(
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: goBranch,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('initial branch renders its root page', (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _ShellHost()),
      ],
    ));
    await tester.pumpAndSettle();

    // The active branch shows its root page.
    expect(find.text('home root'), findsOneWidget);
  });

  testWidgets('switching branches preserves nested navigation history',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _ShellHost()),
      ],
    ));
    await tester.pumpAndSettle();

    // Push a detail page on the home branch.
    Jet.toNamed('/details', id: 'home');
    await tester.pumpAndSettle();
    expect(find.text('home detail'), findsOneWidget);

    // Switch to feed branch.
    await tester.tap(find.byIcon(Icons.feed));
    await tester.pumpAndSettle();
    expect(find.text('feed root'), findsOneWidget);

    // Push detail on feed branch.
    Jet.toNamed('/details', id: 'feed');
    await tester.pumpAndSettle();
    expect(find.text('feed detail'), findsOneWidget);

    // Switch back to home — its history is still on /details.
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.text('home detail'), findsOneWidget,
        reason: 'home branch must remember it was on /details');
  });

  testWidgets('re-tapping the active tab pops the branch to root',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _ShellHost()),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/details', id: 'home');
    await tester.pumpAndSettle();
    expect(find.text('home detail'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.text('home root'), findsOneWidget,
        reason: 'tapping active tab pops to branch root');
  });
}
