# JetX Annotations

Annotations for JetX route generation. Use with `jetx_generator` to automatically generate type-safe routes for your Flutter application.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  jetx_annotations: ^0.0.1
```

## Annotations

### `@JetRouteConfig`

Marks the main router class for code generation.

```dart
@JetRouteConfig(generateForDir: ['lib'])
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
```

**Parameters:**
- `generateForDir`: List of directories to scan for routes (default: `['lib']`)

### `@RoutablePage`

Marks page widgets that should generate route classes.

```dart
@RoutablePage(path: '/home')
class HomePage extends StatefulWidget { ... }
```

**Parameters:**
- `path`: Custom route path. If not provided, generates from class name (e.g., `HomePage` → `/home-page`)

### `@JetParams`

Marks constructor parameters as URL parameters (passed via `Jet.parameters`).

Best for primitive types (String, int, double, bool).

```dart
class ProfilePage extends StatelessWidget {
  final String userId;
  
  ProfilePage({@JetParams() required this.userId});
}
```

### `@JetArgs`

Marks constructor parameters as complex arguments (passed via `Jet.arguments`).

Best for complex types (List, Map, custom objects).

```dart
class OrderPage extends StatelessWidget {
  final Order order;
  
  OrderPage({@JetArgs() required this.order});
}
```

## Usage

See `jetx_generator` package for complete usage instructions.

## License

MIT License - see LICENSE file for details.
