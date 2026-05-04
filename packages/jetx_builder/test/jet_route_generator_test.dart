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

    test('widget-page form: emits typed Route + JetPage registration',
        () async {
      await testBuilder(
        jetxBuilder(BuilderOptions.empty),
        {
          'a|lib/products_page.dart': r'''
import 'package:flutter/widgets.dart';
import 'package:jetx/jetx.dart';

@JetRoute(path: '/products/:id')
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.id, this.tab});
  final String id;
  final String? tab;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''',
        },
        outputs: {
          'a|lib/products_page.jetx_builder.g.part': decodedMatches(allOf([
            // Typed Route class.
            contains('class ProductDetailPageRoute extends JetRouteData'),
            contains('final String id;'),
            contains('final String? tab;'),
            contains("'/products/:id'"),
            contains("'id': id"),
            contains("'tab': tab"),
            // JetPage registration constant.
            contains('final JetPage productDetailPageJet'),
            contains("name: '/products/:id'"),
            contains('ProductDetailPage('),
            contains("Jet.parameters['id']"),
            contains("Jet.parameters['tab']"),
          ])),
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('widget-page form: forwards bindings + transition + middlewares',
        () async {
      await testBuilder(
        jetxBuilder(BuilderOptions.empty),
        {
          'a|lib/page.dart': r'''
import 'package:flutter/widgets.dart';
import 'package:jetx/jetx.dart';

class FooBinding extends BindingsInterface<List<Bind>> {
  @override
  List<Bind> dependencies() => const <Bind>[];
}

class BarMiddleware extends JetMiddleware {}

@JetRoute(
  path: '/foo',
  bindings: [FooBinding],
  middlewares: [BarMiddleware],
  transition: Transition.fade,
  fullscreenDialog: true,
)
class FooPage extends StatelessWidget {
  const FooPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''',
        },
        outputs: {
          'a|lib/page.jetx_builder.g.part': decodedMatches(allOf(
            contains('bindings: [FooBinding()]'),
            contains('middlewares: [BarMiddleware()]'),
            contains('transition: Transition.fade'),
            contains('fullscreenDialog: true'),
          )),
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('widget-page form: rejects unsupported param types', () async {
      Object? caught;
      try {
        await testBuilder(
          jetxBuilder(BuilderOptions.empty),
          {
            'a|lib/page.dart': r'''
import 'package:flutter/widgets.dart';
import 'package:jetx/jetx.dart';

@JetRoute(path: '/foo')
class FooPage extends StatelessWidget {
  const FooPage({super.key, required this.payload});
  final List<int> payload;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
          reason: 'unsupported types must fail at build time');
      expect(caught.toString(), contains('Unsupported'));
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
