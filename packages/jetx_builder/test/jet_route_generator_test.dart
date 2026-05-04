import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jetx_builder/builder.dart';
import 'package:test/test.dart';

void main() {
  group('JetRouteGenerator', () {
    test('emits a mixin with location getter for path-only route', () async {
      await testBuilder(
        jetxBuilder(BuilderOptions.empty),
        {
          'a|lib/routes.dart': r'''
import 'package:jetx/jetx.dart';

@JetRoute(path: '/user/:id')
class UserRoute extends JetRouteData with _$UserRoute {
  const UserRoute({required this.id});
  @override final int id;
}
''',
        },
        outputs: {
          'a|lib/routes.jetx_builder.g.part': decodedMatches(allOf(
            contains(r'mixin _$UserRoute on JetRouteData'),
            contains('int get id;'),
            contains("Jet.buildUrl("),
            contains("'/user/:id'"),
            contains("'id': id"),
          )),
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('non-path fields become query params', () async {
      await testBuilder(
        jetxBuilder(BuilderOptions.empty),
        {
          'a|lib/routes.dart': r'''
import 'package:jetx/jetx.dart';

@JetRoute(path: '/user/:id')
class UserRoute extends JetRouteData with _$UserRoute {
  const UserRoute({required this.id, this.tab});
  @override final int id;
  @override final String? tab;
}
''',
        },
        outputs: {
          'a|lib/routes.jetx_builder.g.part': decodedMatches(allOf(
            contains("'id': id"),
            contains("'tab': tab"),
          )),
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('throws when :param has no matching field', () async {
      Object? caught;
      try {
        await testBuilder(
          jetxBuilder(BuilderOptions.empty),
          {
            'a|lib/routes.dart': r'''
import 'package:jetx/jetx.dart';

@JetRoute(path: '/user/:id')
class UserRoute extends JetRouteData with _$UserRoute {
  const UserRoute();
}
''',
          },
          reader: await PackageAssetReader.currentIsolate(),
          onLog: (_) {},
        );
      } catch (e) {
        caught = e;
      }
      expect(caught, isNotNull,
          reason: 'generator should reject missing path param fields');
      expect(caught.toString(), contains('Path param ":id"'));
      expect(caught.toString(), contains('UserRoute'));
    });
  });
}
