# jetx_builder

`build_runner` aggregator for [JetX](../..). Scans every
`@JetRoute(...)`-annotated widget under `lib/` and emits a single
`<host>.g.dart` containing every typed `<Page>Route` plus an
aggregated `JetPage` table — modeled after `auto_route`'s
`@AutoRouterConfig` pattern.

## Setup

`pubspec.yaml`:

```yaml
dependencies:
  jetx: ^1.0.0-dev.1

dev_dependencies:
  build_runner: ^2.4.0
  jetx_builder:
    path: ../path/to/jetx_builder   # use git/path until published
```

## Usage

### 1. Annotate page widgets

Each page declares its own metadata next to its widget definition. No
`part` directive, no per-page `.g.dart`.

```dart
// lib/pages/products_page.dart
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

class ProductDetailBinding extends BindingsInterface<List<Bind>> {
  @override
  List<Bind> dependencies() => [
        Bind.lazyPut<ProductDetailController>(() => ProductDetailController()),
      ];
}

@JetRoute(
  path: '/products/:id',
  bindings: [ProductDetailBinding],
  transition: Transition.rightToLeft,
)
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.id, this.tab});
  final String id;
  final String? tab;

  @override
  Widget build(BuildContext context) {
    final controller = Jet.find<ProductDetailController>();
    // ...
  }
}
```

### 2. Declare the host

A single host class with `@JetXRouter()` triggers package-wide
aggregation. Imports anchor the pages so the analyzer (and
`jetx_builder`) discovers them.

```dart
// lib/routes/app_router.dart
import 'package:jetx/jetx.dart';

// ignore: unused_import
import '../pages/login_page.dart';
// ignore: unused_import
import '../pages/home_page.dart';
// ignore: unused_import
import '../pages/products_page.dart';

part 'app_router.g.dart';

@JetXRouter()
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
```

### 3. Run codegen

```sh
dart run build_runner build --delete-conflicting-outputs
```

### 4. Wire up + navigate

```dart
JetMaterialApp(
  initialRoute: const LoginPageRoute().location,
  getPages: AppRouter.pages,
);

// Navigation — typed, no string literals:
Jet.go(ProductDetailPageRoute(id: '101', tab: 'specs'));
Jet.goReplacement(const HomePageRoute());
Jet.goAll(const LoginPageRoute());
```

## What the generator emits

For each `@JetRoute`-annotated widget the generator produces:

- `class <ClassName>Route extends JetRouteData` — typed-navigation
  class with constructor params mirroring the page widget's.
- An entry in `_$<HostName>Pages` — a `JetPage` registration
  pre-wired with the page's `path`, `transition`, `bindings`,
  `middlewares`, and `fullscreenDialog` declared on the annotation.

Page constructor params auto-extract from `Jet.parameters` at push
time. Supported types in v1: `String`, `String?`, `int`, `int?`,
`double`, `double?`, `bool`, `bool?`. Unsupported types fail the build
with a clear error.

Bindings flow through to JetX's existing route lifecycle: instantiated
on push, disposed on pop via `RouterReportManager`.
