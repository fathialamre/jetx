# JetX Route Generator

Code generator for JetX routes using annotations. Provides type-safe navigation with automatic parameter mapping using a centralized router approach similar to `auto_route`.

## Features

- 🎯 **Type-safe navigation** - Compile-time route parameter checking
- 🚀 **Centralized router** - All routes defined in one place
- 📦 **Parameter mapping** - Automatic conversion of path and query parameters
- 🔗 **Binding support** - Integrate with JetX dependency injection
- 🛡️ **Middleware support** - Add route guards and interceptors
- ✨ **Clean syntax** - Similar to auto_route and go_router_builder

## Setup

### 1. Add dependencies

```yaml
dependencies:
  jetx: ^0.1.0
  jetx_annotations:
    path: packages/jetx_annotations

dev_dependencies:
  jetx_generator:
    path: packages/jetx_generator
  build_runner: ^2.4.0
```

### 2. Annotate your pages

```dart
// pages/user_page.dart
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

@RoutePage(path: '/user/:userId')
class UserPage extends StatelessWidget {
  final int userId;
  
  @QueryParam()
  final String? tab;
  
  const UserPage({
    super.key,
    required this.userId,
    this.tab,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User $userId')),
      body: Text('Tab: $tab'),
    );
  }
}
```

### 3. Create app router

```dart
// app_router.dart
import 'package:jetx/jetx.dart';
import 'pages/home_page.dart';
import 'pages/user_page.dart';

part 'app_router.g.dart';

@JetRouter([
  HomePage,
  UserPage,
])
class AppRouter {}
```

### 4. Run code generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Use generated routes

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';
import 'app_router.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Router Example',
      getPages: getPages,  // Use generated array
    );
  }
}

// Type-safe navigation
const UserPageRoute(userId: 42, tab: 'posts').push();
```

## Annotations

### @RoutePage

Main annotation for marking a page as a route.

```dart
@RoutePage(
  path: '/custom/:id',              // Optional: custom path (default: auto-generated)
  name: 'customRoute',               // Optional: route name
  transition: 'fadeIn',              // Optional: transition type
  transitionDurationMs: 300,         // Optional: transition duration
  fullscreenDialog: false,           // Optional: fullscreen dialog
  maintainState: true,               // Optional: maintain state
  preventDuplicates: true,           // Optional: prevent duplicate routes
)
```

**Path generation:**
- If `path` is null, it's auto-generated from the class name
- `UserPage` → `/user`
- `UserDetailPage` → `/user-detail`
- `HomePage` → `/home`

### @QueryParam

Mark a constructor parameter as a query parameter.

```dart
@QueryParam(name: 'tab', defaultValue: 'home')
final String? tab;
```

### Complex Objects (Auto-Detected as Arguments)

**New in this version**: Complex types like custom classes and `List<T>` are automatically detected and passed as arguments instead of URL parameters.

#### Auto-Detection

Primitive types (`int`, `double`, `bool`, `String`, `num`, `DateTime`) are passed in the URL.
Complex types (custom classes, `List`, `Map`, etc.) are automatically passed as arguments.

```dart
class User {
  final int id;
  final String name;
  final String email;
  User({required this.id, required this.name, required this.email});
}

@RoutePage(path: '/user/:userId')
class UserPage extends StatelessWidget {
  final int userId;           // ✅ In URL (primitive)
  
  @QueryParam()
  final String? tab;          // ✅ In URL as query param (primitive)
  
  final User user;            // ✅ Auto-detected as argument (complex)
  final List<String>? tags;   // ✅ Auto-detected as argument (complex)
  
  const UserPage({
    super.key,
    required this.userId,
    this.tab,
    required this.user,
    this.tags,
  });
}
```

#### Generated Code

The generator creates navigation methods that automatically pass complex objects as arguments:

```dart
// Navigate with both URL params and complex objects
UserPageRoute(
  userId: 42,           // Goes in URL: /user/42?tab=posts
  tab: 'posts',         // Goes in URL
  user: userObject,     // Passed as argument (not in URL)
  tags: ['flutter', 'dart'],  // Passed as argument
).push();

// Generates internally:
Jet.toNamed(
  '/user/42?tab=posts',
  arguments: {
    'user': userObject,
    'tags': ['flutter', 'dart'],
  },
);
```

#### @ArgumentParam (Explicit Override)

Use `@ArgumentParam()` to explicitly mark a parameter as an argument, even if it's a primitive type:

```dart
@RoutePage(path: '/profile')
class ProfilePage extends StatelessWidget {
  @ArgumentParam()
  final String privateToken;  // Forced to be argument (hidden from URL)
  
  const ProfilePage({super.key, required this.privateToken});
}
```

#### Benefits

- **Type Safety**: Pass full objects without serialization
- **Deep Linking**: Only primitive types in URL (shareable URLs)
- **Flexibility**: Complex data like callbacks, models, and collections
- **Automatic**: No extra configuration needed

### @RouteBinding / @RouteBindings

Bind controllers to routes.

```dart
@RouteBinding(UserController)
class UserPage extends StatelessWidget { ... }

// Or multiple bindings
@RouteBindings([UserController, ProfileController], lazy: true)
class UserPage extends StatelessWidget { ... }
```

### @RouteMiddleware / @RouteMiddlewares

Add middleware to routes.

```dart
@RouteMiddleware(AuthMiddleware)
class UserPage extends StatelessWidget { ... }

