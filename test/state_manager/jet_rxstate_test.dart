import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

void main() {
  Jet.lazyPut<Controller2>(() => Controller2());
  testWidgets("JetxController smoke test", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JetX<Controller>(
          init: Controller(),
          builder: (controller) {
            return Column(
              children: [
                Text(
                  'Count: ${controller.counter.value}',
                ),
                Text(
                  'Double: ${controller.doubleNum.value}',
                ),
                Text(
                  'String: ${controller.string.value}',
                ),
                Text(
                  'List: ${controller.list.length}',
                ),
                Text(
                  'Bool: ${controller.boolean.value}',
                ),
                Text(
                  'Map: ${controller.map.length}',
                ),
                TextButton(
                  child: const Text("increment"),
                  onPressed: () => controller.increment(),
                ),
                JetX<Controller2>(builder: (controller) {
                  return Text('lazy ${controller.lazy.value}');
                }),
                JetX<ControllerNonGlobal>(
                    init: ControllerNonGlobal(),
                    global: false,
                    builder: (controller) {
                      return Text('single ${controller.nonGlobal.value}');
                    })
              ],
            );
          },
        ),
      ),
    );

    expect(find.text("Count: 0"), findsOneWidget);
    expect(find.text("Double: 0.0"), findsOneWidget);
    expect(find.text("String: string"), findsOneWidget);
    expect(find.text("Bool: true"), findsOneWidget);
    expect(find.text("List: 0"), findsOneWidget);
    expect(find.text("Map: 0"), findsOneWidget);

    Controller.to.increment();

    await tester.pump();

    expect(find.text("Count: 1"), findsOneWidget);

    await tester.tap(find.text('increment'));

    await tester.pump();

    expect(find.text("Count: 2"), findsOneWidget);
    expect(find.text("lazy 0"), findsOneWidget);
    expect(find.text("single 0"), findsOneWidget);
  });
}

class Controller2 extends JetxController {
  RxInt lazy = 0.obs;
}

class ControllerNonGlobal extends JetxController {
  RxInt nonGlobal = 0.obs;
}

class Controller extends JetxController {
  static Controller get to => Jet.find();

  RxInt counter = 0.obs;
  RxDouble doubleNum = 0.0.obs;
  RxString string = "string".obs;
  RxList list = [].obs;
  RxMap map = {}.obs;
  RxBool boolean = true.obs;

  void increment() {
    counter.value++;
  }
}
