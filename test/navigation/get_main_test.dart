import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Jet.to navigates to provided route", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));

    Jet.to(() => const FirstScreen());

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsOneWidget);
  });

  testWidgets("Jet.toNamed navigates to provided named route", (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/first',
      getPages: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    Jet.toNamed('/second');

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets("unknowroute", (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/first',
      unknownRoute: JetPage(name: '/404', page: () => const Scaffold()),
      getPages: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    Jet.toNamed('/secondd');

    await tester.pumpAndSettle();

    expect(Jet.rootController.rootDelegate.currentConfiguration?.route?.name,
        '/404');
  });

  testWidgets("Jet.off navigates to provided route", (tester) async {
    await tester.pumpWidget(const Wrapper(child: FirstScreen()));
    // await tester.pump();

    Jet.off(() => const SecondScreen());

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets("Jet.off removes current route", (tester) async {
    await tester.pumpWidget(const Wrapper(child: FirstScreen()));
    await tester.pump();

    Jet.off(() => const SecondScreen());
    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsNothing);
  });

  testWidgets("Jet.offNamed navigates to provided named route", (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/first',
      getPages: [
        JetPage(name: '/first', page: () => const FirstScreen()),
        JetPage(name: '/second', page: () => const SecondScreen()),
        JetPage(name: '/third', page: () => const ThirdScreen()),
      ],
    ));

    await tester.pump();

    Jet.offNamed('/second');

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets("Jet.offNamed removes current route", (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/first',
      getPages: [
        JetPage(name: '/first', page: () => const FirstScreen()),
        JetPage(name: '/second', page: () => const SecondScreen()),
        JetPage(name: '/third', page: () => const ThirdScreen()),
      ],
    ));

    await tester.pump();

    Jet.offNamed('/second');
    await tester.pumpAndSettle();
    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsNothing);
  });

  testWidgets("Jet.offNamed removes only current route", (tester) async {
    await tester.pumpWidget(JetMaterialApp(
      initialRoute: '/first',
      getPages: [
        JetPage(name: '/first', page: () => const FirstScreen()),
        JetPage(name: '/second', page: () => const SecondScreen()),
        JetPage(name: '/third', page: () => const ThirdScreen()),
      ],
    ));

    // await tester.pump();

    Jet.toNamed('/second');
    await tester.pumpAndSettle();
    Jet.offNamed('/third');
    await tester.pumpAndSettle();
    Jet.back();
    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets("Jet.offAll navigates to provided route", (tester) async {
    await tester.pumpWidget(const Wrapper(child: FirstScreen()));
    await tester.pump();

    Jet.offAll(() => const SecondScreen());

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets("Jet.offAll removes all previous routes", (tester) async {
    await tester.pumpWidget(const Wrapper(child: FirstScreen()));
    await tester.pump();

    Jet.to(() => const SecondScreen());
    await tester.pumpAndSettle();
    Jet.offAll(() => const ThirdScreen());
    await tester.pumpAndSettle();
    Jet.back();
    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsNothing);

    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsNothing);
  });

  testWidgets("Jet.offAllNamed navigates to provided named route",
      (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    await tester.pump();

    Jet.toNamed('/second');

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets("Jet.offAllNamed removes all previous routes", (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    await tester.pump();

    Jet.toNamed('/second');
    await tester.pumpAndSettle();
    Jet.offAllNamed('/third');
    await tester.pumpAndSettle();
    Jet.back();
    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsNothing);

    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsNothing);
  });

  testWidgets("Jet.offAndToNamed navigates to provided route", (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    Jet.offAndToNamed('/second');

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets("Jet.offAndToNamed removes previous route", (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    Jet.offAndToNamed('/second');

    await tester.pumpAndSettle();
    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsNothing);
  });

  testWidgets("Jet.offUntil navigates to provided route", (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));

    Jet.to(() => const FirstScreen());

    await tester.pumpAndSettle();

    Jet.offUntil(
        () => const ThirdScreen(), (route) => route.name == '/FirstScreen');

    await tester.pumpAndSettle();

    expect(find.byType(ThirdScreen), findsOneWidget);
  });

  testWidgets("Jet.until removes each route that meet the predicate",
      (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    Jet.toNamed('/second');
    await tester.pumpAndSettle();

    Jet.toNamed('/third');
    await tester.pumpAndSettle();

    Jet.until((route) => route.name == '/first');

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsOneWidget);
    expect(find.byType(SecondScreen), findsNothing);
    expect(find.byType(ThirdScreen), findsNothing);
  });

  testWidgets(
      "Jet.offUntil removes previous routes if they don't match predicate",
      (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));

    Jet.to(() => const FirstScreen());
    await tester.pumpAndSettle();
    Jet.to(() => const SecondScreen());
    await tester.pumpAndSettle();
    Jet.offUntil(
        () => const ThirdScreen(), (route) => route.name == '/FirstScreen');
    await tester.pumpAndSettle();
    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsNothing);
  });

  testWidgets(
      "Jet.offUntil leaves previous routes that match provided predicate",
      (tester) async {
    await tester.pumpWidget(Wrapper(child: Container()));

    Jet.to(() => const FirstScreen());
    await tester.pumpAndSettle();
    Jet.to(() => const SecondScreen());
    await tester.pumpAndSettle();
    Jet.offUntil(
        () => const ThirdScreen(), (route) => route.name == '/FirstScreen');
    await tester.pumpAndSettle();
    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsOneWidget);
  });

  group('Jet.offNamedUntil Tests', () {
    testWidgets("Navigates to provided route", (tester) async {
      await tester.pumpWidget(WrapperNamed(
        initialRoute: '/first',
        namedRoutes: [
          JetPage(page: () => const FirstScreen(), name: '/first'),
          JetPage(page: () => const SecondScreen(), name: '/second'),
          JetPage(page: () => const ThirdScreen(), name: '/third')
        ],
      ));

      Jet.offNamedUntil('/second', (route) => route.name == '/first');
      await tester.pumpAndSettle();

      expect(find.byType(SecondScreen), findsOneWidget);
      expect(Jet.currentRoute, '/second');
    });

    testWidgets("Removes routes that don't match predicate", (tester) async {
      await tester.pumpWidget(WrapperNamed(
        initialRoute: '/first',
        namedRoutes: [
          JetPage(page: () => const FirstScreen(), name: '/first'),
          JetPage(page: () => const SecondScreen(), name: '/second'),
          JetPage(page: () => const ThirdScreen(), name: '/third')
        ],
      ));

      Jet.toNamed('/second');
      await tester.pumpAndSettle();
      Jet.offNamedUntil('/third', (route) => route.name == '/first');
      await tester.pumpAndSettle();

      expect(find.byType(ThirdScreen), findsOneWidget);
      expect(Jet.currentRoute, '/third');
      expect(Jet.previousRoute, '/first');
    });

    testWidgets("Keeps routes that match predicate", (tester) async {
      await tester.pumpWidget(WrapperNamed(
        initialRoute: '/first',
        namedRoutes: [
          JetPage(page: () => const FirstScreen(), name: '/first'),
          JetPage(page: () => const SecondScreen(), name: '/second'),
          JetPage(page: () => const ThirdScreen(), name: '/third'),
        ],
      ));

      Jet.toNamed('/second');
      await tester.pumpAndSettle();
      Jet.offNamedUntil('/third', (route) => route.name == '/first');
      await tester.pumpAndSettle();
      Jet.back();
      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
      expect(Jet.currentRoute, '/first');
    });

    testWidgets("Handles predicate that never returns true", (tester) async {
      await tester.pumpWidget(WrapperNamed(
        initialRoute: '/first',
        namedRoutes: [
          JetPage(page: () => const FirstScreen(), name: '/first'),
          JetPage(page: () => const SecondScreen(), name: '/second'),
          JetPage(page: () => const ThirdScreen(), name: '/third'),
          JetPage(page: () => const FourthScreen(), name: '/fourth'),
        ],
      ));

      Jet.toNamed('/second');
      await tester.pumpAndSettle();

      Jet.toNamed('/third');
      await tester.pumpAndSettle();

      Jet.offNamedUntil('/fourth', (route) => false);
      await tester.pumpAndSettle();

      expect(find.byType(FourthScreen), findsOneWidget);
      expect(Jet.currentRoute, '/fourth');
      expect(Jet.previousRoute, '/first');
    });

    testWidgets("Handles complex navigation scenario", (tester) async {
      await tester.pumpWidget(WrapperNamed(
        initialRoute: '/first',
        namedRoutes: [
          JetPage(page: () => const FirstScreen(), name: '/first'),
          JetPage(page: () => const SecondScreen(), name: '/second'),
          JetPage(page: () => const ThirdScreen(), name: '/third'),
          JetPage(page: () => const FourthScreen(), name: '/fourth'),
        ],
      ));

      Jet.toNamed('/second');
      await tester.pumpAndSettle();
      Jet.toNamed('/third');
      await tester.pumpAndSettle();
      Jet.offNamedUntil('/fourth', (route) => route.name == '/first');
      await tester.pumpAndSettle();

      expect(find.byType(FourthScreen), findsOneWidget);
      expect(Jet.currentRoute, '/fourth');
      expect(Jet.previousRoute, '/first');

      Jet.back();
      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
      expect(Jet.currentRoute, '/first');
    });
  });

  testWidgets("Jet.offNamedUntil navigates to provided route", (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    Jet.offNamedUntil('/second', (route) => route.name == '/first');

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsOneWidget);
  });

  testWidgets(
      "Jet.offNamedUntil removes previous routes if they don't match predicate",
      (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    Jet.toNamed('/second');
    await tester.pumpAndSettle();
    Jet.offNamedUntil('/third', (route) => route.name == '/first');

    await tester.pumpAndSettle();

    expect(find.byType(SecondScreen), findsNothing);
  });

  testWidgets(
      "Jet.offNamedUntil leaves previous routes that match provided predicate",
      (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third'),
      ],
    ));

    Jet.toNamed('/second');
    await tester.pumpAndSettle();
    Jet.offNamedUntil('/third', (route) => route.name == '/first');
    await tester.pumpAndSettle();
    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsOneWidget);
  });

  testWidgets("Jet.back navigates back", (tester) async {
    await tester.pumpWidget(
      Wrapper(
        defaultTransition: Transition.circularReveal,
        child: Container(),
      ),
    );

    // await tester.pump();

    Jet.to(() => const FirstScreen());
    await tester.pumpAndSettle();

    Jet.to(() => const SecondScreen());
    await tester.pumpAndSettle();
    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsOneWidget);
  });

  testWidgets(
      "Jet.back with closeOverlays pops both snackbar and current route",
      (tester) async {
    await tester.pumpWidget(
      Wrapper(
        defaultTransition: Transition.circularReveal,
        child: Container(),
      ),
    );

    // await tester.pump();

    Jet.to(() => const FirstScreen());
    await tester.pumpAndSettle();
    Jet.to(() => const SecondScreen());
    await tester.pumpAndSettle();
    Jet.snackbar('title', "message");
    await tester.pumpAndSettle();
    Jet.backLegacy(closeOverlays: true);

    await tester.pumpAndSettle();

    expect(Jet.isSnackbarOpen, false);

    expect(find.byType(FirstScreen), findsOneWidget);
  });

  testWidgets("Jet.until", (tester) async {
    await tester.pumpWidget(WrapperNamed(
      initialRoute: '/first',
      namedRoutes: [
        JetPage(page: () => const FirstScreen(), name: '/first'),
        JetPage(page: () => const SecondScreen(), name: '/second'),
        JetPage(page: () => const ThirdScreen(), name: '/third')
      ],
    ));

    await tester.pump();

    Jet.toNamed('/second');
    await tester.pumpAndSettle();
    Jet.toNamed('/third');
    await tester.pumpAndSettle();
    Jet.until((route) => route.name == '/first');
    await tester.pumpAndSettle();

    expect(find.byType(FirstScreen), findsOneWidget);
  });

  group("Jet.defaultTransition smoke test", () {
    testWidgets("fadeIn", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.fadeIn,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("downToUp", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.downToUp,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("fade", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.fade,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("leftToRight", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.leftToRight,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("leftToRightWithFade", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.leftToRightWithFade,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("leftToRightWithFade", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.rightToLeft,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("defaultTransition", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.rightToLeft,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("rightToLeftWithFade", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.rightToLeftWithFade,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("cupertino", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.cupertino,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });

    testWidgets("size", (tester) async {
      await tester.pumpWidget(
        Wrapper(
          defaultTransition: Transition.size,
          child: Container(),
        ),
      );

      Jet.to(() => const FirstScreen());

      await tester.pumpAndSettle();

      expect(find.byType(FirstScreen), findsOneWidget);
    });
  });
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(child: const Text('Home'));
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(child: const Text('FirstScreen'));
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FourthScreen extends StatelessWidget {
  const FourthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
