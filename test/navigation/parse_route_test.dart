import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

void main() {
  test('Parse Page with children', () {
    final testParams = {'hi': 'value'};
    final pageTree = JetPage(
      name: '/city',
      page: () => Container(),
      children: [
        JetPage(
          name: '/home',
          page: () => Container(),
          transition: Transition.rightToLeftWithFade,
          children: [
            JetPage(
              name: '/bed-room',
              transition: Transition.size,
              page: () => Container(),
            ),
            JetPage(
              name: '/living-room',
              transition: Transition.topLevel,
              page: () => Container(),
            ),
          ],
        ),
        JetPage(
          name: '/work',
          transition: Transition.upToDown,
          page: () => Container(),
          children: [
            JetPage(
              name: '/office',
              transition: Transition.zoom,
              page: () => Container(),
              children: [
                JetPage(
                  name: '/pen',
                  transition: Transition.cupertino,
                  page: () => Container(),
                  parameters: testParams,
                ),
                JetPage(
                  name: '/paper',
                  page: () => Container(),
                  transition: Transition.downToUp,
                ),
              ],
            ),
            JetPage(
              name: '/meeting-room',
              transition: Transition.fade,
              page: () => Container(),
            ),
          ],
        ),
      ],
    );

    final tree = ParseRouteTree(routes: <JetPage>[]);

    tree.addRoute(pageTree);

    // tree.addRoute(pageTree);
    const searchRoute = '/city/work/office/pen';
    final match = tree.matchRoute(searchRoute);
    expect(match, isNotNull);
    expect(match.route!.name, searchRoute);
    final testRouteParam = match.route!.parameters!;
    for (final tParam in testParams.entries) {
      expect(testRouteParam[tParam.key], tParam.value);
    }
  });

  test('Parse Page without children', () {
    final pageTree = [
      JetPage(
          name: '/city',
          page: () => Container(),
          transition: Transition.cupertino),
      JetPage(
          name: '/city/home',
          page: () => Container(),
          transition: Transition.downToUp),
      JetPage(
          name: '/city/home/bed-room',
          page: () => Container(),
          transition: Transition.fade),
      JetPage(
          name: '/city/home/living-room',
          page: () => Container(),
          transition: Transition.fadeIn),
      JetPage(
          name: '/city/work',
          page: () => Container(),
          transition: Transition.leftToRight),
      JetPage(
          name: '/city/work/office',
          page: () => Container(),
          transition: Transition.leftToRightWithFade),
      JetPage(
          name: '/city/work/office/pen',
          page: () => Container(),
          transition: Transition.native),
      JetPage(
          name: '/city/work/office/paper',
          page: () => Container(),
          transition: Transition.noTransition),
      JetPage(
          name: '/city/work/meeting-room',
          page: () => Container(),
          transition: Transition.rightToLeft),
    ];

    final tree = ParseRouteTree(routes: pageTree);

    // for (var p in pageTree) {
    //   tree.addRoute(p);
    // }

    const searchRoute = '/city/work/office/pen';
    final match = tree.matchRoute(searchRoute);
    expect(match, isNotNull);
    expect(match.route!.name, searchRoute);
  });

  testWidgets(
    'test params from dynamic route',
    (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/first/juan',
        jetPages: [
          JetPage(page: () => Container(), name: '/first/:name'),
          JetPage(page: () => Container(), name: '/second/:id'),
          JetPage(page: () => Container(), name: '/third'),
          JetPage(page: () => Container(), name: '/last/:id/:name/profile'),
          JetPage(page: () => Container(), name: '/first/second/:token')
        ],
      ));

      expect(Jet.parameters['name'], 'juan');

      Jet.toNamed('/second/1234');

      await tester.pumpAndSettle();

      expect(Jet.parameters['id'], '1234');

      Jet.toNamed('/third?name=jonny&job=dev');

      await tester.pumpAndSettle();

      expect(Jet.parameters['name'], 'jonny');
      expect(Jet.parameters['job'], 'dev');

      Jet.toNamed('/last/1234/ana/profile');

      await tester.pumpAndSettle();

      expect(Jet.parameters['id'], '1234');
      expect(Jet.parameters['name'], 'ana');

      Jet.toNamed('/last/1234/ana/profile?job=dev');

      await tester.pumpAndSettle();

      expect(Jet.parameters['id'], '1234');
      expect(Jet.parameters['name'], 'ana');
      expect(Jet.parameters['job'], 'dev');

      Jet.toNamed(
        'https://www.example.com/first/second/fa9662f4-ec3f-11ee-a806-169a3915b383',
      );
      await tester.pumpAndSettle();
      expect(Jet.parameters['token'], 'fa9662f4-ec3f-11ee-a806-169a3915b383');
    },
  );

  testWidgets(
    'params in url by parameters',
    (tester) async {
      await tester.pumpWidget(JetMaterialApp(
        initialRoute: '/first/juan',
        jetPages: [
          JetPage(page: () => Container(), name: '/first/:name'),
          JetPage(page: () => Container(), name: '/italy'),
        ],
      ));

      // Jet.parameters = ({"varginias": "varginia", "vinis": "viniiss"});
      var parameters = <String, String>{
        "varginias": "varginia",
        "vinis": "viniiss"
      };
      // print("Jet.parameters: ${Jet.parameters}");
      parameters.addAll({"a": "b", "c": "d"});
      Jet.toNamed("/italy", parameters: parameters);

      await tester.pumpAndSettle();
      expect(Jet.parameters['varginias'], 'varginia');
      expect(Jet.parameters['vinis'], 'viniiss');
      expect(Jet.parameters['a'], 'b');
      expect(Jet.parameters['c'], 'd');
    },
  );
}