// Or multiple middlewares
@RouteMiddlewares([AuthMiddleware, LoggingMiddleware])
class UserPage extends StatelessWidget { ... }
```

## Generated Code

The generator creates a single `app_router.g.dart` file containing:

### 1. Route Data Classes

All generated route classes extend `NavigableRoute` which provides common navigation methods:

```dart
class HomePageRoute extends NavigableRoute {
  const HomePageRoute();
  
  @override
  String get path => '/home';
}

class UserPageRoute extends NavigableRoute {
  const UserPageRoute({
    required this.userId,
    this.tab,
  });

  final int userId;
  final String? tab;

  @override
  String get path => '/user/$userId' + (tab != null ? '?tab=$tab' : '');
}
```

**Note:** All navigation methods are inherited from the `NavigableRoute` base class, keeping the generated code clean and maintainable.

**Available Navigation Methods:**
- `push<T>()` - Navigate to this route
- `pushReplacement<T>()` - Replace current route
- `pushAndRemoveUntil<T>(predicate)` - Remove routes until condition
- `pushAndRemoveAll<T>()` - Clear stack and push this route
- `pushWithArgs<T>(arguments)` - Navigate with arguments (invisible, any type)
- `pushReplacementWithArgs<T>(arguments)` - Replace with arguments
- `pushWithParameters<T>(parameters)` - Navigate with parameters (URL query string)
- `isActive` - Check if route is currently active
- `routeName` - Get the route path

**Key Difference:**
- **Parameters** (`pushWithParameters`) → visible in URL, strings only, for deep links
- **Arguments** (`pushWithArgs`) → invisible, any type, for complex objects

### 2. getPages Array

```dart
final getPages = <JetPage>[
  JetPage(
    name: '/home',
    page: () => HomePage(),
    fullscreenDialog: false,
    maintainState: true,
    preventDuplicates: true,
  ),
  JetPage(
    name: '/user/:userId',
    page: () {
      final userId = int.parse(Jet.parameters['userId']!);
      final tabStr = Jet.parameters['tab'];
      final tab = tabStr != null ? tabStr : null as String?;
      return UserPage(userId: userId, tab: tab);
    },
    fullscreenDialog: false,
    maintainState: true,
    preventDuplicates: true,
  ),
];
```

## Parameter Types

The generator automatically converts route parameters based on their types:

- `int` → `int.parse(param)`
- `double` → `double.parse(param)`
- `bool` → `param == 'true'`
- `String` → `param` (no conversion)

## Examples

### Basic Route

```dart
@RoutePage()  // Path: /home
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) => Scaffold(...);
}

// Navigate
const HomePageRoute().push();
```

### Route with Path Parameters

```dart
@RoutePage(path: '/product/:productId')
class ProductPage extends StatelessWidget {
  final int productId;
  
  const ProductPage({super.key, required this.productId});
  
  @override
  Widget build(BuildContext context) => Scaffold(...);
}

// Navigate
const ProductPageRoute(productId: 123).push();
```

### Route with Query Parameters

```dart
@RoutePage(path: '/search')
class SearchPage extends StatelessWidget {
  @QueryParam()
  final String? query;
  
  @QueryParam()
  final String? category;
  
  const SearchPage({super.key, this.query, this.category});
  
  @override
  Widget build(BuildContext context) => Scaffold(...);
}

// Navigate
const SearchPageRoute(query: 'flutter', category: 'mobile').push();
// Generates: /search?query=flutter&category=mobile
```

### Route with Binding

```dart
class UserController extends JetxController {
  var userName = 'John'.obs;
}

@RoutePage(path: '/profile/:userId')
@RouteBinding(UserController)
class ProfilePage extends StatelessWidget {
  final int userId;
  
  const ProfilePage({super.key, required this.userId});
  
  @override
  Widget build(BuildContext context) {
    final controller = Jet.find<UserController>();
    return Scaffold(...);
  }
}
```

## Comparison with Manual Routes

**Before (Manual):**
```dart
// Define routes manually
JetMaterialApp(
  getPages: [
    JetPage(
      name: '/user/:userId',
      page: () {
        final userId = int.parse(Jet.parameters['userId']!);
        final tab = Jet.parameters['tab'];
        return UserPage(userId: userId, tab: tab);
      },
    ),
  ],
)

// Navigate (not type-safe)
Jet.toNamed('/user/42?tab=posts');
```

**After (Generated):**
```dart
// Create app_router.dart with @JetRouter annotation
@JetRouter([HomePage, UserPage])
class AppRouter {}

// Use generated getPages
JetMaterialApp(
  getPages: getPages,  // All routes in one array
)

// Navigate (type-safe)
const UserPageRoute(userId: 42, tab: 'posts').push();
```

## Tips

1. **Centralized router:** Create one `app_router.dart` file with `@JetRouter` annotation
2. **Use `part` directive:** Add `part 'app_router.g.dart';` to your router file
3. **Run build_runner after changes:** Generated code updates automatically
4. **Use watch mode during development:** `flutter pub run build_runner watch`
5. **Combine routes:** Use spread operator to combine generated and manual routes: `[...getPages, manualRoute]`

## Architecture

The generator follows the architecture of popular code generation tools:

- **jetx_annotations**: Annotation classes
- **jetx_generator**: Code generation logic using `source_gen` and `code_builder`
- Uses `build_runner` for code generation
- Generates `.g.dart` part files

## License

Same as JetX framework

