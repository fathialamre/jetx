import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

import 'jet_main_test.dart';

class RedirectMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    return RouteDecoder.fromRoute('/second');
  }
}

class Redirect2Middleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    return RouteDecoder.fromRoute('/first');
  }
}

class RedirectMiddlewareNull extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    return null;
  }
}

class RedirectBypassMiddleware extends GetMiddleware {
  @override
  Future<RouteDecoder?> redirectDelegate(RouteDecoder route) async {
    return route;
  }
}

void main() {
  tearDown(() {
    Jet.reset();
  });

  testWidgets("Middleware should redirect to second screen", (tester) async {
    // Test setup
    await tester.pumpWidget(
      JetMaterialApp(
        initialRoute: '/',
        jetPages: [
          JetPage(name: '/', page: () => const Home()),
          JetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [RedirectMiddleware()],
          ),
          JetPage(name: '/second', page: () => const SecondScreen()),
          JetPage(name: '/third', page: () => const ThirdScreen()),
        ],
      ),
    );

    // Act
    Jet.toNamed('/first');
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(SecondScreen), findsOneWidget);
    expect(find.byType(FirstScreen), findsNothing);
    expect(Jet.currentRoute, '/second');
  });

  testWidgets("Middleware should stop navigation", (tester) async {
    // Test setup
    await tester.pumpWidget(
      JetMaterialApp(
        initialRoute: '/',
        jetPages: [
          JetPage(name: '/', page: () => const Home()),
          JetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [RedirectMiddlewareNull()],
          ),
          JetPage(name: '/second', page: () => const SecondScreen()),
          JetPage(name: '/third', page: () => const ThirdScreen()),
        ],
      ),
    );

    // Act
    await tester.pumpAndSettle();
    Jet.toNamed('/first');
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(Home), findsOneWidget);
    expect(find.byType(FirstScreen), findsNothing);
    expect(Jet.currentRoute, '/');
  });

  testWidgets("Middleware should be bypassed", (tester) async {
    // Test setup
    await tester.pumpWidget(
      JetMaterialApp(
        initialRoute: '/',
        jetPages: [
          JetPage(name: '/', page: () => const Home()),
          JetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [RedirectBypassMiddleware()],
          ),
          JetPage(name: '/second', page: () => const SecondScreen()),
          JetPage(name: '/third', page: () => const ThirdScreen()),
        ],
      ),
    );

    // Act
    await tester.pumpAndSettle();
    Jet.toNamed('/first');
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(FirstScreen), findsOneWidget);
    expect(find.byType(SecondScreen), findsNothing);
    expect(find.byType(Home), findsNothing);
    expect(Jet.currentRoute, '/first');
  });

  testWidgets("Middleware should redirect twice", (tester) async {
    // Test setup
    await tester.pumpWidget(
      JetMaterialApp(
        initialRoute: '/',
        jetPages: [
          JetPage(name: '/', page: () => const Home()),
          JetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [RedirectMiddleware()],
          ),
          JetPage(name: '/second', page: () => const SecondScreen()),
          JetPage(name: '/third', page: () => const ThirdScreen()),
          JetPage(
            name: '/fourth',
            page: () => const FourthScreen(),
            middlewares: [Redirect2Middleware()],
          ),
        ],
      ),
    );

    // Act
    Jet.toNamed('/fourth');
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(SecondScreen), findsOneWidget);
    expect(find.byType(FirstScreen), findsNothing);
    expect(Jet.currentRoute, '/second');
  });

  testWidgets("Navigation history should be correct after redirects",
      (tester) async {
    // Test setup
    await tester.pumpWidget(
      JetMaterialApp(
        initialRoute: '/',
        jetPages: [
          JetPage(name: '/', page: () => const Home()),
          JetPage(
            name: '/first',
            page: () => const FirstScreen(),
            middlewares: [RedirectMiddleware()],
          ),
          JetPage(name: '/second', page: () => const SecondScreen()),
        ],
      ),
    );

    // Act
    Jet.toNamed('/first');
    await tester.pumpAndSettle();

    // Assert
    expect(Jet.currentRoute, '/second');
    expect(Jet.previousRoute, '/');

    // Act: go back
    Jet.back();
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(Home), findsOneWidget);
    expect(Jet.currentRoute, '/');
  });
}
