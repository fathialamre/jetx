# Route Management

JetX provides powerful route management without requiring context. Navigate anywhere in your app with simple, intuitive APIs.

---

## Table of Contents

- [Introduction](#introduction)
- [Basic Navigation](#basic-navigation)
- [Named Routes](#named-routes)
- [Route Parameters](#route-parameters)
- [Middleware](#middleware)
- [Nested Navigation](#nested-navigation)
- [Best Practices](#best-practices)

---

## Introduction

JetX route management eliminates the need for context in navigation. Navigate from anywhere in your app - controllers, services, or widgets - without passing context around.

**Key Benefits:**
- 🚀 **No Context Required** - Navigate from anywhere
- ⚡ **Simple API** - Intuitive navigation methods
- 🎯 **Type Safe** - Full type safety support
- 🔗 **Integrated** - Works seamlessly with state management

---

## Basic Navigation

### Navigate to Next Screen

```dart
// Go to next screen
Jet.to(NextScreen());

// Go to next screen and remove current
Jet.off(NextScreen());

// Go to next screen and remove all previous
Jet.offAll(NextScreen());

// Go back
Jet.back();

// Go back with result
Jet.back(result: 'success');
```

### Navigation with Results

```dart
// Navigate and wait for result
var result = await Jet.to(SelectionScreen());

// Handle result
if (result == 'success') {
  print('User selected successfully');
}

// In SelectionScreen, return result
Jet.back(result: 'success');
```

### Alternative Navigation

```dart
// Using Flutter's navigator (no context needed)
navigator.push(
  MaterialPageRoute(
    builder: (_) => NextScreen(),
  ),
);

// JetX syntax (recommended)
Jet.to(NextScreen());
```

---

## Named Routes

### Setup

Define routes in your `JetMaterialApp`:

```dart
void main() {
  runApp(
    JetMaterialApp(
      initialRoute: '/',
      getPages: [
        JetPage(name: '/', page: () => HomeScreen()),
        JetPage(name: '/profile', page: () => ProfileScreen()),
        JetPage(
          name: '/settings',
          page: () => SettingsScreen(),
          transition: Transition.zoom,
        ),
      ],
    ),
  );
}
```

### Navigation

```dart
// Navigate to named route
Jet.toNamed('/profile');

// Navigate and remove current
Jet.offNamed('/profile');

// Navigate and remove all previous
Jet.offAllNamed('/profile');

// Navigate with arguments
Jet.toNamed('/profile', arguments: {'userId': 123});
```

### Unknown Routes (404)

Handle routes that don't exist:

```dart
JetMaterialApp(
  unknownRoute: JetPage(
    name: '/notfound',
    page: () => NotFoundScreen(),
  ),
  initialRoute: '/',
  getPages: [
    JetPage(name: '/', page: () => HomeScreen()),
    JetPage(name: '/profile', page: () => ProfileScreen()),
  ],
)
```

---

## Route Parameters

### Arguments

Send data to routes:

```dart
// Send arguments
Jet.toNamed('/profile', arguments: {'userId': 123, 'name': 'John'});

// Receive arguments
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = Jet.arguments as Map<String, dynamic>;
    final userId = args['userId'];
    final name = args['name'];
    
    return Scaffold(
      appBar: AppBar(title: Text('Profile of $name')),
      body: Text('User ID: $userId'),
    );
  }
}
```

### Dynamic URLs

Create dynamic routes with parameters:

```dart
// Define dynamic routes
JetMaterialApp(
      getPages: [
    JetPage(name: '/', page: () => HomeScreen()),
    JetPage(name: '/user/:id', page: () => UserScreen()),
    JetPage(name: '/post/:id/comments', page: () => CommentsScreen()),
  ],
)

// Navigate with parameters
Jet.toNamed('/user/123');
Jet.toNamed('/post/456/comments');

// Access parameters
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = Jet.parameters['id'];
    
    return Scaffold(
      appBar: AppBar(title: Text('User $userId')),
      body: Text('User ID: $userId'),
    );
  }
}
```

### Query Parameters

Add query parameters to routes:

```dart
// Navigate with query parameters
Jet.toNamed('/search?query=flutter&category=tech');

// Or use parameters map
Jet.toNamed('/search', parameters: {
  'query': 'flutter',
  'category': 'tech',
});

// Access query parameters
class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final query = Jet.parameters['query'];
    final category = Jet.parameters['category'];
    
    return Scaffold(
      appBar: AppBar(title: Text('Search: $query')),
      body: Text('Category: $category'),
    );
  }
}
```

---

## Middleware

Control route access and lifecycle with middleware.

### Creating Middleware

```dart
class AuthMiddleware extends JetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Jet.find<AuthService>();
    return authService.isAuthenticated ? null : RouteSettings(name: '/login');
  }

  @override
  JetPage? onPageCalled(JetPage? page) {
    // Modify page before creation
    return page;
  }
}

class LoggingMiddleware extends JetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    print('Navigating to: $route');
    return null;
  }
}
```

### Using Middleware

```dart
// Apply middleware to specific routes
JetPage(
  name: '/dashboard',
  page: () => DashboardScreen(),
  middlewares: [AuthMiddleware()],
)

// Apply middleware globally
JetMaterialApp(
  routingCallback: (routing) {
    if (routing.current == '/dashboard') {
      // Check authentication
      final authService = Jet.find<AuthService>();
      if (!authService.isAuthenticated) {
        Jet.offNamed('/login');
      }
    }
  },
  getPages: [
    JetPage(name: '/', page: () => HomeScreen()),
    JetPage(name: '/dashboard', page: () => DashboardScreen()),
    JetPage(name: '/login', page: () => LoginScreen()),
  ],
)
```

### Route Guards

```dart
class AdminMiddleware extends JetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final userService = Jet.find<UserService>();
    return userService.isAdmin ? null : RouteSettings(name: '/unauthorized');
  }
}

// Protect admin routes
JetPage(
  name: '/admin',
  page: () => AdminScreen(),
  middlewares: [AuthMiddleware(), AdminMiddleware()],
)
```

---

## Nested Navigation

Create parallel navigation stacks for complex UIs.

```dart
class NestedNavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left navigation
          Expanded(
            flex: 1,
            child: Navigator(
              key: Jet.nestedKey(1),
              initialRoute: '/menu',
              onGenerateRoute: (settings) {
                if (settings.name == '/menu') {
                  return JetPageRoute(
                    page: () => MenuScreen(),
                  );
                }
                return null;
          },
        ),
      ),
          
          // Right content
          Expanded(
            flex: 3,
            child: Navigator(
              key: Jet.nestedKey(2),
              initialRoute: '/content',
              onGenerateRoute: (settings) {
                if (settings.name == '/content') {
                  return JetPageRoute(
                    page: () => ContentScreen(),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Navigate within nested navigator
Jet.toNamed('/details', id: 2); // Navigate in right navigator
Jet.toNamed('/settings', id: 1); // Navigate in left navigator
```

---

## Best Practices

### 1. Route Organization

```dart
// Organize routes in separate files
class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String user = '/user/:id';
  static const String post = '/post/:id';
}

// Use constants
Jet.toNamed(AppRoutes.profile);
```

### 2. Route Parameters

```dart
// Use typed parameters
class RouteParams {
  final String userId;
  final String? category;
  
  RouteParams({required this.userId, this.category});
}

// Pass typed parameters
Jet.toNamed('/user/${params.userId}', arguments: params);

// Receive typed parameters
final params = Jet.arguments as RouteParams;
```

### 3. Middleware Best Practices

```dart
// Keep middleware simple and focused
class AuthMiddleware extends JetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Single responsibility: check authentication
    return _isAuthenticated() ? null : RouteSettings(name: '/login');
  }
  
  bool _isAuthenticated() {
    final authService = Jet.find<AuthService>();
    return authService.isAuthenticated;
  }
}
```

### 4. Error Handling

```dart
// Handle navigation errors
try {
  await Jet.toNamed('/profile');
} catch (e) {
  print('Navigation failed: $e');
  // Handle error
}

// Provide fallback routes
JetMaterialApp(
  unknownRoute: JetPage(
    name: '/notfound',
    page: () => NotFoundScreen(),
  ),
  // ... other routes
)
```

### 5. Performance Tips

- Use `Jet.off()` instead of `Jet.to()` when you don't need to go back
- Use `Jet.offAll()` to clear navigation stack when appropriate
- Implement proper middleware to avoid unnecessary redirects
- Use nested navigation sparingly - it can be complex

---

## Complete Example

### Multi-Screen App with Authentication

```dart
// lib/routes/app_routes.dart
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

// lib/middleware/auth_middleware.dart
class AuthMiddleware extends JetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Jet.find<AuthService>();
    final isAuthenticated = authService.isAuthenticated;
    
    // Allow access to login and splash screens
    if (route == AppRoutes.login || route == AppRoutes.splash) {
      return null;
    }
    
    // Redirect to login if not authenticated
    return isAuthenticated ? null : RouteSettings(name: AppRoutes.login);
  }
}

// lib/main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      title: 'JetX Demo',
      initialRoute: AppRoutes.splash,
      getPages: [
        JetPage(
          name: AppRoutes.splash,
          page: () => SplashScreen(),
        ),
        JetPage(
          name: AppRoutes.login,
          page: () => LoginScreen(),
        ),
        JetPage(
          name: AppRoutes.home,
          page: () => HomeScreen(),
          middlewares: [AuthMiddleware()],
        ),
        JetPage(
          name: AppRoutes.profile,
          page: () => ProfileScreen(),
          middlewares: [AuthMiddleware()],
        ),
        JetPage(
          name: AppRoutes.settings,
          page: () => SettingsScreen(),
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}

// lib/controllers/auth_controller.dart
class AuthController extends JetxController {
  final isAuthenticated = false.obs;
  
  Future<void> login(String email, String password) async {
    try {
      // Perform login
      await authService.login(email, password);
      isAuthenticated.value = true;
      
      // Navigate to home
      Jet.offAllNamed(AppRoutes.home);
    } catch (e) {
      Jet.snackbar('Error', 'Login failed: $e');
    }
  }
  
  void logout() {
    authService.logout();
    isAuthenticated.value = false;
    Jet.offAllNamed(AppRoutes.login);
  }
}

// lib/screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Jet.find<AuthController>();
    
    return Scaffold(
          appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Jet.toNamed(AppRoutes.profile),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Jet.toNamed(AppRoutes.settings),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Home Screen'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Jet.toNamed(AppRoutes.profile),
              child: Text('Go to Profile'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Jet.toNamed(AppRoutes.settings),
              child: Text('Go to Settings'),
            ),
          ],
        ),
        ),
      );
    }
  }
```

---

## Learn More

- **[State Management](./state_management.md)** - Reactive state management
- **[Dependency Management](./dependency_management.md)** - Smart dependency injection
- **[UI Features](./ui_features.md)** - Dialogs, snackbars, and more
- **[Quick Reference](./quick_reference.md)** - Fast lookup for all features

---

**Ready to navigate without context?** [Get started with JetX →](../README.md#quick-start)