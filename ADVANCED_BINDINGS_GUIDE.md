# Advanced Bindings Guide

## Overview

JetX now supports advanced binding features including:
- Multiple bindings per route
- Automatic dependency resolution with constructor analysis
- Support for `tag` and `permanent` parameters
- Automatic topological sorting of dependencies

## Features

### 1. Multiple Bindings

You can now specify multiple bindings for a single route using either multiple `@RouteBinding` annotations or a single `@RouteBindings` annotation.

#### Using Multiple @RouteBinding Annotations

```dart
@RoutePage()
@RouteBinding(AuthService, permanent: true)
@RouteBinding(UserService, permanent: true)
@RouteBinding(UserController, tag: 'user-ctrl')
class UserPage extends StatelessWidget {
  // ...
}
```

Each binding can have its own `tag` and `permanent` settings.

#### Using @RouteBindings Annotation

```dart
@RoutePage(path: '/profile')
@RouteBindings([AuthService, UserService, UserController], permanent: true)
class ProfilePage extends StatelessWidget {
  // ...
}
```

The `permanent` parameter applies to all bindings in the list. Individual tags are not supported with `@RouteBindings`.

### 2. Automatic Dependency Resolution

The generator automatically analyzes constructor dependencies and resolves them in the correct order.

**Example:**

```dart
// Service with no dependencies
class AuthService {
  String getToken() => 'token-12345';
}

// Service that depends on AuthService
class UserService {
  final AuthService authService;
  UserService(this.authService);
}

// Controller that depends on UserService
class UserController extends JetxController {
  final UserService service;
  UserController(this.service);
}
```

**Usage:**

```dart
@RoutePage()
@RouteBindings([AuthService, UserService, UserController])
class MyPage extends StatelessWidget {
  // ...
}
```

**Generated Code:**

```dart
binding: BindingsBuilder(() {
  Jet.lazyPut(() => AuthService());
  Jet.lazyPut(() => UserService(Jet.find<AuthService>()));
  Jet.lazyPut(() => UserController(Jet.find<UserService>()));
}),
```

The generator:
1. Analyzes each controller's constructor
2. Identifies dependencies
3. Sorts bindings using topological sort
4. Injects dependencies using `Jet.find<T>()`

### 3. Tag and Permanent Parameters

#### Tag Parameter

Use `tag` to register a binding with a specific identifier. Useful when you have multiple instances of the same type.

```dart
@RouteBinding(UserController, tag: 'user-ctrl')
```

Generated:
```dart
Jet.lazyPut(() => UserController(...), tag: 'user-ctrl');
```

Retrieve it with:
```dart
final controller = Jet.find<UserController>(tag: 'user-ctrl');
```

#### Permanent Parameter

Use `permanent: true` to keep the instance alive even when the page is disposed.

```dart
@RouteBinding(AuthService, permanent: true)
```

Generated:
```dart
Jet.lazyPut(() => AuthService(), permanent: true);
```

### 4. Lazy vs Eager Loading

By default, all bindings are lazy. Set `lazy: false` for eager initialization.

```dart
@RouteBinding(AuthService, lazy: false)
```

Generated:
```dart
Jet.put(AuthService());  // Initialized immediately
```

## Complete Example

```dart
// Services
class AuthService {
  bool isAuthenticated() => true;
}

class UserService {
  final AuthService authService;
  UserService(this.authService);
  
  String getUserData() {
    return authService.isAuthenticated() 
      ? 'User data' 
      : 'Not authenticated';
  }
}

class UserController extends JetxController {
  final UserService service;
  UserController(this.service);
  
  void loadUser() => print(service.getUserData());
}

// Page with bindings
@RoutePage(path: '/user/:id')
@RouteBinding(AuthService, permanent: true)
@RouteBinding(UserService, permanent: true)
@RouteBinding(UserController, tag: 'user-ctrl')
class UserPage extends StatelessWidget {
  final int id;
  
  const UserPage({required this.id});
  
  @override
  Widget build(BuildContext context) {
    final controller = Jet.find<UserController>(tag: 'user-ctrl');
    controller.loadUser();
    return Scaffold(/* ... */);
  }
}
```

## Best Practices

1. **Use `permanent: true` for shared services** that should live across multiple pages (e.g., `AuthService`, `ApiService`)

2. **Use tags for page-specific controllers** to avoid conflicts when the same controller type is used on different pages

3. **Organize dependencies in layers**:
   - Core services (Auth, API) → `permanent: true`
   - Domain services (User, Product) → depends on use case
   - Page controllers → usually not permanent, with tags

4. **The generator handles dependency order** - you don't need to manually order your `@RouteBinding` annotations

5. **Use `@RouteBindings` when all bindings share the same configuration** (like `permanent: true` for all)

## How It Works Under the Hood

1. **Annotation Parsing**: The generator reads `@RouteBinding` and `@RouteBindings` annotations from your page classes

2. **Constructor Analysis**: For each binding, it analyzes the class constructor to extract parameter types

3. **Dependency Graph**: It builds a dependency graph showing which bindings depend on others

4. **Topological Sort**: Dependencies are sorted so that each binding is initialized after its dependencies

5. **Code Generation**: Generates `BindingsBuilder` code with:
   - Proper initialization order
   - `Jet.find<T>()` calls for dependency injection
   - `tag` and `permanent` parameters where specified

## Limitations

1. Only constructor parameters are analyzed (property injection is not supported)
2. Circular dependencies will be detected but may not generate optimal code
3. Optional constructor parameters without defaults are not automatically injected
4. `@RouteBindings` cannot specify individual tags for each binding (use multiple `@RouteBinding` instead)

## Migration from Old Code

**Before:**
```dart
@RoutePage()
class UserPage extends StatelessWidget {
  // Manual binding in router config
}

// In router config:
JetPage(
  name: '/user',
  page: () => UserPage(),
  binding: BindingsBuilder(() {
    Jet.lazyPut(() => UserService());
    Jet.lazyPut(() => UserController(Jet.find<UserService>()));
  }),
)
```

**After:**
```dart
@RoutePage()
@RouteBindings([UserService, UserController])
class UserPage extends StatelessWidget {
  // Automatic binding generation!
}
```

The generator handles everything automatically.

