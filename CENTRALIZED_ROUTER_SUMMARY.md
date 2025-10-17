# Centralized Router Implementation Summary

## Overview

Successfully refactored the JetX route generator from a per-page approach to a centralized router approach, matching the architecture of `auto_route`. This provides a cleaner, more maintainable way to manage routes.

## What Changed

### Before (Per-Page Generation)

```dart
// home_page.dart
@RoutePage(path: '/home')
class HomePage extends StatelessWidget { ... }

part 'home_page.g.dart';  // Generated per page

// In main.dart
getPages: [
  homePageJetPage,  // Import from each file
  userPageJetPage,
]
```

### After (Centralized Router)

```dart
// app_router.dart
@JetRouter([
  HomePage,
  UserPage,
])
class AppRouter {}

part 'app_router.g.dart';  // Single generated file

// In main.dart
import 'app_router.dart';

getPages: getPages,  // Single array
```

## Key Implementation Details

### 1. Updated Annotations

**File:** `packages/jetx_annotations/lib/jetx_annotations.dart`

Simplified `@JetRouter` to accept just a list of route types:

```dart
class JetRouter {
  final List<Type> routes;
  const JetRouter(this.routes);
}
```

### 2. New Router Parser

**File:** `packages/jetx_generator/lib/src/parsers/router_parser.dart`

- Finds classes annotated with `@JetRouter`
- Extracts the list of route types from the annotation
- Resolves each type to its `ClassElement`
- Uses existing `RouteParser` to parse each route
- Collects import paths for all routes
- Returns `RouterConfig` with all routes

### 3. New Router Code Generator

**File:** `packages/jetx_generator/lib/src/generators/router_generator.dart`

Generates a complete `app_router.g.dart` file containing:

- **Route Classes**: One class per route with:
  - Fields for all parameters
  - Const constructor
  - `path` getter with string interpolation
  - Navigation methods (`push()`, `pushReplacement()`, `pushAndRemoveUntil()`)

- **getPages Array**: A `final List<JetPage>` containing:
  - All JetPage configurations
  - Parameter extraction logic
  - Type conversions
  - Bindings setup
  - Middleware integration

### 4. Updated Generator

**File:** `packages/jetx_generator/lib/jetx_generator.dart`

Changed from:
- `JetXRouteGenerator extends GeneratorForAnnotation<RoutePage>` (per-page)

To:
- `JetXRouterGenerator extends GeneratorForAnnotation<JetRouter>` (centralized)

### 5. Build Configuration

**File:** `packages/jetx_generator/build.yaml`

- Uses `SharedPartBuilder` with `.jetx_route.g.part` extension
- Configured to use `source_gen|combining_builder`
- Outputs to cache, combined into `.g.dart` file

## Generated File Structure

### app_router.g.dart

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// Route Classes
class HomePageRoute {
  const HomePageRoute();
  String get path => '/home';
  Future<T?>? push<T>() => Jet.toNamed<T>(path);
  Future<T?>? pushReplacement<T>() => Jet.offNamed<T>(path);
  Future<T?>? pushAndRemoveUntil<T>(bool Function(JetPage)? predicate) =>
      Jet.offNamedUntil<T>(path, predicate);
}

class UserPageRoute {
  const UserPageRoute({required this.userId, this.tab});
  final int userId;
  final String? tab;
  String get path => '/user/$userId' + ...queryString;
  // ... navigation methods
}

// getPages Array
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
    binding: BindingsBuilder(() {
      Jet.lazyPut(() => UserController());
    }),
    // ... other properties
  ),
];
```

## Example Usage

### 1. Create Router File

```dart
// lib/app_router.dart
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

### 2. Annotate Pages

```dart
// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

@RoutePage(path: '/home')
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) => Scaffold(...);
}

// lib/pages/user_page.dart
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';

@RoutePage(path: '/user/:userId')
@RouteBinding(UserController)
class UserPage extends StatelessWidget {
  final int userId;
  
  @QueryParam()
  final String? tab;
  
  const UserPage({super.key, required this.userId, this.tab});
  
  @override
  Widget build(BuildContext context) => Scaffold(...);
}
```

### 3. Run Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Use in App

```dart
// lib/main.dart
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
      getPages: [
        ...getPages,  // Generated routes
        // Manual routes (still supported)
        JetPage(name: '/profile', page: () => const ProfilePage()),
      ],
    );
  }
}
```

### 5. Navigate

```dart
// Type-safe navigation
const UserPageRoute(userId: 42, tab: 'posts').push();
const HomePageRoute().pushReplacement();
```

## Benefits

1. **Single Source of Truth**: All routes defined in one `app_router.dart` file
2. **Better Organization**: Clear separation between route definitions and implementations
3. **Easier Maintenance**: Adding routes requires updating only the `@JetRouter` array
4. **Matches Industry Standard**: Similar to `auto_route` architecture
5. **Type-Safe**: Full compile-time checking for all routes
6. **Backward Compatible**: Can mix generated and manual routes

## Files Modified

### Generator Package
- `packages/jetx_annotations/lib/jetx_annotations.dart` - Simplified `@JetRouter`
- `packages/jetx_generator/lib/src/models/router_config.dart` - New model
- `packages/jetx_generator/lib/src/parsers/router_parser.dart` - New parser
- `packages/jetx_generator/lib/src/generators/router_generator.dart` - New generator
- `packages/jetx_generator/lib/jetx_generator.dart` - Changed to `JetXRouterGenerator`
- `packages/jetx_generator/lib/builder.dart` - Updated builder name
- `packages/jetx_generator/build.yaml` - Build configuration
- `packages/jetx_generator/README.md` - Updated documentation

### Example App
- `example/lib/app_router.dart` - NEW: Centralized router file
- `example/lib/app_router.g.dart` - NEW: Generated file
- `example/lib/pages/home_page.dart` - Removed `part` directive
- `example/lib/pages/user_page.dart` - Removed `part` directive
- `example/lib/main.dart` - Updated to use `getPages` array
- DELETED: `example/lib/pages/home_page.g.dart`
- DELETED: `example/lib/pages/user_page.g.dart`

### Documentation
- `README.md` - Updated code generator section
- `CHANGELOG.md` - Added centralized router details

## Verification

✅ Code compiles without errors
✅ No analyzer issues found
✅ APK builds successfully
✅ Type-safe navigation works correctly
✅ Parameter extraction and conversion working
✅ Bindings integration working
✅ All documentation updated

## Implementation Date

October 17, 2025

## Status

✅ **Complete and Working**

The centralized router is production-ready and provides a much cleaner architecture for managing routes in JetX applications.

