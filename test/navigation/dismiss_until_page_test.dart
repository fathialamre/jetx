import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

import 'utils/wrapper.dart';

class _DialogBody extends StatelessWidget {
  const _DialogBody();
  @override
  Widget build(BuildContext context) =>
      const Material(child: Center(child: Text('dialog body')));
}

class _SheetBody extends StatelessWidget {
  const _SheetBody();
  @override
  Widget build(BuildContext context) =>
      const Material(child: SizedBox(height: 200, child: Text('sheet body')));
}

void main() {
  tearDown(() => Jet.reset());

  testWidgets('Jet.dismissUntilPage closes snackbar + dialog + sheet, page stays',
      (tester) async {
    await tester.pumpWidget(Wrapper(child: const Text('home')));
    await tester.pumpAndSettle();

    Jet.snackbar('hi', 'there', duration: const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 50));
    expect(Jet.isSnackbarOpen, isTrue);

    Jet.dialog(const _DialogBody());
    await tester.pumpAndSettle();
    expect(Jet.isDialogOpen, isTrue);
    expect(find.text('dialog body'), findsOneWidget);

    Jet.bottomSheet(const _SheetBody());
    await tester.pumpAndSettle();
    expect(Jet.isBottomSheetOpen, isTrue);
    expect(find.text('sheet body'), findsOneWidget);

    Jet.dismissUntilPage();
    await tester.pumpAndSettle();

    expect(Jet.isSnackbarOpen, isFalse);
    expect(Jet.isDialogOpen, isFalse);
    expect(Jet.isBottomSheetOpen, isFalse);
    expect(find.text('home'), findsOneWidget,
        reason: 'page stack must remain intact');
  });

  testWidgets('Jet.dismissUntilPage with only a dialog open closes the dialog',
      (tester) async {
    // Regression for the closeAllDialogsAndBottomSheets `&&` predicate that
    // would not close a dialog opened in isolation.
    await tester.pumpWidget(Wrapper(child: const Text('home')));
    await tester.pumpAndSettle();

    Jet.dialog(const _DialogBody());
    await tester.pumpAndSettle();
    expect(Jet.isDialogOpen, isTrue);

    Jet.dismissUntilPage();
    await tester.pumpAndSettle();

    expect(Jet.isDialogOpen, isFalse);
  });
}
