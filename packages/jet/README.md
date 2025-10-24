# Jet Router

A modern, context-aware Flutter router based on Navigator 2.0, designed to address common issues with service-locator-based routing while providing a clean, type-safe API.

## Features

- ✅ **Context-aware navigation** - All navigation requires BuildContext (no global access)
- ✅ **Explicit dependencies** - No service locator pattern
- ✅ **Type-safe routing** - Compile-time safety with code generation support
- ✅ **Return results from routes** - Like go_router and auto_route, await results from navigation
- ✅ **Route guards** - Protect routes with authentication and authorization
- ✅ **Custom transitions** - Beautiful page transitions with customizable animations
- ✅ **Deep linking** - Full support for web URLs and app links
- ✅ **Path parameters** - Extract parameters from route paths
- ✅ **Query parameters** - Handle URL query parameters
- ✅ **Navigator 2.0** - Built on Flutter's declarative navigation API

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  jet:
    path: ../jet
```

## Quick Start

### 1. Define Your Routes

```dart
final appRoutes = [
  JetRoute(
    path: '/',
    builder: (context, data) => const HomePage(),
    initialRoute: true,
  ),
  JetRoute(
    path: '/profile/:userId',
    builder: (context, data) => ProfilePage(
      userId: data.pathParams['userId']!,
    ),
    guards: [AuthGuard()],
    transition: const TransitionType.slideRight(),
  ),
  JetRoute(
    path: '/settings',
    builder: (context, data) => const SettingsPage(),
    transition: const TransitionType.fadeIn(),
  ),
];
```

### 2. Configure MaterialApp

Create a `JetRouter` instance and use it with `MaterialApp.router`:

```dart
// Create the router instance
final jetRouter = JetRouter(
  routes: appRoutes,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: jetRouter.routerConfig,
    );
  }
}
```

**Alternative (explicit properties for advanced control)**:
```dart
MaterialApp.router(
  routerDelegate: jetRouter.routerDelegate,
  routeInformationParser: jetRouter.routeInformationParser,
  backButtonDispatcher: jetRouter.backButtonDispatcher,
  // You can also add routeInformationProvider if needed
);
```

**Advanced configuration**:
```dart
final jetRouter = JetRouter(
  routes: appRoutes,
  initialRoute: '/home', // Optional: override initial route
  useHashUrl: false, // Web: use path-based URLs (default)
  navigatorKey: myNavigatorKey, // Optional: custom navigator key
);
```

### 3. Navigate Using Context Extensions

```dart
// Push a new route
context.router.push('/profile/123');

// Replace current route
context.router.replace('/login');

// Pop current route
context.router.pop();

// Clear stack and navigate
context.router.pushAndRemoveAll('/');

// Access route data
final userId = context.router.pathParam('userId');
final query = context.router.queryParam('search');
```

### 4. Return Results from Routes

Just like **go_router** and **auto_route**, you can await results from pushed routes:

```dart
// Navigate and await a result
final result = await context.router.push<String>('/edit-profile');
if (result != null) {
  print('Profile updated: $result');
}

// Return a result when popping
ElevatedButton(
  onPressed: () {
    context.router.pop('user_updated');
  },
  child: Text('Save'),
)

// Type-safe results with any type
final isConfirmed = await context.router.push<bool>('/confirm-dialog');
if (isConfirmed == true) {
  // User confirmed
}

// Works with replace and pushAndRemoveAll too
final data = await context.router.replace<Map<String, dynamic>>('/form');
```

This follows the exact same pattern as go_router's `context.push<T>()` and auto_route's result handling.

## Advanced Usage

### Route Guards

Protect routes with custom guards:

```dart
class AuthGuard extends RouteGuard {
  @override
  Future<bool> canActivate(BuildContext context, JetRoute route) async {
    // Check if user is authenticated
    final isAuthenticated = await checkAuth();
    return isAuthenticated;
  }

  @override
  String? redirect(BuildContext context, JetRoute route) {
    return '/login'; // Redirect to login if not authenticated
  }
}
```

### Custom Transitions

```dart
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: TransitionType.custom(
    builder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      );
    },
  ),
)
```

### Multiple Route Configurations

Organize routes by feature:

```dart
final config = RouteConfig.merge([
  authRoutes,
  profileRoutes,
  settingsRoutes,
]);
```

## Key Differences from GetX/Nylo

- ✅ No global state access (`Get.to()`, `Get.find()`)
- ✅ BuildContext required for all navigation
- ✅ Explicit dependencies in constructors
- ✅ No magic lifecycle management
- ✅ Follows Flutter's Navigator 2.0 architecture
- ✅ Testable with standard Flutter testing tools

## License

See LICENSE file.
