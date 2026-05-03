import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

import 'utils/wrapper.dart';

void main() {
  group('Config classes — value semantics', () {
    test('JetSnackbarConfig.copyWith preserves untouched fields', () {
      const base = JetSnackbarConfig(
        title: 'A',
        message: 'B',
        duration: Duration(seconds: 7),
      );
      final next = base.copyWith(title: 'C');
      expect(next.title, 'C');
      expect(next.message, 'B');
      expect(next.duration, const Duration(seconds: 7));
    });

    test('JetDialogConfig.copyWith preserves untouched fields', () {
      const base = JetDialogConfig(
        content: SizedBox(),
        useSafeArea: false,
      );
      final next =
          base.copyWith(transitionDuration: const Duration(milliseconds: 50));
      expect(next.useSafeArea, isFalse);
      expect(next.transitionDuration, const Duration(milliseconds: 50));
    });

    test('JetBottomSheetConfig.copyWith preserves untouched fields', () {
      const base = JetBottomSheetConfig(
        bottomsheet: SizedBox(),
        isScrollControlled: true,
      );
      final next = base.copyWith(persistent: false);
      expect(next.isScrollControlled, isTrue);
      expect(next.persistent, isFalse);
    });
  });

  group('Config-driven entry points dispatch through legacy core', () {
    testWidgets('snackbarFromConfig opens a snackbar', (tester) async {
      await tester.pumpWidget(Wrapper(child: const Text('home')));
      await tester.pumpAndSettle();

      Jet.snackbarFromConfig(const JetSnackbarConfig(
        title: 'Saved',
        message: 'OK',
        duration: Duration(seconds: 30),
      ));
      await tester.pump(const Duration(milliseconds: 50));

      expect(Jet.isSnackbarOpen, isTrue);
      Jet.closeAllSnackbars();
      await tester.pumpAndSettle();
    });

    testWidgets('dialogFromConfig opens a dialog', (tester) async {
      await tester.pumpWidget(Wrapper(child: const Text('home')));
      await tester.pumpAndSettle();

      Jet.dialogFromConfig(const JetDialogConfig(
        content: Material(child: Center(child: Text('cfg-dialog'))),
      ));
      await tester.pumpAndSettle();

      expect(Jet.isDialogOpen, isTrue);
      expect(find.text('cfg-dialog'), findsOneWidget);
      Jet.closeAllDialogs();
      await tester.pumpAndSettle();
    });

    testWidgets('bottomSheetFromConfig opens a bottom sheet', (tester) async {
      await tester.pumpWidget(Wrapper(child: const Text('home')));
      await tester.pumpAndSettle();

      Jet.bottomSheetFromConfig(const JetBottomSheetConfig(
        bottomsheet:
            Material(child: SizedBox(height: 200, child: Text('cfg-sheet'))),
      ));
      await tester.pumpAndSettle();

      expect(Jet.isBottomSheetOpen, isTrue);
      expect(find.text('cfg-sheet'), findsOneWidget);
      Jet.backLegacy();
      await tester.pumpAndSettle();
    });
  });
}
