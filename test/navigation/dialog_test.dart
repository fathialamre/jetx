import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Jet.defaultDialog smoke test", (tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Jet.defaultDialog(
        onConfirm: () {}, middleText: "Dialog made in 3 lines of code");

    await tester.pumpAndSettle();

    expect(find.text("Ok"), findsOneWidget);
  });

  testWidgets("Jet.dialog smoke test", (tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Jet.dialog(const YourDialogWidget());

    await tester.pumpAndSettle();

    expect(find.byType(YourDialogWidget), findsOneWidget);
  });

  group("Get dialog close tests", () {
    /// Set up the test by opening a dialog and checking to ensure state is correct
    Future<void> setUpCloseTest(WidgetTester tester) async {
      await tester.pumpWidget(
        Wrapper(child: Container()),
      );

      await tester.pump();

      Jet.dialog(const YourDialogWidget());
      await tester.pumpAndSettle();

      expect(find.byType(YourDialogWidget), findsOneWidget);
      expect(Jet.isDialogOpen, true);
    }

    /// Tear down the test by checking after closing the dialog
    Future<void> tearDownCloseTest(WidgetTester tester) async {
      await tester.pumpAndSettle();

      expect(find.byType(YourDialogWidget), findsNothing);
      expect(Jet.isDialogOpen, false);
      await tester.pumpAndSettle();
    }

    testWidgets("Get dialog close - with backLegacy", (tester) async {
      await setUpCloseTest(tester);
      // Close using backLegacy
      Jet.backLegacy();
      await tearDownCloseTest(tester);
    });

    testWidgets("Get dialog close - with closeDialog", (tester) async {
      await setUpCloseTest(tester);
      // Close using closeDialog
      Jet.closeDialog();
      await tearDownCloseTest(tester);
    });
  });

  group("Jet.closeDialog", () {
    testWidgets("Jet.closeDialog - closes dialog and returns value",
        (tester) async {
      await tester.pumpWidget(
        Wrapper(child: Container()),
      );

      await tester.pump();

      final result = Jet.dialog(const YourDialogWidget());
      await tester.pumpAndSettle();

      expect(find.byType(YourDialogWidget), findsOneWidget);
      expect(Jet.isDialogOpen, true);

      const dialogResult = "My dialog result";

      Jet.closeDialog(result: dialogResult);
      await tester.pumpAndSettle();

      final returnedResult = await result;
      expect(returnedResult, dialogResult);

      expect(find.byType(YourDialogWidget), findsNothing);
      expect(Jet.isDialogOpen, false);
      await tester.pumpAndSettle();
    });

    testWidgets("Jet.closeDialog - does not close bottomsheets",
        (tester) async {
      await tester.pumpWidget(
        Wrapper(child: Container()),
      );

      await tester.pump();

      Jet.bottomSheet(const YourDialogWidget());
      await tester.pumpAndSettle();

      expect(find.byType(YourDialogWidget), findsOneWidget);
      expect(Jet.isDialogOpen, false);

      Jet.closeDialog();
      await tester.pumpAndSettle();

      expect(find.byType(YourDialogWidget), findsOneWidget);
    });
  });
}

class YourDialogWidget extends StatelessWidget {
  const YourDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
