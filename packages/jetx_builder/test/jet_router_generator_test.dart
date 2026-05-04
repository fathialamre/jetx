import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:jetx_builder/builder.dart';
import 'package:test/test.dart';

void main() {
  group('JetXRouterGenerator (aggregator)', () {
    test('emits typed Routes + pages list for every @JetRoute widget',
        () async {
      await testBuilder(
        jetxBuilder(BuilderOptions.empty),
        {
          'a|lib/pages/login_page.dart': r'''
import 'package:flutter/widgets.dart';
import 'package:jetx/jetx.dart';

@JetRoute(path: '/login')
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''',
          'a|lib/pages/products_page.dart': r'''
import 'package:flutter/widgets.dart';
import 'package:jetx/jetx.dart';

@JetRoute(path: '/products/:id', transition: Transition.fadeIn)
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.id, this.tab});
  final String id;
  final String? tab;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''',
          'a|lib/app_router.dart': r'''
import 'package:jetx/jetx.dart';

import 'pages/login_page.dart';
import 'pages/products_page.dart';

part 'app_router.g.dart';

@JetXRouter()
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
''',
        },
        outputs: {
          'a|lib/app_router.g.dart': decodedMatches(allOf([
            // Both typed routes generated.
            contains('class LoginPageRoute extends JetRouteData'),
            contains('class ProductDetailPageRoute extends JetRouteData'),
            // Aggregated pages list.
            contains(r'final List<JetPage> _$AppRouterPages'),
            contains("name: '/login'"),
            contains("name: '/products/:id'"),
            contains('LoginPage()'),
            contains('ProductDetailPage('),
            contains("Jet.parameters['id']"),
            contains('transition: Transition.fadeIn'),
          ])),
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('forwards bindings + middlewares + fullscreenDialog from annotation',
        () async {
      await testBuilder(
        jetxBuilder(BuilderOptions.empty),
        {
          'a|lib/pages/foo_page.dart': r'''
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
  fullscreenDialog: true,
)
class FooPage extends StatelessWidget {
  const FooPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''',
          'a|lib/router.dart': r'''
import 'package:jetx/jetx.dart';

import 'pages/foo_page.dart';

part 'router.g.dart';

@JetXRouter()
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
''',
        },
        outputs: {
          'a|lib/router.g.dart': decodedMatches(allOf([
            contains('bindings: [FooBinding()]'),
            contains('middlewares: [BarMiddleware()]'),
            contains('fullscreenDialog: true'),
          ])),
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('rejects @JetRoute on non-widget class under aggregator', () async {
      Object? caught;
      try {
        await testBuilder(
          jetxBuilder(BuilderOptions.empty),
          {
            'a|lib/spec.dart': r'''
import 'package:jetx/jetx.dart';

@JetRoute(path: '/x')
class XSpec extends JetRouteData with _$XSpec {
  const XSpec();
}
''',
            'a|lib/router.dart': r'''
import 'package:jetx/jetx.dart';

import 'spec.dart';

part 'router.g.dart';

@JetXRouter()
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
''',
          },
          reader: await PackageAssetReader.currentIsolate(),
          onLog: (_) {},
        );
      } catch (e) {
        caught = e;
      }
      expect(caught, isNotNull);
      expect(caught.toString(), contains('only supports widget'));
    });
  });
}
