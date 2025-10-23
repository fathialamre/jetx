# JetX Generator

Code generator for JetX routes. Automatically generates type-safe route classes from `@JetPageRoute` annotations.

## Features

- 🎯 Type-safe route navigation
- 🚀 Auto-generated route classes with helper methods
- 📝 Support for route parameters (primitives and complex types)
- 🔄 Automatic parameter extraction from `Jet.parameters` and `Jet.arguments`
- 📦 Built-in navigation methods (push, replace, off, offAll, etc.)

## Installation

Add these packages to your `pubspec.yaml`:

```yaml
dependencies:
  jetx_annotations: ^0.0.1

dev_dependencies:
  build_runner: ^2.4.0
  jetx_generator: ^0.0.1
```

## Quick Start

### 1. Create a Router Class

Create a router class and annotate it with `@JetRouteConfig`:

```dart
import 'package:jet/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

part 'router.g.dart';

@JetRouteConfig(generateForDir: ['lib'])
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
```

### 2. Annotate Your Pages

Add `@RoutablePage` to your page widgets:

```dart
import 'package:flutter/material.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

@RoutablePage(path: '/home')
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome!')),
    );
  }
}
```

### 3. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or use watch mode for automatic regeneration:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Use Generated Routes

The generator creates a route class for each annotated page:

```dart
// Navigate using generated route
HomePageRoute.push();

// Or use other navigation methods
HomePageRoute.replace();
HomePageRoute.off();
HomePageRoute.offAll();
```

### 5. Use the Router in Your App

```dart
import 'package:flutter/material.dart';
import 'package:jet/jet.dart';
import 'router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'My App',
      initialRoute: '/home',
      jetPages: AppRouter.pages,
    );
  }
}
```

## Advanced Usage

### Route Parameters

#### Primitive Parameters (URL Params)

Primitive types (String, int, double, bool) are automatically passed as URL parameters:

```dart
@RoutablePage(path: '/profile')
class ProfilePage extends StatelessWidget {
  final String userId;
  final int? age;
  
  const ProfilePage({
    super.key,
    required this.userId,
    this.age,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile: $userId')),
      body: Text('Age: $age'),
    );
  }
}

// Navigate with parameters
ProfilePageRoute.push(userId: '123', age: 25);
```

#### Complex Arguments

Complex types are passed via `Jet.arguments`:

```dart
@RoutablePage(path: '/order')
class OrderPage extends StatelessWidget {
  final Order order;
  
  const OrderPage({super.key, required this.order});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.id}')),
      body: Text('Total: \$${order.total}'),
    );
  }
}

// Navigate with complex argument
final order = Order(id: '456', total: 99.99);
OrderPageRoute.push(order: order);
```

#### Manual Parameter Type Control

Use `@JetParams()` or `@JetArgs()` to override automatic type detection:

```dart
@RoutablePage(path: '/details')
class DetailsPage extends StatelessWidget {
  final String title;        // Auto-detected as URL param
  final Map<String, dynamic> data;  // Auto-detected as argument
  
  const DetailsPage({
    super.key,
    @JetParams() required this.title,  // Explicit URL param
    @JetArgs() required this.data,     // Explicit argument
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Text('Data: $data'),
    );
  }
}
```

### Custom Path Generation

If you don't specify a path, it's auto-generated from the class name:

```dart
// Auto-generates path: /user-profile
@RoutablePage()
class UserProfilePage extends StatelessWidget { ... }

// Custom path
@RoutablePage(path: '/profile')
class UserProfilePage extends StatelessWidget { ... }
```

### Generated Navigation Methods

Each route class includes these helper methods:

- `push<T>()` - Push route onto stack
- `replace<T>()` - Replace current route
- `off<T>()` - Remove current and push
- `offAll<T>()` - Clear stack and push
- `toNamed<T>()` - Navigate using named route
- `offNamed<T>()` - Replace using named route
- `offAllNamed<T>()` - Clear and navigate using named route
- `page()` - Create widget instance
- `jetPage()` - Create JetPage configuration

## Configuration

### Router Configuration

```dart
@JetRouteConfig(
  generateForDir: ['lib', 'lib/features'],  // Scan specific directories
)
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
```

## Example

See the `/example` directory for a complete working example.

## Troubleshooting

### Build Errors

If you encounter build errors:

1. Clean the build cache:
   ```bash
   dart run build_runner clean
   ```

2. Rebuild:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Missing Part Directive

Make sure your router file includes the part directive:

```dart
part 'router.g.dart';  // Must match your file name
```

### Import Errors

Ensure all necessary imports are present:

```dart
import 'package:jet/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
```

## License

MIT License - see LICENSE file for details.
