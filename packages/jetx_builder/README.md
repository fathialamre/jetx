# jetx_builder

`build_runner` code generator for [JetX](../..). Emits typed
`JetRouteData` mixins from `@JetRoute(path: ...)`-annotated classes,
giving compile-time-safe navigation in place of stringly-typed
`Jet.toNamed('/user/${id}')` calls.

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

Annotate a class that extends `JetRouteData` and mix in the generated
`_$<ClassName>` mixin:

```dart
// routes.dart
import 'package:jetx/jetx.dart';

part 'routes.g.dart';

@JetRoute(path: '/user/:id')
class UserRoute extends JetRouteData with _$UserRoute {
  const UserRoute({required this.id, this.tab});

  @override
  final int id;
  @override
  final String? tab;
}
```

Run `build_runner`:

```sh
dart run build_runner build
```

Then push the typed route from anywhere:

```dart
Jet.go(const UserRoute(id: 42, tab: 'profile'));
```

The generator routes `:id` from the path to the matching field, sends
remaining fields as query parameters, and uses `Jet.buildUrl` so URL
encoding is handled correctly.

## How it works

For each `@JetRoute`-annotated class, the generator emits a mixin like:

```dart
mixin _$UserRoute on JetRouteData {
  int get id;
  String? get tab;

  @override
  String get location => Jet.buildUrl(
        '/user/:id',
        pathParams: <String, Object?>{'id': id},
        queryParams: <String, Object?>{'tab': tab},
      );
}
```

Path param `:name` segments are matched by name against the fields on
the user's class. Mismatches fail at build time with a clear error.
