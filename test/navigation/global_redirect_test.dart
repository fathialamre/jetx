import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home')));
}

class _Login extends StatelessWidget {
  const _Login();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('login')));
}

class _Profile extends StatelessWidget {
  const _Profile();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('profile')));
}

void main() {
  testWidgets('global redirect swaps target before per-route middleware',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      redirect: (current) async =>
          current.name == '/login' ? null : '/login',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(name: '/login', page: () => const _Login()),
        JetPage(name: '/profile', page: () => const _Profile()),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.toNamed('/profile');
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget,
        reason: 'redirect must intercept before profile renders');
    expect(find.text('profile'), findsNothing);
  });

  testWidgets(
      'refreshListenable triggers re-evaluation of current route via redirect',
      (tester) async {
    final loggedIn = ValueNotifier<bool>(false);

    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      refreshListenable: loggedIn,
      redirect: (current) async {
        if (current.name == '/login') return null;
        return loggedIn.value ? null : '/login';
      },
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(name: '/login', page: () => const _Login()),
        JetPage(name: '/profile', page: () => const _Profile()),
      ],
    ));
    await tester.pumpAndSettle();

    // Logged-out push to /profile bounces to /login.
    Jet.toNamed('/profile');
    await tester.pumpAndSettle();
    expect(find.text('login'), findsOneWidget);

    // Now log in. refreshListenable fires; current top route (/login)
    // is re-evaluated; redirect returns null for /login so nothing
    // changes. Subsequent navigations should pass through.
    loggedIn.value = true;
    await tester.pumpAndSettle();

    Jet.toNamed('/profile');
    await tester.pumpAndSettle();
    expect(find.text('profile'), findsOneWidget,
        reason:
            'after login, redirect returns null for non-login routes so /profile renders');

    loggedIn.dispose();
  });
}
