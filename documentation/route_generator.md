# JetX Route Generator

The JetX Route Generator automatically generates type-safe route classes for your Flutter application, eliminating boilerplate code and reducing errors.

## Features

- 🚀 **Automatic route generation** from annotated pages
- 🔒 **Type-safe navigation** with compile-time checking
- 📦 **Parameter handling** - automatically detects URL parameters and complex arguments
- ✨ **Clean generated code** - only 3 navigation methods per route (push, off, offAll)
- 🎯 **Zero boilerplate** - just annotate your pages and go

## Installation

### 1. Add dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  jet: ^0.1.0-alpha.4
  jetx_annotations: ^0.1.0-alpha.4

dev_dependencies:
  build_runner: ^2.4.0
  jetx_generator: ^0.1.0-alpha.4
```

### 2. Install packages

```bash
flutter pub get
```

## Setup

### 1. Create a router file

Create a file `lib/router.dart`:

```dart
import 'package:jetx/jet.dart';
import 'package:jetxx_annotations/jetx_annotations.dart';

// Import all your page files
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';

part 'router.g.dart';

@JetRouteConfig(generateForDir: ['lib'])
class AppRouter {
  static List<JetPage> get pages => [
    JetPage(name: HomePageRoute.path, page: () => HomePageRoute.page()),
    JetPage(name: ProfilePageRoute.path, page: () => ProfilePageRoute.page()),
    JetPage(name: SettingsPageRoute.path, page: () => SettingsPageRoute.page()),
  ];
}
```

> **Note:**  
You should manually register all your generated route pages here in the `AppRouter.pages` list, as shown above.  

For each page you want routed, add an entry like:  
```dart
JetPage(
  name: SomePageRoute.path,
  page: () => SomePageRoute.page(),
  // Optionally set other JetPage properties such as
  // transition, binding, middlewares, etc.
)
```
Make sure to include every page you wish to expose for navigation, following this pattern and populating any needed properties per your use case.


**After creating the file, you should register the routes in your app like this:**

```dart
// In your main.dart or app configuration
JetMaterialApp(
  getPages: AppRouter.pages,  // Register the generated routes
  home: HomePage(),
)
```

### 2. Annotate your pages

Annotate each page with `@RoutablePage`:

```dart
import 'package:flutter/material.dart';
import 'package:jetxx_annotations/jetx_annotations.dart';

@RoutablePage(path: '/home')
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}
```

### 3. Run the generator

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch for changes:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Usage

### Basic Navigation

After generation, you can navigate using the generated route classes:

```dart
// Push a new route
HomePageRoute.push();

// Replace current route
HomePageRoute.off();

// Clear stack and navigate
HomePageRoute.offAll();
```

### Routes with Parameters

The generator automatically detects parameters and creates type-safe navigation methods:

```dart
@RoutablePage(path: '/profile')
class ProfilePage extends StatelessWidget {
  final String userId;
  final String? name;
  final Profile profile;

  const ProfilePage({
    super.key,
    required this.userId,
    this.name,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile: $userId')),
      body: Text('Name: ${name ?? "Unknown"}'),
    );
  }
}
```

Navigate with parameters:

```dart
// All parameters are passed with type safety
ProfilePageRoute.push(
  userId: '123',
  name: 'John Doe',
  profile: myProfileObject,
);
```

### Parameter Types

The generator automatically categorizes parameters:

- **URL Parameters** (primitives): `String`, `int`, `double`, `bool`
  - Passed via `Jet.parameters` as query strings
  - Serialized to strings automatically

- **Arguments** (complex types): Custom objects, `List`, `Map`, etc.
  - Passed via `Jet.arguments`
  - Can be any Dart object

### Custom Path

If you don't specify a path, the generator creates one from the class name:

```dart
@RoutablePage()  // Auto-generates path '/home-page'
class HomePage extends StatelessWidget {
  // ...
}
```

Or specify a custom path:

```dart
@RoutablePage(path: '/custom/path')
class HomePage extends StatelessWidget {
  // ...
}
```

### Explicit Parameter Types

Override automatic detection with annotations:

```dart
@RoutablePage(path: '/advanced')
class AdvancedPage extends StatelessWidget {
  @JetParams()  // Force this to be a URL parameter
  final CustomObject customObject;
  
  @JetArgs()    // Force this to be an argument
  final String userId;

