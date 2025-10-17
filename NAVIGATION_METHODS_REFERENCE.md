# NavigableRoute Navigation Methods Reference

Complete reference for all navigation methods available in the `NavigableRoute` base class.

## Overview

All generated route classes extend `NavigableRoute`, which provides a rich set of navigation methods. This means every route in your app automatically has these methods available.

```dart
// Generated route class
class UserPageRoute extends NavigableRoute {
  const UserPageRoute({required this.userId});
  final int userId;
  
  @override
  String get path => '/user/$userId';
  
  // All methods below are inherited from NavigableRoute!
}
```

## Basic Navigation Methods

### `push<T>()`

Navigate to the route and add it to the navigation stack.

**Returns:** `Future<T?>?` - Completes when the route is popped with optional result

**Example:**
```dart
// Navigate to user page
await const UserPageRoute(userId: 42).push();

// Navigate and get result
final result = await const SelectionPageRoute().push<String>();
print('Selected: $result');
```

---

### `pushReplacement<T>()`

Replace the current route with this route.

**Returns:** `Future<T?>?` - Completes when the new route is popped

**Example:**
```dart
// Replace current page with home page
const HomePageRoute().pushReplacement();

// After login, replace login page with dashboard
const DashboardPageRoute().pushReplacement();
```

---

## Advanced Navigation Methods

### `pushAndRemoveUntil<T>(predicate)`

Navigate to this route and remove all previous routes until the predicate returns true.

**Parameters:**
- `predicate: bool Function(JetPage)?` - Function that returns true to stop removing routes

**Returns:** `Future<T?>?`

**Example:**
```dart
// Clear all routes and go to home
const HomePageRoute().pushAndRemoveUntil((route) => false);

// Go to settings but keep home in stack
const SettingsPageRoute().pushAndRemoveUntil(
  (route) => route.name == '/home'
);

// After logout, clear stack except splash
const LoginPageRoute().pushAndRemoveUntil(
  (route) => route.name == '/'
);
```

---

### `pushAndRemoveAll<T>()`

Navigate to this route and remove ALL previous routes from the stack.

**Returns:** `Future<T?>?`

**Example:**
```dart
// After logout, clear everything and show login
const LoginPageRoute().pushAndRemoveAll();

// After successful onboarding
const HomePageRoute().pushAndRemoveAll();

// Deep link handling - clear stack and show target
const ProductPageRoute(productId: deepLinkId).pushAndRemoveAll();
```

---

### `pushAndThenPush<T>(predicate, [data])`

Navigate to this route and then conditionally push routes on top.

**Parameters:**
- `predicate: bool Function(JetPage)` - Condition for removing routes
- `data: Object?` - Optional data to pass

**Returns:** `Future<T?>?`

**Example:**
```dart
// Go to home and then show notification
await const HomePageRoute().pushAndThenPush(
  (route) => route.isFirst,
  {'showNotification': true}
);
```

---

## Navigation with Arguments

### `pushWithArgs<T>(arguments)`

Navigate to this route with custom arguments.

**Parameters:**
- `arguments: dynamic` - Any data to pass (accessible via `Jet.arguments`)

**Returns:** `Future<T?>?`

**Example:**
```dart
// Pass extra data to the route
const UserPageRoute(userId: 42).pushWithArgs({
  'source': 'notification',
  'timestamp': DateTime.now(),
});

// In the destination page:
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = Jet.arguments as Map?;
    final source = args?['source']; // 'notification'
    return Scaffold(...);
  }
}
```

---

### `pushReplacementWithArgs<T>(arguments)`

Replace current route with this route and pass custom arguments.

**Parameters:**
- `arguments: dynamic` - Any data to pass

**Returns:** `Future<T?>?`

**Example:**
```dart
// Replace and pass data
const HomePageRoute().pushReplacementWithArgs({
  'refresh': true,
  'showWelcome': false,
});
```

---

### `pushWithParameters<T>(parameters)`

Navigate to this route with additional query parameters.

**Parameters:**
- `parameters: Map<String, String>` - Query parameters to add

**Returns:** `Future<T?>?`

**Example:**
```dart
// Add analytics tracking parameters
const UserPageRoute(userId: 42).pushWithParameters({
  'utm_source': 'email',
  'utm_campaign': 'welcome',
});

// Generated URL: /user/42?utm_source=email&utm_campaign=welcome
```

---

## Utility Methods

### `isActive`

Check if this route is currently the active route.

**Returns:** `bool` - true if this route matches the current route

