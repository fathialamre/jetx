import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

import 'utils/wrapper.dart';

class _SheetBody extends StatelessWidget {
  const _SheetBody({this.label = 'sheet'});
  final String label;
  @override
  Widget build(BuildContext context) => Material(
        child: SizedBox(
          height: 200,
          child: Center(child: Text(label)),
        ),
      );
}

void main() {
  tearDown(() => Jet.reset());

  testWidgets(
      'bottomSheet future resolves with value passed to Jet.backLegacy',
      (tester) async {
    await tester.pumpWidget(Wrapper(child: const Text('home')));
    await tester.pumpAndSettle();

    final future = Jet.bottomSheet<String>(const _SheetBody());
    await tester.pumpAndSettle();
    expect(Jet.isBottomSheetOpen, isTrue);

    // Overlays sit above the page stack and must be popped via the
    // navigator key, not through Jet.back which targets _activePages and
    // asserts canBack.
    Jet.backLegacy<String>(result: 'picked');
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, 'picked');
    expect(Jet.isBottomSheetOpen, isFalse);
  });

  testWidgets(
      'bottomSheet future resolves with null when popped without a result',
      (tester) async {
    await tester.pumpWidget(Wrapper(child: const Text('home')));
    await tester.pumpAndSettle();

    final future = Jet.bottomSheet<String>(const _SheetBody());
    await tester.pumpAndSettle();
    expect(Jet.isBottomSheetOpen, isTrue);

    Jet.backLegacy();
    await tester.pumpAndSettle();

    expect(await future, isNull);
  });

  testWidgets('barrier tap dismisses sheet when isDismissible is true',
      (tester) async {
    await tester.pumpWidget(Wrapper(child: const Text('home')));
    await tester.pumpAndSettle();

    final future = Jet.bottomSheet<String>(const _SheetBody(),
        isDismissible: true);
    await tester.pumpAndSettle();
    expect(Jet.isBottomSheetOpen, isTrue);

    // Tap above the sheet (sheet is 200px tall, anchored bottom).
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(Jet.isBottomSheetOpen, isFalse);
    expect(await future, isNull);
  });

  testWidgets(
      'isDismissible:false ignores barrier taps; sheet stays open',
      (tester) async {
    await tester.pumpWidget(Wrapper(child: const Text('home')));
    await tester.pumpAndSettle();

    Jet.bottomSheet<String>(const _SheetBody(), isDismissible: false);
    await tester.pumpAndSettle();
    expect(Jet.isBottomSheetOpen, isTrue);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(Jet.isBottomSheetOpen, isTrue,
        reason: 'isDismissible:false must block barrier-tap dismissal');

    // Clean up so the test exits.
    Jet.backLegacy();
    await tester.pumpAndSettle();
  });

  testWidgets(
      'sequential bottomSheet calls: closing the first allows opening the second',
      (tester) async {
    await tester.pumpWidget(Wrapper(child: const Text('home')));
    await tester.pumpAndSettle();

    Jet.bottomSheet(const _SheetBody(label: 'first'));
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);

    Jet.backLegacy();
    await tester.pumpAndSettle();
    expect(Jet.isBottomSheetOpen, isFalse);

    Jet.bottomSheet(const _SheetBody(label: 'second'));
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    expect(Jet.isBottomSheetOpen, isTrue);

    Jet.backLegacy();
    await tester.pumpAndSettle();
  });
}
