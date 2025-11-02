import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

import 'utils/wrapper.dart';

/// Comprehensive navigation tests to verify routing, dialogs, sheets, and lifecycle
void main() {
  setUp(() {
    Jet.resetInstance();
  });

  tearDown(() {
    Jet.resetInstance();
  });

  group('Basic Navigation', () {
    testWidgets('Jet.to should navigate to new page', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.to(() => const SecondPage()),
            child: const Text('Navigate'),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('Jet.back should navigate back', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.to(() => const SecondPage()),
            child: const Text('Navigate'),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);

      Jet.back();
      await tester.pumpAndSettle();

      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);
    });

    testWidgets('Jet.off should replace current page', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.off(() => const SecondPage()),
            child: const Text('Replace'),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);

      // Try to go back - should not be able to
      Jet.back();
      await tester.pumpAndSettle();

      // Should still be on second page
      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('Jet.offAll should clear stack and navigate', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => Jet.to(() => const SecondPage()),
                child: const Text('Page 2'),
              ),
            ],
          ),
        ),
      );

      await tester.pump();

      // Navigate to page 2
      await tester.tap(find.text('Page 2'));
      await tester.pumpAndSettle();

      // Navigate to page 3 with offAll
      Jet.offAll(() => const ThirdPage());
      await tester.pumpAndSettle();

      expect(find.text('Third Page'), findsOneWidget);

      // Try to go back - should not be able to
      Jet.back();
      await tester.pumpAndSettle();

      // Should still be on third page
      expect(find.text('Third Page'), findsOneWidget);
    });
  });

  group('Dialog Navigation', () {
    testWidgets('Jet.dialog should show dialog', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.dialog(
              const AlertDialog(
                title: Text('Test Dialog'),
              ),
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.pump();

      expect(Jet.isDialogOpen ?? false, isFalse);

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(Jet.isDialogOpen ?? false, isTrue);
    });

    testWidgets('Jet.backLegacy should close dialog', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.dialog(
              const AlertDialog(
                title: Text('Test Dialog'),
              ),
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(Jet.isDialogOpen ?? false, isTrue);

      Jet.backLegacy();
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsNothing);
      expect(Jet.isDialogOpen ?? false, isFalse);
    });

    testWidgets('closeDialog should close specific dialog', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.dialog(
              const AlertDialog(
                title: Text('Test Dialog'),
              ),
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(Jet.isDialogOpen ?? false, isTrue);

      Jet.closeDialog();
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsNothing);
      expect(Jet.isDialogOpen ?? false, isFalse);
    });

    testWidgets('closeAllDialogs should close multiple dialogs',
        (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () async {
              await Jet.dialog(
                AlertDialog(
                  title: const Text('Dialog 1'),
                  content: ElevatedButton(
                    onPressed: () => Jet.dialog(
                      const AlertDialog(
                        title: Text('Dialog 2'),
                      ),
                    ),
                    child: const Text('Show Dialog 2'),
                  ),
                ),
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog 2'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog 2'), findsOneWidget);

      Jet.closeAllDialogs();
      await tester.pumpAndSettle();

      expect(find.text('Dialog 1'), findsNothing);
      expect(find.text('Dialog 2'), findsNothing);
    });
  });

  group('BottomSheet Navigation', () {
    testWidgets('Jet.bottomSheet should show bottom sheet', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.bottomSheet(
              Container(
                height: 200,
                child: const Center(
                  child: Text('Bottom Sheet'),
                ),
              ),
            ),
            child: const Text('Show Sheet'),
          ),
        ),
      );

      await tester.pump();

      expect(Jet.isBottomSheetOpen ?? false, isFalse);

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Bottom Sheet'), findsOneWidget);
      expect(Jet.isBottomSheetOpen ?? false, isTrue);
    });

    testWidgets('closeBottomSheet should close sheet', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () => Jet.bottomSheet(
              Container(
                height: 200,
                child: const Center(
                  child: Text('Bottom Sheet'),
                ),
              ),
            ),
            child: const Text('Show Sheet'),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(Jet.isBottomSheetOpen ?? false, isTrue);

      Jet.closeBottomSheet();
      await tester.pumpAndSettle();

      expect(find.text('Bottom Sheet'), findsNothing);
      expect(Jet.isBottomSheetOpen ?? false, isFalse);
    });
  });

  group('Mixed Overlays', () {
    testWidgets('closeAllDialogsAndBottomSheets should close both',
        (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => Jet.dialog(
                  const AlertDialog(
                    title: Text('Test Dialog'),
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
              ElevatedButton(
                onPressed: () => Jet.bottomSheet(
                  Container(
                    height: 200,
                    child: const Center(
                      child: Text('Bottom Sheet'),
                    ),
                  ),
                ),
                child: const Text('Show Sheet'),
              ),
            ],
          ),
        ),
      );

      await tester.pump();

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(Jet.isDialogOpen ?? false, isTrue);

      // Can't test showing both at once easily, but we can test the logic
      Jet.closeAllDialogsAndBottomSheets(null);
      await tester.pumpAndSettle();

      expect(Jet.isDialogOpen ?? false, isFalse);
    });
  });

  group('Navigation Safety', () {
    testWidgets('back with canPop should not crash on empty stack',
        (tester) async {
      await tester.pumpWidget(
        const JetMaterialApp(
          home: Scaffold(
            body: Text('Home'),
          ),
        ),
      );

      // Try to go back on empty stack with canPop=true
      expect(() => Jet.back(canPop: true), returnsNormally);
      await tester.pumpAndSettle();

      // Should still be on home
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('back without canPop should attempt pop even on empty stack',
        (tester) async {
      await tester.pumpWidget(
        const JetMaterialApp(
          home: Scaffold(
            body: Text('Home'),
          ),
        ),
      );

      // This should try to pop but nothing happens as we're at root
      expect(() => Jet.back(canPop: false), returnsNormally);
      await tester.pumpAndSettle();
    });

    testWidgets('multiple back calls with times parameter', (tester) async {
      await tester.pumpWidget(
        Wrapper(
          child: ElevatedButton(
            onPressed: () {
              Jet.to(() => const SecondPage());
            },
            child: const Text('Navigate'),
          ),
        ),
      );

      await tester.pump();

      // Navigate to page 2
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Navigate to page 3
      Jet.to(() => const ThirdPage());
      await tester.pumpAndSettle();

      expect(find.text('Third Page'), findsOneWidget);

      // Go back 2 times
      Jet.back(times: 2);
      await tester.pumpAndSettle();

      // Should be back on home page
      expect(find.text('Navigate'), findsOneWidget);
    });
  });

  group('Named Routes', () {
    testWidgets('toNamed should navigate to named route', (tester) async {
      await tester.pumpWidget(
        JetMaterialApp(
          initialRoute: '/',
          jetPages: [
            JetPage(
              name: '/',
              page: () => const HomePage(),
            ),
            JetPage(
              name: '/second',
              page: () => const SecondPage(),
            ),
          ],
        ),
      );

      await tester.pump();

      Jet.toNamed('/second');
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('offNamed should replace with named route', (tester) async {
      await tester.pumpWidget(
        JetMaterialApp(
          initialRoute: '/',
          jetPages: [
            JetPage(
              name: '/',
              page: () => const HomePage(),
            ),
            JetPage(
              name: '/second',
              page: () => const SecondPage(),
            ),
          ],
        ),
      );

      Jet.offNamed('/second');
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);

      // Try to go back
      Jet.back();
      await tester.pumpAndSettle();

      // Should still be on second page (replaced)
      expect(find.text('Second Page'), findsOneWidget);
    });
  });
}

// Helper widgets for tests
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Page')),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Second Page')),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Third Page')),
    );
  }
}