**Example:**
```dart
// Conditional logic based on current route
if (const HomePageRoute().isActive) {
  print('User is on home page');
}

// Highlight navigation item
bool isSelected = const SettingsPageRoute().isActive;

// Prevent duplicate navigation
if (!const ProfilePageRoute(userId: currentUserId).isActive) {
  const ProfilePageRoute(userId: currentUserId).push();
}
```

---

### `routeName`

Get the route's path/name.

**Returns:** `String` - The path of this route

**Example:**
```dart
final route = const UserPageRoute(userId: 42);
print(route.routeName); // '/user/42'

// Use in logging
logger.log('Navigating to: ${route.routeName}');

// Conditional routing
final targetRoute = isLoggedIn 
  ? const DashboardPageRoute()
  : const LoginPageRoute();
  
print('Target: ${targetRoute.routeName}');
```

---

## Complete Examples

### Authentication Flow

```dart
class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final success = await performLogin();
        if (success) {
          // Clear stack and go to dashboard
          const DashboardPageRoute().pushAndRemoveAll();
        }
      },
      child: Text('Login'),
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await performLogout();
        // Clear everything and show login
        const LoginPageRoute().pushAndRemoveAll();
      },
      child: Text('Logout'),
    );
  }
}
```

---

### Deep Link Handling

```dart
class DeepLinkHandler {
  static void handleDeepLink(Uri uri) {
    if (uri.path.startsWith('/user/')) {
      final userId = int.parse(uri.pathSegments.last);
      
      // Navigate with analytics parameters
      UserPageRoute(userId: userId).pushWithParameters({
        'source': 'deeplink',
        'campaign': uri.queryParameters['campaign'] ?? 'none',
      });
    }
  }
}
```

---

### Navigation with Result

```dart
class SelectColorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final color = await const ColorPickerPageRoute().push<Color>();
        if (color != null) {
          // Use the selected color
          updateThemeColor(color);
        }
      },
      child: Text('Pick Color'),
    );
  }
}
```

---

### Conditional Navigation

```dart
class DashboardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Don't navigate if already on dashboard
        if (const DashboardPageRoute().isActive) {
          return;
        }
        
        // Navigate to dashboard, keep home in stack
        const DashboardPageRoute().pushAndRemoveUntil(
          (route) => route.name == '/home',
        );
      },
      child: Text('Go to Dashboard'),
    );
  }
}
```

---

### Navigation with Tracking

```dart
class TrackedNavigation {
  static Future<T?> navigateWithAnalytics<T>(
    NavigableRoute route,
    String screenName,
  ) async {
    // Log navigation event
    analytics.logEvent('screen_view', {
      'screen_name': screenName,
      'route': route.routeName,
    });
    
    // Navigate
    return await route.push<T>();
  }
}

// Usage
TrackedNavigation.navigateWithAnalytics(
  const UserPageRoute(userId: 42),
  'UserProfile',
);
```

---

## Method Comparison Table

| Method | Stack Behavior | Use Case |
|--------|---------------|----------|
| `push()` | Adds to stack | Normal navigation |
| `pushReplacement()` | Replaces current | After form submission |
| `pushAndRemoveUntil()` | Removes until condition | Logout, deep links |
| `pushAndRemoveAll()` | Clears entire stack | Login/logout, onboarding |
| `pushWithArgs()` | Adds with data | Pass extra metadata |
| `pushWithParameters()` | Adds with query params | Analytics, tracking |

---

## Best Practices

1. **Use `pushAndRemoveAll()` for major flow changes**
   ```dart
   // Good: Clear stack on logout
   const LoginPageRoute().pushAndRemoveAll();
   ```

2. **Use `pushWithArgs()` for optional data**
   ```dart
   // Good: Pass extra context
   const PageRoute().pushWithArgs({'context': 'from_notification'});
   ```

3. **Check `isActive` to prevent duplicate navigation**
   ```dart
   // Good: Avoid pushing same route twice
   if (!route.isActive) {
     route.push();
   }
   ```

4. **Use `pushAndRemoveUntil()` for structured flows**
   ```dart
   // Good: Maintain specific stack structure
   const SuccessPageRoute().pushAndRemoveUntil(
     (route) => route.name == '/home',
   );
   ```

---

## Summary

The `NavigableRoute` base class provides **10 navigation methods** and **2 utility properties**, giving you complete control over navigation in your JetX app with a clean, type-safe API.

All methods return nullable Futures to match JetX's navigation API, and all methods support generic type parameters for receiving results from popped routes.

