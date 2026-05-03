import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home')));
}

class _UserScreen extends StatelessWidget {
  const _UserScreen();
  @override
  Widget build(BuildContext context) {
    final id = Jet.parameters['id'];
    final tab = Jet.parameters['tab'];
    return Scaffold(body: Center(child: Text('user=$id tab=$tab')));
  }
}

class UserRoute extends JetRouteData {
  const UserRoute({required this.id, this.tab, this.payload});
  final int id;
  final String? tab;
  final Object? payload;

  @override
  String get location => Jet.buildUrl(
        '/user/:id',
        pathParams: {'id': id},
        queryParams: {'tab': tab},
      );

  @override
  Object? get arguments => payload;
}

void main() {
  testWidgets('Jet.go(typed route) resolves location and pushes',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(name: '/user/:id', page: () => const _UserScreen()),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.go(const UserRoute(id: 42, tab: 'profile'));
    await tester.pumpAndSettle();

    expect(find.textContaining('user=42'), findsOneWidget);
    expect(find.textContaining('tab=profile'), findsOneWidget);
  });

  testWidgets('Jet.go forwards JetRouteData.arguments as route arguments',
      (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(name: '/user/:id', page: () => const _UserScreen()),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.go(const UserRoute(id: 7, payload: {'extra': 'data'}));
    await tester.pumpAndSettle();

    expect(Jet.arguments, {'extra': 'data'});
  });

  testWidgets('Jet.goReplacement replaces current route', (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => const _Home()),
        JetPage(name: '/user/:id', page: () => const _UserScreen()),
      ],
    ));
    await tester.pumpAndSettle();

    Jet.go(const UserRoute(id: 1));
    await tester.pumpAndSettle();
    expect(Jet.history.length, 2);

    Jet.goReplacement(const UserRoute(id: 2));
    await tester.pumpAndSettle();
    expect(Jet.history.length, 2,
        reason: 'replacement keeps stack depth');
    expect(find.textContaining('user=2'), findsOneWidget);
  });
}
