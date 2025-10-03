import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jet/jet.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Jet.bottomSheet smoke test", (tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Jet.bottomSheet(Wrap(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.music_note),
          title: const Text('Music'),
          onTap: () {},
        ),
      ],
    ));

    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.music_note), findsOneWidget);
  });

  testWidgets("Jet.bottomSheet close test", (tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    await tester.pump();

    Jet.bottomSheet(Wrap(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.music_note),
          title: const Text('Music'),
          onTap: () {},
        ),
      ],
    ));

    await tester.pumpAndSettle();

    expect(Jet.isBottomSheetOpen, true);

    Jet.backLegacy();
    await tester.pumpAndSettle();

    expect(Jet.isBottomSheetOpen, false);

    // expect(() => Jet.bottomSheet(Container(), isScrollControlled: null),
    //     throwsAssertionError);

    // expect(() => Jet.bottomSheet(Container(), isDismissible: null),
    //     throwsAssertionError);

    // expect(() => Jet.bottomSheet(Container(), enableDrag: null),
    //     throwsAssertionError);

    await tester.pumpAndSettle();
  });

  // testWidgets(
  //   "JetMaterialApp with debugShowMaterialGrid null",
  //   (tester) async {
  //     expect(
  //       () => JetMaterialApp(
  //         debugShowMaterialGrid: null,
  //       ),
  //       throwsAssertionError,
  //     );
  //   },
  // );
}
