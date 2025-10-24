# Jet Router Documentation

A modern, context-aware Flutter router built on Navigator 2.0, designed for clean, maintainable navigation without global state or service locators.

## Table of Contents

1. [Introduction](#introduction)
2. [Installation & Setup](#installation--setup)
3. [Route Configuration](#route-configuration)
4. [Navigation Methods](#navigation-methods)
5. [Returning Results from Routes](#returning-results-from-routes)
6. [Parameters & Data Passing](#parameters--data-passing)
7. [Route Guards](#route-guards)
8. [Transitions & Animations](#transitions--animations)
9. [Deep Linking & Web URLs](#deep-linking--web-urls)
10. [Advanced Features](#advanced-features)
11. [Best Practices](#best-practices)

---

## Introduction

### What is Jet Router?

Jet Router is a declarative routing solution for Flutter that embraces Navigator 2.0's powerful architecture while providing a clean, intuitive API. Unlike traditional routers that rely on global state access, Jet Router requires BuildContext for all navigation operations, ensuring your code remains testable and maintainable.

### Key Features

- ✅ **Context-aware navigation** - All navigation requires BuildContext (no global access)
- ✅ **Explicit dependencies** - No service locator pattern or hidden dependencies
- ✅ **Type-safe routing** - Compile-time safety with structured route definitions
- ✅ **Return results from routes** - Await results from navigation with type safety
- ✅ **Route guards** - Protect routes with authentication and authorization logic
- ✅ **Custom transitions** - Beautiful page transitions with built-in and custom animations
- ✅ **Deep linking** - Full support for web URLs and app links
- ✅ **Path parameters** - Extract parameters from route paths (e.g., `/user/:id`)
- ✅ **Query parameters** - Handle URL query parameters seamlessly
- ✅ **Navigator 2.0** - Built on Flutter's modern declarative navigation API
- ✅ **Testable** - Easy to test with standard Flutter testing tools

### Why Jet Router?

**Context-Aware vs Service-Locator**

Traditional routers use global state access:

```dart
// ❌ Global access - hard to test, implicit dependencies
// Global navigation calls
// Service locator pattern
```

Jet Router requires explicit context:

```dart
// ✅ Context-aware - testable, explicit dependencies
context.router.push('/profile/123');
```

**Benefits:**

- **Testability**: No global state makes testing straightforward
- **Maintainability**: Explicit dependencies are easy to track
- **Type Safety**: Structured routes prevent runtime errors
- **Flutter Best Practices**: Aligns with Flutter's recommended patterns
- **No Magic**: Clear, predictable behavior without hidden side effects

---

## Installation & Setup

### 1. Add Dependency

Add Jet Router to your `pubspec.yaml`:

```yaml
dependencies:
  jet:
    path: ../jet  # or use git/pub.dev reference
```

Run:

```bash
flutter pub get
```

### 2. Basic Setup

Create your router configuration:

```dart
import 'package:flutter/material.dart';
import 'package:jet/jet_router.dart';

// Define your routes
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
  ),
  JetRoute(
    path: '/settings',
    builder: (context, data) => const SettingsPage(),
  ),
];

// Create the router instance
final jetRouter = JetRouter(
  routes: appRoutes,
);
```

### 3. Configure MaterialApp

Use `MaterialApp.router` with your Jet Router instance:

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My App',
      routerConfig: jetRouter.routerConfig,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
```

**Alternative Configuration (Advanced)**

For more control, you can specify router components individually:

```dart
MaterialApp.router(
  routerDelegate: jetRouter.routerDelegate,
  routeInformationParser: jetRouter.routeInformationParser,
  backButtonDispatcher: jetRouter.backButtonDispatcher,
  // ... other properties
)
```

### 4. Advanced Router Configuration

```dart
final jetRouter = JetRouter(
  routes: appRoutes,
  initialRoute: '/home',              // Override initial route
  useHashUrl: false,                  // Web: use path-based URLs (default)
  navigatorKey: GlobalKey<NavigatorState>(), // Custom navigator key
  notFoundRoute: JetRoute(            // Custom 404 page
    path: '/404',
    builder: (context, data) => const NotFoundPage(),
  ),
);
```

---

## Route Configuration

### Defining Routes with JetRoute

Each route is defined using the `JetRoute` class:

```dart
JetRoute(
  path: '/user/:userId',
  builder: (context, data) => UserPage(
    userId: data.pathParams['userId']!,
  ),
  // Optional properties
  name: 'user-profile',
  initialRoute: false,
  guards: [AuthGuard()],
  transition: const TransitionType.slideRight(),
  transitionDuration: const Duration(milliseconds: 300),
  fullscreenDialog: false,
  maintainState: true,
  popGesture: true,
  meta: {'requiresAuth': true, 'analyticsName': 'profile'},
)
```

### Route Path Patterns

**Simple Paths**

```dart
JetRoute(
  path: '/',
  builder: (context, data) => const HomePage(),
)

JetRoute(
  path: '/about',
  builder: (context, data) => const AboutPage(),
)
```

**Path Parameters**

Use `:paramName` syntax for dynamic segments:

```dart
JetRoute(
  path: '/user/:userId',
  builder: (context, data) {
    final userId = data.pathParams['userId']!;
    return UserPage(userId: userId);
  },
)

JetRoute(
  path: '/blog/:category/:postId',
  builder: (context, data) {
    final category = data.pathParams['category']!;
    final postId = data.pathParams['postId']!;
    return BlogPostPage(category: category, postId: postId);
  },
)
```

### Route Builder

The builder function receives:
- `BuildContext context` - Current build context
- `RouteData data` - Route information (params, query, arguments)

```dart
builder: (context, data) {
  // Access path parameters
  final id = data.pathParams['id'];
  
  // Access query parameters
  final filter = data.queryParams['filter'];
  
  // Access custom arguments
  final args = data.arguments as Map<String, dynamic>?;
  
  return MyPage(id: id, filter: filter, args: args);
}
```

### Initial Route

Mark one route as the initial route:

```dart
JetRoute(
  path: '/',
  builder: (context, data) => const HomePage(),
  initialRoute: true,  // This is the starting route
)
```

### Route Naming

Give routes semantic names for better code organization:

```dart
JetRoute(
  path: '/user/:userId',
  name: 'user-profile',  // Optional name
  builder: (context, data) => const ProfilePage(),
)
```

### Route Metadata

Store additional information with routes:

```dart
JetRoute(
  path: '/admin',
  builder: (context, data) => const AdminPage(),
  meta: {
    'requiresAuth': true,
    'requiredRole': 'admin',
    'analyticsName': 'admin_dashboard',
    'title': 'Admin Dashboard',
  },
)
```

### JetRoute Properties Reference

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `path` | `String` | required | Route path pattern (e.g., `/user/:id`) |
| `builder` | `Function` | required | Widget builder function |
| `name` | `String?` | `null` | Optional route name |
| `initialRoute` | `bool` | `false` | Whether this is the initial route |
| `guards` | `List<RouteGuard>` | `[]` | Route guards for access control |
| `transition` | `TransitionType?` | `null` | Page transition animation |
| `transitionDuration` | `Duration?` | `null` | Transition animation duration |
| `reverseTransitionDuration` | `Duration?` | `null` | Reverse transition duration |
| `curve` | `Curve` | `Curves.linear` | Animation curve |
| `fullscreenDialog` | `bool` | `false` | Present as fullscreen dialog |
| `maintainState` | `bool` | `true` | Maintain state when inactive |
| `popGesture` | `bool?` | `null` | Enable iOS swipe-to-pop gesture |
| `meta` | `Map<String, dynamic>?` | `null` | Additional metadata |

---

## Navigation Methods

Jet Router provides a clean API for navigation through the `context.router` extension.

### Push Navigation

Push a new route onto the navigation stack:

```dart
// Basic push
context.router.push('/profile');

// Push with path parameters
context.router.push('/user/123');

// Push with query parameters
context.router.push('/search?q=flutter&sort=date');

// Push with arguments
context.router.push(
  '/details',
  arguments: {'title': 'My Title', 'data': someData},
);

// Push with all parameter types
context.router.push(
  '/user/123?tab=posts&filter=recent',
  arguments: {'metadata': {...}},
);
```

**How it works:**
- Adds new route to the navigation stack
- Previous route remains in memory
- Back button returns to previous route
- Supports all data passing methods

### Replace Navigation

Replace the current route with a new one:

```dart
// Replace current route
context.router.replace('/login');

// Replace with parameters
context.router.replace(
  '/success?message=Operation completed',
  arguments: {'timestamp': DateTime.now()},
);
```

**How it works:**
- Removes current route from stack
- Adds new route in its place
- Previous route cannot be returned to
- Useful for login flows, onboarding, etc.

**Use cases:**
- After login (replace login page with home)
- After successful operation (replace form with success page)
- Onboarding completion
- Any flow where back navigation should be prevented

### Pop Navigation

Remove the current route and go back:

```dart
// Simple pop
context.router.pop();

// Pop with result
context.router.pop<String>('Some result data');

// Pop with typed result
final result = await context.router.push('/select-item');
if (result != null) {
  // Handle the result
}
```

**Checking if can pop:**

```dart
if (context.router.canPop()) {
  context.router.pop();
} else {
  // We're at the root, show exit dialog
  showExitDialog(context);
}
```

### Push and Remove All

Clear the entire navigation stack and push a new route:

```dart
// Clear stack and go to home
context.router.pushAndRemoveAll('/');

// Useful after logout
await AuthService.logout();
context.router.pushAndRemoveAll('/login');

// After completing onboarding
context.router.pushAndRemoveAll('/home');
```

**How it works:**
- Removes all routes from the stack
- Pushes the new route as the only route
- No back navigation possible
- Creates a fresh navigation state

### Pop Until

Pop routes until a condition is met:

```dart
// Pop until we find a specific route
context.router.popUntil((route) => route.path == '/');

// Pop until we find home route
context.router.popUntil((route) => route.initialRoute);

// Pop until we find a route with specific metadata
context.router.popUntil(
  (route) => route.meta?['isMainPage'] == true,
);
```

### Navigation State Queries

Get information about the current navigation state:

```dart
// Check if can pop
final canGoBack = context.router.canPop();

// Get current route
final currentRoute = context.router.currentRoute;

// Get current route data
final routeData = context.router.routeData;

// Access current path parameters
final params = context.router.pathParams;

// Access current query parameters
final query = context.router.queryParams;
```

### Navigation Patterns

**Pattern 1: Navigate and Wait for Result**

```dart
// Navigate and wait for user selection
final selectedItem = await context.router.push<Item>('/select-item');

if (selectedItem != null) {
  // Handle selected item
  setState(() {
    this.item = selectedItem;
  });
}

// In the selection page, return result
void onItemSelected(Item item) {
  context.router.pop<Item>(item);
}
```

**Pattern 2: Conditional Navigation**

```dart
void navigateToProfile() {
  if (AuthService.isLoggedIn) {
    context.router.push('/profile');
  } else {
    context.router.push('/login');
  }
}
```

**Pattern 3: Progressive Flows**

```dart
// Step 1
await completeStep1();
context.router.replace('/onboarding/step2');

// Step 2
await completeStep2();
context.router.replace('/onboarding/step3');

// Step 3 (final)
await completeStep3();
context.router.pushAndRemoveAll('/home');
```

**Pattern 4: Safe Pop**

```dart
void handleBackPress() {
  if (hasUnsavedChanges) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Do you want to discard changes?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              context.router.pop(); // Pop route
            },
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  } else if (context.router.canPop()) {
    context.router.pop();
  }
}
```

---

## Returning Results from Routes

Jet Router supports returning results from routes. This allows you to navigate to a route and await a result when it's popped.

### Basic Usage

Navigate to a route with a generic type parameter and await the result:

```dart
// Navigate and await a result
final result = await context.router.push<String>('/edit-profile');
if (result != null) {
  print('Profile updated: $result');
}
```

Return a result when popping:

```dart
// Inside the route, return a result when popping
ElevatedButton(
  onPressed: () {
    context.router.pop('user_updated');
  },
  child: Text('Save'),
)
```

### Type-Safe Results

Results are fully type-safe and work with any type:

```dart
// String results
final message = await context.router.push<String>('/form');

// Boolean results (confirmation dialogs)
final confirmed = await context.router.push<bool>('/confirm-dialog');
if (confirmed == true) {
  // User confirmed the action
}

// Complex objects
final userData = await context.router.push<Map<String, dynamic>>('/picker');

// Custom classes
final product = await context.router.push<Product>('/product-list');
```

### Works with All Navigation Methods

```dart
// Push
final result = await context.router.push<String>('/page');

// Replace
final result = await context.router.replace<bool>('/page');

// Push and remove all
final result = await context.router.pushAndRemoveAll<String>('/page');
```

### Complete Example

**List Page (Caller):**

```dart
class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index].name),
            onTap: () async {
              // Navigate and await result
              final action = await context.router.push<String>(
                '/product-details',
                arguments: products[index],
              );
              
              // Handle the result
              if (action == 'added_to_cart') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to cart')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
```

**Details Page (Returns Result):**

```dart
class ProductDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.router.routeArguments<Product>();
    
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Return a result
              context.router.pop('added_to_cart');
            },
            child: Text('Add to Cart'),
          ),
          OutlinedButton(
            onPressed: () {
              // Cancel without result (returns null)
              context.router.pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
```

### Best Practices

1. **Always check for null** - Results can be null if the user navigates back without providing a value:
   ```dart
   final result = await context.router.push<String>('/page');
   if (result != null) {
     // Handle result
   }
   ```

2. **Check mounted before setState** - When using results in stateful widgets:
   ```dart
   final result = await context.router.push<String>('/page');
   if (mounted && result != null) {
     setState(() {
       _value = result;
     });
   }
   ```

3. **Use appropriate types** - Choose types that make sense:
   - Boolean for confirmations
   - Strings for simple messages
   - Objects for complex data

### How It Works

Under the hood, Jet Router uses Dart's `Completer<T?>` pattern:
1. When pushing a route, a `Completer<T?>` is created
2. The push method returns the completer's future
3. When popped with a result, the completer is completed with that value
4. The awaiting caller receives the result

This provides a clean, type-safe way to handle navigation results.

---

## Parameters & Data Passing

Jet Router supports three ways to pass data between routes: path parameters, query parameters, and custom arguments.

### Path Parameters

Define parameters in the route path using `:paramName` syntax:

**Route Definition:**

```dart
JetRoute(
  path: '/user/:userId',
  builder: (context, data) {
    final userId = data.pathParams['userId']!;
    return UserPage(userId: userId);
  },
)

JetRoute(
  path: '/blog/:category/:postId',
  builder: (context, data) {
    final category = data.pathParams['category']!;
    final postId = data.pathParams['postId']!;
    return BlogPostPage(category: category, postId: postId);
  },
)
```

**Navigation:**

```dart
// Navigate with path parameters
context.router.push('/user/123');
context.router.push('/blog/flutter/awesome-article');
```

**Accessing Parameters:**

```dart
// In the destination page
final userId = context.router.pathParam('userId');

// Or from routeData
final userId = context.router.routeData?.pathParams['userId'];

// Get all path parameters
final params = context.router.pathParams;
// Result: {'userId': '123'}
```

### Query Parameters

Pass data via URL query strings:

**Navigation:**

```dart
// Single query parameter
context.router.push('/search?q=flutter');

// Multiple query parameters
context.router.push('/products?category=mobile&sort=price&order=asc');

// Combine with path parameters
context.router.push('/user/123?tab=profile&edit=true');
```

**Accessing Query Parameters:**

```dart
// In the destination page
final searchQuery = context.router.queryParam('q');
final category = context.router.queryParam('category');
final sort = context.router.queryParam('sort');

// Get all query parameters
final query = context.router.queryParams;
// Result: {'category': 'mobile', 'sort': 'price', 'order': 'asc'}

// With default values
final tab = context.router.queryParam('tab') ?? 'overview';
final pageSize = int.tryParse(context.router.queryParam('size') ?? '10') ?? 10;
```

### Custom Arguments

Pass complex objects or non-serializable data:

**Navigation:**

```dart
// Pass a simple map
context.router.push(
  '/details',
  arguments: {
    'title': 'Product Name',
    'price': 29.99,
    'inStock': true,
  },
);

// Pass custom objects
context.router.push(
  '/edit',
  arguments: UserModel(
    id: '123',
    name: 'John Doe',
    email: 'john@example.com',
  ),
);

// Pass complex data
context.router.push(
  '/checkout',
  arguments: CheckoutData(
    cartItems: [...],
    shippingAddress: address,
    paymentMethod: paymentMethod,
    coupon: activeCoupon,
  ),
);
```

**Accessing Arguments:**

```dart
// Type-safe access
final args = context.router.routeArguments<Map<String, dynamic>>();
final title = args?['title'] as String?;
final price = args?['price'] as double?;

// Custom object
final user = context.router.routeArguments<UserModel>();
if (user != null) {
  print('Editing user: ${user.name}');
}

// Or from routeData
final args = context.router.routeData?.arguments;
```

### Combining All Parameter Types

You can use path parameters, query parameters, and arguments together:

**Navigation:**

```dart
context.router.push(
  '/user/123?tab=posts&filter=recent',
  arguments: {
    'metadata': {'source': 'notification', 'timestamp': DateTime.now()},
    'highlightPostId': '456',
  },
);
```

**Accessing in Destination:**

```dart
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Path parameter
    final userId = context.router.pathParam('userId')!;
    
    // Query parameters
    final tab = context.router.queryParam('tab') ?? 'overview';
    final filter = context.router.queryParam('filter');
    
    // Arguments
    final args = context.router.routeArguments<Map<String, dynamic>>();
    final metadata = args?['metadata'] as Map<String, dynamic>?;
    final highlightPostId = args?['highlightPostId'] as String?;
    
    return Scaffold(
      appBar: AppBar(title: Text('User $userId')),
      body: UserContent(
        userId: userId,
        selectedTab: tab,
        filter: filter,
        highlightPostId: highlightPostId,
      ),
    );
  }
}
```

### RouteData Object

All parameter data is accessible through the `RouteData` object:

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routeData = context.router.routeData;
    
    if (routeData != null) {
      print('Path: ${routeData.path}');
      print('Path params: ${routeData.pathParams}');
      print('Query params: ${routeData.queryParams}');
      print('Arguments: ${routeData.arguments}');
      
      // Helper methods
      final id = routeData.getPathParam('id');
      final query = routeData.getQueryParam('q');
      final args = routeData.getArguments<MyCustomType>();
    }
    
    return Scaffold(...);
  }
}
```

### Best Practices for Data Passing

**✅ Use Path Parameters for:**
- Resource identifiers (user IDs, post IDs, etc.)
- Essential route information
- Data that should be in the URL
- SEO-important content

**✅ Use Query Parameters for:**
- Optional filters and sorting
- Pagination information
- Search queries
- Shareable state

**✅ Use Arguments for:**
- Complex objects
- Non-serializable data
- Large data structures
- Temporary/transient data
- Data that shouldn't be in the URL

**Example:**

```dart
// ✅ Good: Resource ID in path, filters in query, object in arguments
context.router.push(
  '/product/123?color=blue&size=large',
  arguments: ProductDetails(/* complex object */),
);

// ❌ Avoid: Everything in arguments (not deep-linkable)
context.router.push(
  '/product',
  arguments: {'id': '123', 'color': 'blue', 'size': 'large'},
);
```

---

## Route Guards

Route guards protect routes from unauthorized access and can redirect users to appropriate pages based on conditions.

### Creating a Route Guard

Extend the `RouteGuard` abstract class:

```dart
import 'package:flutter/widgets.dart';
import 'package:jet/jet_router.dart';

class AuthGuard extends RouteGuard {
  const AuthGuard();

  @override
  Future<bool> canActivate(BuildContext context, JetRoute route) async {
    // Check if user is authenticated
    final authService = AuthService.instance;
    return authService.isAuthenticated;
  }

  @override
  String? redirect(BuildContext context, JetRoute route) {
    // Redirect to login if not authenticated
    return '/login';
  }
}
```

### Guard Methods

**`canActivate(BuildContext context, JetRoute route)`**

- Returns `true` to allow navigation
- Returns `false` to prevent navigation
- Can be async (return `Future<bool>`)
- Called before the route is activated

**`redirect(BuildContext context, JetRoute route)`**

- Called when `canActivate` returns `false`
- Return a path string to redirect
- Return `null` to stay on current route
- Useful for redirecting to login, unauthorized pages, etc.

### Adding Guards to Routes

```dart
JetRoute(
  path: '/admin',
  builder: (context, data) => const AdminPage(),
  guards: const [AuthGuard()],
)

// Multiple guards (executed in order)
JetRoute(
  path: '/admin/settings',
  builder: (context, data) => const AdminSettingsPage(),
  guards: const [
    AuthGuard(),
    AdminRoleGuard(),
    PermissionGuard('settings.edit'),
  ],
)
```

### Guard Examples

**Example 1: Authentication Guard**

```dart
class AuthGuard extends RouteGuard {
  const AuthGuard();

  @override
  Future<bool> canActivate(BuildContext context, JetRoute route) async {
    final authService = AuthService.instance;
    return authService.isAuthenticated;
  }

  @override
  String? redirect(BuildContext context, JetRoute route) {
    // Save intended route for post-login redirect
    AuthService.instance.setIntendedRoute(route.path);
    return '/login';
  }
}
```


### Multiple Guards

When multiple guards are specified, they are executed in order:

```dart
JetRoute(
  path: '/premium-admin',
  builder: (context, data) => const PremiumAdminPage(),
  guards: const [
    AuthGuard(),                    // 1. Check authentication
    AdminRoleGuard(),               // 2. Check admin role
    SubscriptionGuard('premium'),   // 3. Check premium subscription
  ],
)
```

**Execution flow:**
1. First guard executes `canActivate()`
2. If it returns `false`, `redirect()` is called and navigation stops
3. If it returns `true`, next guard executes
4. Process repeats until all guards pass or one fails

### Guard with Route Metadata

Use route metadata to configure guards:

```dart
class MetadataGuard extends RouteGuard {
  const MetadataGuard();

  @override
  Future<bool> canActivate(BuildContext context, JetRoute route) async {
    final requiredRole = route.meta?['requiredRole'] as String?;
    
    if (requiredRole == null) return true;
    
    final authService = AuthService.instance;
    final user = await authService.getCurrentUser();
    return user?.role == requiredRole;
  }

  @override
  String? redirect(BuildContext context, JetRoute route) {
    return '/unauthorized';
  }
}

// Route definition
JetRoute(
  path: '/admin',
  builder: (context, data) => const AdminPage(),
  guards: const [MetadataGuard()],
  meta: {'requiredRole': 'admin'},
)
```

### Best Practices for Guards

**✅ Do:**
- Keep guards focused and single-purpose
- Make guards reusable across routes
- Use async operations for API checks
- Log guard denials for debugging
- Handle network errors gracefully
- Cache permission checks when appropriate

**❌ Don't:**
- Perform heavy operations in guards (use caching)
- Show UI dialogs from guards (use redirects)
- Modify global state in guards
- Create circular redirect loops
- Ignore errors silently

**Example: Guard with Error Handling**

```dart
class SafeAuthGuard extends RouteGuard {
  const SafeAuthGuard();

  @override
  Future<bool> canActivate(BuildContext context, JetRoute route) async {
    try {
      final authService = AuthService.instance;
      return await authService.isAuthenticated;
    } catch (e) {
      // Log error
      debugPrint('Auth guard error: $e');
      // Fail closed (deny access on error)
      return false;
    }
  }

  @override
  String? redirect(BuildContext context, JetRoute route) {
    return '/login';
  }
}
```

---

## Transitions & Animations

Jet Router supports custom page transitions for smooth navigation experiences.

### Built-in Transition Types

**Fade Transition**

```dart
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.fade(),
)
```

**Slide Transitions**

```dart
// Slide from right (default for iOS)
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.slideRight(),
)

// Slide from left
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.slideLeft(),
)

// Slide from bottom
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.slideUp(),
)

// Slide from top
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.slideDown(),
)
```

**Scale Transition**

```dart
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.scale(),
)
```

**Rotation Transition**

```dart
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.rotation(),
)
```

**No Transition**

```dart
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.none(),
)
```

### Custom Duration and Curves

Customize transition timing:

```dart
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: TransitionType.fade(
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  ),
  // Or use route-level properties
  transitionDuration: const Duration(milliseconds: 300),
  reverseTransitionDuration: const Duration(milliseconds: 200),
  curve: Curves.fastOutSlowIn,
)
```

### Custom Transitions

Create completely custom transitions:

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

### Advanced Custom Transition Examples

**Example 1: Slide and Fade**

```dart
TransitionType.custom(
  builder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    final slideTween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );
    
    final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
    
    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(
        opacity: animation.drive(fadeTween),
        child: child,
      ),
    );
  },
)
```


### Animation Curves

Available curves from Flutter:

```dart
// Common curves
Curves.linear
Curves.easeIn
Curves.easeOut
Curves.easeInOut
Curves.fastOutSlowIn
Curves.bounceIn
Curves.bounceOut
Curves.elasticIn
Curves.elasticOut

// Use in route
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: const TransitionType.slideRight(),
  curve: Curves.fastOutSlowIn,
)
```

### Platform-Specific Transitions

Define different transitions per platform:

```dart
JetRoute(
  path: '/page',
  builder: (context, data) => const MyPage(),
  transition: Platform.isIOS
      ? const TransitionType.slideRight()
      : const TransitionType.fade(),
)
```

### Transition Best Practices

**✅ Do:**
- Use platform-appropriate transitions (slide for iOS, fade for Android)
- Keep durations between 200-400ms for best UX
- Use `easeInOut` or `fastOutSlowIn` curves for natural feel
- Consider reducing motion for accessibility
- Test transitions on actual devices

**❌ Don't:**
- Use overly long transitions (>500ms)
- Combine too many animation effects
- Use jarring or distracting animations
- Ignore platform conventions
- Animate every route change

**Recommended Transition Mapping:**

```dart
// iOS-style (push from right)
TransitionType.slideRight()

// Android-style (fade + scale)
TransitionType.fade()
TransitionType.scale()

// Modal dialogs (slide up from bottom)
TransitionType.slideUp()

// Overlay/Detail pages (fade)
TransitionType.fade()
```

---

## Deep Linking & Web URLs

Jet Router provides full support for deep linking and web URLs, making your app accessible via custom schemes and web links.

### URL Strategy Configuration

Configure how URLs are handled on web:

**Path-Based URLs (Recommended)**

```dart
final jetRouter = JetRouter(
  routes: appRoutes,
  useHashUrl: false,  // Default: clean URLs
);

// Results in URLs like:
// https://myapp.com/profile/123
// https://myapp.com/products?category=electronics
```

**Hash-Based URLs**

```dart
final jetRouter = JetRouter(
  routes: appRoutes,
  useHashUrl: true,  // Use hash-based routing
);

// Results in URLs like:
// https://myapp.com/#/profile/123
// https://myapp.com/#/products?category=electronics
```

### Automatic Deep Link Handling

Jet Router automatically handles deep links when routes are defined:

```dart
// Define routes normally
final appRoutes = [
  JetRoute(
    path: '/',
    builder: (context, data) => const HomePage(),
    initialRoute: true,
  ),
  JetRoute(
    path: '/product/:productId',
    builder: (context, data) {
      final productId = data.pathParams['productId']!;
      return ProductPage(productId: productId);
    },
  ),
];

// These URLs will automatically work:
// myapp.com/product/123
// myapp://product/123 (if custom scheme configured)
```

### Web Platform Considerations

**Setting Up for Web**

1. **Use Path-Based URLs** (recommended for SEO):

```dart
final jetRouter = JetRouter(
  routes: appRoutes,
  useHashUrl: false,
);
```

2. **Configure Web Server** for path-based routing:

For Firebase Hosting (`firebase.json`):

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

For Apache (`.htaccess`):

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

For Nginx:

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

### Mobile Deep Linking

**iOS Configuration**

Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
    <key>CFBundleURLName</key>
    <string>com.example.myapp</string>
  </dict>
</array>
```

**Android Configuration**

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
  android:name=".MainActivity"
  ...>
  <!-- Deep link intent filter -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <!-- Custom scheme -->
    <data android:scheme="myapp" />
  </intent-filter>
  
  <!-- App links (https) -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data android:scheme="https" />
    <data android:host="myapp.com" />
    <data android:pathPrefix="/" />
  </intent-filter>
</activity>
```

### Deep Link Handler

Use `DeepLinkHandler` for custom deep link processing:

```dart
import 'package:jet/jet_router.dart';

final deepLinkHandler = DeepLinkHandler(
  onDeepLink: (Uri uri) async {
    // Process deep link
    print('Received deep link: $uri');
    
    // Extract path and query
    final path = deepLinkHandler.extractPath(uri);
    final params = deepLinkHandler.extractQueryParameters(uri);
    
    // Custom handling logic
    if (path.startsWith('/product/')) {
      // Track analytics
      Analytics.trackDeepLink(path);
    }
  },
);
```

### SEO and Meta Tags

For web apps, ensure proper meta tags in `web/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- SEO -->
  <title>My App</title>
  <meta name="description" content="App description">
  
  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://myapp.com/">
  <meta property="og:title" content="My App">
  <meta property="og:description" content="App description">
  
  <!-- Twitter -->
  <meta property="twitter:card" content="summary_large_image">
  <meta property="twitter:url" content="https://myapp.com/">
  <meta property="twitter:title" content="My App">
  <meta property="twitter:description" content="App description">
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

### Testing Deep Links

**iOS Simulator:**

```bash
xcrun simctl openurl booted "myapp://product/123"
```

**Android Emulator:**

```bash
adb shell am start -W -a android.intent.action.VIEW -d "myapp://product/123" com.example.myapp
```

**Web:**

Simply navigate to the URL in a browser:

```
http://localhost:3000/product/123
```

### Best Practices

**✅ Do:**
- Use path-based URLs for web (better SEO)
- Define all routes that should be deep-linkable
- Test deep links on all platforms
- Configure web server for SPA routing
- Use meaningful, readable URLs
- Handle invalid deep links gracefully

**❌ Don't:**
- Use hash URLs on web unless necessary
- Forget to configure platform-specific deep linking
- Ignore URL validation and error handling
- Use overly complex URL structures
- Include sensitive data in URLs

---

## Advanced Features

### Fullscreen Dialogs

Present routes as fullscreen dialogs (typically used for modal flows):

```dart
JetRoute(
  path: '/create-post',
  builder: (context, data) => const CreatePostPage(),
  fullscreenDialog: true,  // Shows close button instead of back button
  transition: const TransitionType.slideUp(),
)
```

**Characteristics:**
- Close button (X) instead of back arrow in AppBar
- Typically slide up from bottom
- User can cancel the flow
- Common for creation/editing flows

### Pop Gestures

Control iOS swipe-to-pop gestures:

```dart
JetRoute(
  path: '/important-form',
  builder: (context, data) => const ImportantFormPage(),
  popGesture: false,  // Disable swipe-to-pop
)

JetRoute(
  path: '/gallery',
  builder: (context, data) => const GalleryPage(),
  popGesture: true,  // Enable swipe-to-pop (default on iOS)
)
```

**Use cases for disabling:**
- Forms with unsaved changes
- Multi-step flows
- Payment processes
- Critical operations

### Route Maintenance State

Control whether inactive routes maintain their state:

```dart
JetRoute(
  path: '/heavy-page',
  builder: (context, data) => const HeavyPage(),
  maintainState: true,  // Default: keep state when navigating away
)

JetRoute(
  path: '/temporary-page',
  builder: (context, data) => const TemporaryPage(),
  maintainState: false,  // Reset state when navigating away
)
```

### Custom Navigator Key

Access the navigator state externally:

```dart
final navigatorKey = GlobalKey<NavigatorState>();

final jetRouter = JetRouter(
  routes: appRoutes,
  navigatorKey: navigatorKey,
);

// Later, access navigator from anywhere (use sparingly!)
navigatorKey.currentState?.pop();
```

**Note:** Use with caution. Prefer context-based navigation when possible.

### Not Found (404) Routes

Handle invalid routes gracefully:

```dart
final jetRouter = JetRouter(
  routes: appRoutes,
  notFoundRoute: JetRoute(
    path: '/404',
    builder: (context, data) => const NotFoundPage(),
  ),
);
```

**404 Page Example:**

```dart
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final attemptedPath = context.router.routeData?.path ?? 'unknown';
    
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Path: $attemptedPath'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.router.pushAndRemoveAll('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```


### Programmatic Route Access

Access route information programmatically:

```dart
// Get current route
final currentRoute = context.router.currentRoute;
print('Current path: ${currentRoute?.path}');
print('Route name: ${currentRoute?.routeName}');
print('Metadata: ${currentRoute?.meta}');

// Get all routes (via delegate)
final delegate = context.router.delegate;
// Access configuration if needed
```


---

## Best Practices

### Context-Aware Navigation

Always use BuildContext for navigation:

```dart
// ✅ Good: Context-aware
void navigateToProfile(BuildContext context) {
  context.router.push('/profile');
}

// ❌ Avoid: Global access (not used in Jet Router)
// Global navigation calls are not supported
```

### Explicit Dependencies

Pass dependencies explicitly through constructors:

```dart
// ✅ Good: Explicit dependencies
class ProfilePage extends StatelessWidget {
  final String userId;
  final UserRepository userRepository;

  const ProfilePage({
    required this.userId,
    required this.userRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use dependencies
  }
}

// In route
JetRoute(
  path: '/profile/:userId',
  builder: (context, data) {
    final userId = data.pathParams['userId']!;
    return ProfilePage(
      userId: userId,
      userRepository: UserRepository(), // or inject via DI
    );
  },
)

// ❌ Avoid: Service locator
// Global service access is not supported
```

### Guard Organization

Keep guards focused and reusable:

```dart
// ✅ Good: Single-purpose guards
class AuthGuard extends RouteGuard { /* ... */ }
class AdminGuard extends RouteGuard { /* ... */ }
class SubscriptionGuard extends RouteGuard { /* ... */ }

// ✅ Good: Composable guards
JetRoute(
  path: '/premium-admin',
  builder: (context, data) => const PremiumAdminPage(),
  guards: const [
    AuthGuard(),
    AdminGuard(),
    SubscriptionGuard('premium'),
  ],
)

// ❌ Avoid: Monolithic guards
class ComplexGuard extends RouteGuard {
  // Doing too many things
}
```

### Error Handling

Handle navigation errors gracefully:

```dart
void navigateWithErrorHandling(BuildContext context, String path) {
  try {
    context.router.push(path);
  } catch (e) {
    // Log error
    debugPrint('Navigation error: $e');
    
    // Show user-friendly message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: ${e.toString()}')),
      );
    }
  }
}
```

### Route Organization

Organize routes by feature:

```dart
// lib/routes/auth_routes.dart
final authRoutes = [...];

// lib/routes/profile_routes.dart
final profileRoutes = [...];

// lib/routes/app_routes.dart
final appRoutes = [
  homeRoute,
  ...authRoutes,
  ...profileRoutes,
  ...settingsRoutes,
];
```



---


---


---

## Conclusion

Jet Router provides a modern, type-safe, and context-aware routing solution for Flutter applications. By leveraging Navigator 2.0's declarative approach while maintaining a simple API, it offers the best of both worlds: power and simplicity.

### Quick Reference

**Setup:**
```dart
final jetRouter = JetRouter(routes: appRoutes);
MaterialApp.router(routerConfig: jetRouter.routerConfig);
```

**Navigation:**
```dart
context.router.push('/path');
context.router.replace('/path');
context.router.pop();
context.router.pushAndRemoveAll('/path');

// Return results
final result = await context.router.push<String>('/page');
context.router.pop('result_value');
```

**Parameters:**
```dart
final userId = context.router.pathParam('userId');
final query = context.router.queryParam('q');
final args = context.router.routeArguments<MyType>();
```

**Guards:**
```dart
class MyGuard extends RouteGuard {
  Future<bool> canActivate(BuildContext context, JetRoute route) async { }
  String? redirect(BuildContext context, JetRoute route) { }
}
```

### Resources

- [GitHub Repository](https://github.com/your-repo/jetx)
- [Example App](/packages/jet/example/)
- [API Documentation](https://pub.dev/documentation/jet/latest/)

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/your-repo/jetx/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-repo/jetx/discussions)

---

**Made with ❤️ by the Jet team**