  // ...
}
```

## Generated Code Structure

For each annotated page, the generator creates a route class with:

1. **Path constant** - Static path string
2. **page() method** - Factory method that reads parameters from Jet
3. **Helper methods** - `_buildParameters()` and `_buildArguments()` for code reuse
4. **Navigation methods** - Type-safe navigation helpers

Example generated code:

```dart
class ProfilePageRoute {
  ProfilePageRoute._();

  static const String path = '/profile';

  static ProfilePage page() {
    final userIdValue = Jet.parameters['userId']!;
    final nameValue = Jet.parameters['name'];
    final args = Jet.arguments;
    return ProfilePage(
      userId: userIdValue,
      profile: args as Profile,
      name: nameValue,
    );
  }

  static Map<String, String> _buildParameters({
    required String userId,
    String? name,
  }) {
    return {
      'userId': userId,
      if (name != null) 'name': name,
    };
  }

  static dynamic _buildArguments({
    required Profile profile,
  }) {
    return profile;
  }

  static Future<T?>? push<T>({
    required String userId,
    required Profile profile,
    String? name,
  }) {
    return Jet.toNamed<T>(
      path,
      parameters: _buildParameters(userId: userId, name: name),
      arguments: _buildArguments(profile: profile),
    );
  }

  static Future<T?>? off<T>({
    required String userId,
    required Profile profile,
    String? name,
  }) {
    return Jet.offNamed<T>(
      path,
      parameters: _buildParameters(userId: userId, name: name),
      arguments: _buildArguments(profile: profile),
    );
  }

  static Future<T?>? offAll<T>({
    required String userId,
    required Profile profile,
    String? name,
  }) {
    return Jet.offAllNamed<T>(
      path,
      parameters: _buildParameters(userId: userId, name: name),
      arguments: _buildArguments(profile: profile),
    );
  }
}
```

## Navigation Methods

Each generated route class provides three navigation methods:

- **`push()`** - Navigate to the route (pushes onto navigation stack)
- **`off()`** - Replace the current route (removes current, then navigates)
- **`offAll()`** - Clear all routes and navigate (clears stack, then navigates)

All methods:
- Are type-safe with proper parameter types
- Support generic return types `<T>`
- Return `Future<T?>?` for handling navigation results

## Configuration Options

### JetRouteConfig

```dart
@JetRouteConfig(
  generateForDir: ['lib', 'lib/features'],  // Directories to scan
)
class AppRouter {
  // ...
}
```

### RoutablePage

```dart
@RoutablePage(
  path: '/custom/path',  // Optional: custom path
)
class MyPage extends StatelessWidget {
  // ...
}
```

## Best Practices

1. **Import your pages** - Always import page files in your router file
2. **Run generator often** - Use `watch` mode during development
3. **Commit generated files** - Include `.g.dart` files in version control
4. **Exclude key parameter** - The generator automatically excludes Flutter's `key` parameter
5. **Use const constructors** - For better performance in your page widgets

## Troubleshooting

### "No routes found"

Make sure:
- Your pages are annotated with `@RoutablePage`
- Page files are in the directories specified in `generateForDir`
- You've imported the page files in your router file

### "Part of directive error"

Ensure your router file has:
```dart
part 'router.g.dart';
```

### "Cannot find Jet.parameters"

Make sure you've:
1. Added `JetMaterialApp` as your root app widget
2. Configured navigation properly in your app

## Example Project

See the [example](../example) directory for a complete working implementation.

## Comparison with Manual Routes

### Before (Manual):

```dart
// Define route
Jet.toNamed('/profile', 
  parameters: {'userId': userId, 'name': name},
  arguments: profile,
);

// In ProfilePage - manually extract parameters
final userId = Jet.parameters['userId']!;
final name = Jet.parameters['name'];
final profile = Jet.arguments as Profile;
```

### After (Generated):

```dart
// Type-safe navigation
ProfilePageRoute.push(
  userId: userId,
  name: name,
  profile: profile,
);

// Parameters automatically extracted in generated code
```

## Benefits

✅ **Type Safety** - Compile-time checking of parameters  
✅ **Auto-completion** - IDE suggests available parameters  
✅ **Refactoring** - Rename parameters and get compile errors instead of runtime errors  
✅ **Less Code** - No manual parameter extraction  
✅ **Maintainability** - Single source of truth for route definitions  
✅ **Performance** - No reflection or runtime overhead

