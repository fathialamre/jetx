# JetX Route Generator Example

This example demonstrates how to use the JetX route generator to create type-safe routes for your Flutter application.

## Features Demonstrated

- ✅ Router configuration with `@JetRouteConfig`
- ✅ Page annotation with `@JetPageRoute`
- ✅ Auto-generated route classes
- ✅ Type-safe navigation helpers
- ✅ Custom and auto-generated paths

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Routes

Run the build_runner to generate route classes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or use watch mode for automatic regeneration during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 3. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── router.dart            # Router configuration
├── router.g.dart          # Generated routes (auto-generated)
└── pages/
    ├── home_page.dart     # Home page with @JetPageRoute
    ├── profile_page.dart  # Profile page with @JetPageRoute
    └── settings_page.dart # Settings page with @JetPageRoute
```

## How It Works

### 1. Define the Router

In `router.dart`:

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

In your page files:

```dart
import 'package:flutter/material.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

@JetPageRoute(path: '/home')
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Welcome!')),
    );
  }
}
```

### 3. Use the Router in Your App

In `main.dart`:

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
      title: 'JetX Example',
      initialRoute: '/home',
      jetPages: AppRouter.pages,  // Use generated pages
    );
  }
}
```

### 4. Navigate Using Generated Routes

After running the build_runner, you'll have access to generated route classes:

```dart
// Navigate to home
HomePageRoute.push();

// Navigate to profile
ProfilePageRoute.push();

// Navigate to settings
SettingsPageRoute.push();

// Use other navigation methods
SettingsPageRoute.replace();
SettingsPageRoute.off();
SettingsPageRoute.offAll();
```

## Generated Code

After running `build_runner`, a `router.g.dart` file will be created with:

- Route class for each annotated page (e.g., `HomePageRoute`, `ProfilePageRoute`, `SettingsPageRoute`)
- Navigation helper methods (push, replace, off, offAll, etc.)
- Automatic parameter handling
- Type-safe route paths
- `_$AppRouterPages` list for JetMaterialApp

## Code Generation Commands

### Build Once

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Recommended for Development)

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Clean Build Cache

If you encounter issues:

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

## Advanced Usage

### Custom Paths

```dart
@JetPageRoute(path: '/custom-path')
class MyPage extends StatelessWidget { ... }
```

### Auto-Generated Paths

If you don't specify a path, it's auto-generated from the class name:

```dart
@JetPageRoute()  // Generates: /user-profile
class UserProfilePage extends StatelessWidget { ... }
```

### Pages with Parameters

```dart
@JetPageRoute(path: '/profile')
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

## Troubleshooting

### Build Runner Errors

If you see errors during code generation:

1. Clean the build cache:
   ```bash
   dart run build_runner clean
   ```

2. Delete conflicting files:
   ```bash
   rm -rf .dart_tool/build
   ```

3. Rebuild:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Missing Part Directive

Make sure your router file has the part directive:

```dart
part 'router.g.dart';  // Must match your file name
```

### Import Errors

Ensure you have the necessary imports:

```dart
import 'package:jet/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
```

## Learn More

- [JetX Documentation](https://github.com/fathialamre/jetx)
- [JetX Annotations](../packages/jetx_annotations/README.md)
- [JetX Generator](../packages/jetx_generator/README.md)

## License

MIT License
