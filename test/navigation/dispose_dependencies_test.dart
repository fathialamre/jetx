import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

import 'utils/wrapper.dart';

void main() {
  testWidgets("Test dispose dependencies with unnamed routes", (tester) async {
    await tester.pumpWidget(
      Wrapper(child: Container()),
    );

    expect(Jet.isRegistered<Controller2>(), false);
    expect(Jet.isRegistered<Controller>(), false);

    Jet.to(() => const First());

    await tester.pumpAndSettle();

    expect(find.byType(First), findsOneWidget);

    expect(Jet.isRegistered<Controller>(), true);

    Jet.to(() => const Second());

    await tester.pumpAndSettle();

    expect(find.byType(Second), findsOneWidget);

    expect(Jet.isRegistered<Controller>(), true);
    expect(Jet.isRegistered<Controller2>(), true);

    Jet.back();

    await tester.pumpAndSettle();

    expect(find.byType(First), findsOneWidget);

    expect(Jet.isRegistered<Controller>(), true);
    expect(Jet.isRegistered<Controller2>(), false);

    Jet.back();

    await tester.pumpAndSettle();

    expect(Jet.isRegistered<Controller>(), false);
    expect(Jet.isRegistered<Controller2>(), false);
  });
}

class Controller extends JetxController {}

class Controller2 extends JetxController {}

class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) {
    Jet.put(Controller());
    return const Center(
      child: Text("first"),
    );
  }
}

class Second extends StatelessWidget {
  const Second({super.key});

  @override
  Widget build(BuildContext context) {
    Jet.put(Controller2());
    return const Center(
      child: Text("second"),
    );
  }
}
