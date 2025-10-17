import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

void main() {
  testWidgets("test if Jet.isSnackbarOpen works with Jet.snackbar",
      (tester) async {
    await tester.pumpWidget(
      JetMaterialApp(
        popGesture: true,
        home: ElevatedButton(
          child: const Text('Open Snackbar'),
          onPressed: () {
            Jet.snackbar(
              'title',
              "message",
              duration: const Duration(seconds: 1),
              mainButton:
                  TextButton(onPressed: () {}, child: const Text('button')),
              isDismissible: false,
            );
          },
        ),
      ),
    );

    await tester.pump();

    expect(Jet.isSnackbarOpen, false);
    await tester.tap(find.text('Open Snackbar'));

    expect(Jet.isSnackbarOpen, true);
    await tester.pump(const Duration(seconds: 1));
    expect(Jet.isSnackbarOpen, false);
  });

  testWidgets("Jet.rawSnackbar test", (tester) async {
    await tester.pumpWidget(
      JetMaterialApp(
        popGesture: true,
        home: ElevatedButton(
          child: const Text('Open Snackbar'),
          onPressed: () {
            Jet.rawSnackbar(
              title: 'title',
              message: "message",
              onTap: (_) {},
              shouldIconPulse: true,
              icon: const Icon(Icons.alarm),
              showProgressIndicator: true,
              duration: const Duration(seconds: 1),
              isDismissible: true,
              leftBarIndicatorColor: Colors.amber,
              overlayBlur: 1.0,
            );
          },
        ),
      ),
    );

    await tester.pump();

    expect(Jet.isSnackbarOpen, false);
    await tester.tap(
      find.text('Open Snackbar'),
    );

    expect(Jet.isSnackbarOpen, true);
    await tester.pump(const Duration(seconds: 1));
    expect(Jet.isSnackbarOpen, false);
  });

  testWidgets("test snackbar queue", (tester) async {
    const messageOne = Text('title');

    const messageTwo = Text('titleTwo');

    await tester.pumpWidget(
      JetMaterialApp(
        popGesture: true,
        home: ElevatedButton(
          child: const Text('Open Snackbar'),
          onPressed: () {
            Jet.rawSnackbar(
                messageText: messageOne, duration: const Duration(seconds: 1));
            Jet.rawSnackbar(
                messageText: messageTwo, duration: const Duration(seconds: 1));
          },
        ),
      ),
    );

    await tester.pump();

    expect(Jet.isSnackbarOpen, false);
    await tester.tap(find.text('Open Snackbar'));
    expect(Jet.isSnackbarOpen, true);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('title'), findsOneWidget);
    expect(find.text('titleTwo'), findsNothing);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('title'), findsNothing);
    expect(find.text('titleTwo'), findsOneWidget);
    Jet.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets("test snackbar dismissible", (tester) async {
    const dismissDirection = DismissDirection.down;
    const snackBarTapTarget = Key('snackbar-tap-target');

    const JetSnackBar getBar = JetSnackBar(
      key: ValueKey('dismissible'),
      message: 'bar1',
      duration: Duration(seconds: 2),
      isDismissible: true,
      snackPosition: SnackPosition.bottom,
      dismissDirection: dismissDirection,
    );

    await tester.pumpWidget(JetMaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                GestureDetector(
                  key: snackBarTapTarget,
                  onTap: () {
                    Jet.showSnackbar(getBar);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    height: 100.0,
                    width: 100.0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ));

    await tester.pump();

    expect(Jet.isSnackbarOpen, false);
    expect(find.text('bar1'), findsNothing);

    await tester.tap(find.byKey(snackBarTapTarget));
    await tester.pumpAndSettle();

    expect(Jet.isSnackbarOpen, true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byWidget(getBar), findsOneWidget);
    await tester.ensureVisible(find.byWidget(getBar));
    await tester.drag(find.byType(Dismissible), const Offset(0.0, 50.0));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(Jet.isSnackbarOpen, false);
  });

  testWidgets("test snackbar onTap", (tester) async {
    const dismissDirection = DismissDirection.vertical;
    const snackBarTapTarget = Key('snackbar-tap-target');
    var counter = 0;

    late final JetSnackBar getBar;

    late final SnackbarController getBarController;

    await tester.pumpWidget(JetMaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Column(
              children: <Widget>[
                GestureDetector(
                  key: snackBarTapTarget,
                  onTap: () {
                    getBar = JetSnackBar(
                      message: 'bar1',
                      onTap: (_) {
                        counter++;
                      },
                      duration: const Duration(seconds: 2),
                      isDismissible: true,
                      dismissDirection: dismissDirection,
                    );
                    getBarController = Jet.showSnackbar(getBar);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    height: 100.0,
                    width: 100.0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ));

    await tester.pumpAndSettle();

    expect(Jet.isSnackbarOpen, false);
    expect(find.text('bar1'), findsNothing);

    await tester.tap(find.byKey(snackBarTapTarget));
    await tester.pumpAndSettle();

    expect(Jet.isSnackbarOpen, true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byWidget(getBar), findsOneWidget);
    await tester.ensureVisible(find.byWidget(getBar));
    await tester.tap(find.byWidget(getBar));
    expect(counter, 1);
    await tester.pump(const Duration(milliseconds: 3000));
    await getBarController.close(withAnimations: false);
  });

  testWidgets("Get test actions and icon", (tester) async {
    const icon = Icon(Icons.alarm);
    final action = TextButton(onPressed: () {}, child: const Text('button'));

    late final JetSnackBar getBar;

    await tester.pumpWidget(const JetMaterialApp(home: Scaffold()));

    await tester.pump();

    expect(Jet.isSnackbarOpen, false);
    expect(find.text('bar1'), findsNothing);

    getBar = JetSnackBar(
      message: 'bar1',
      icon: icon,
      mainButton: action,
      leftBarIndicatorColor: Colors.yellow,
      showProgressIndicator: true,
      // maxWidth: 100,
      borderColor: Colors.red,
      duration: const Duration(seconds: 1),
      isDismissible: false,
    );
    Jet.showSnackbar(getBar);

    expect(Jet.isSnackbarOpen, true);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byWidget(getBar), findsOneWidget);
    expect(find.byWidget(icon), findsOneWidget);
    expect(find.byWidget(action), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));

    expect(Jet.isSnackbarOpen, false);
  });
}
