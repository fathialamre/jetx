# JetX Best Practices

This guide provides recommended patterns for building maintainable, testable applications with JetX v2.0.0.

## Table of Contents

1. [Dependency Injection Best Practices](#dependency-injection-best-practices)
2. [State Management Best Practices](#state-management-best-practices)
3. [Navigation Best Practices](#navigation-best-practices)
4. [Testing Best Practices](#testing-best-practices)
5. [Project Structure](#project-structure)
6. [Performance Tips](#performance-tips)

---

## Dependency Injection Best Practices

### 1. Register Dependencies at the Right Level

```dart
// ✅ GOOD: Register global dependencies in main()
void main() {
  final container = JetContainer();
  
  // Core services needed everywhere
  container.registerSingleton<Database>(() => Database());
  container.registerSingleton<AuthService>(() => AuthService());
  
  runApp(JetContainerProvider(
    container: container,
    child: MyApp(),
  ));
}

// ✅ GOOD: Register feature-specific dependencies in route bindings
class ProfileBindings extends RouteBindings {
  @override
  void dependencies(JetContainer container) {
    // Only available on profile route
    container.register<ProfileService>(() => ProfileService());
  }
}
```

### 2. Use Named Registrations with Enums

```dart
// ✅ GOOD: Type-safe with enums
enum Environment { prod, dev, staging }

container.registerNamed<ApiService>(
  Environment.prod,
  () => ApiService(baseUrl: 'https://api.prod.com'),
);

final api = container.resolveNamed<ApiService>(Environment.prod);

// ❌ BAD: String-based (typo-prone)
container.register<ApiService>('prod', () => ApiService(...));
final api = container.resolve<ApiService>('prod'); // Easy to typo
```

### 3. Make Dependencies Explicit in Constructors

```dart
// ✅ GOOD: Dependencies are clear
class HomeController extends JetxController {
  final ApiService api;
  final Database db;
  
  HomeController({
    required this.api,
    required this.db,
  });
  
  // Anyone reading this knows what HomeController needs
}

// ❌ BAD: Hidden dependencies
class HomeController extends JetxController {
  void doSomething() {
    final api = Jet.find<ApiService>(); // Where did this come from?
  }
}
```

### 4. Use registerWithContainer for Complex Dependencies

```dart
// ✅ GOOD: Resolve dependencies during registration
container.registerSingleton<Database>(() => Database());
container.registerWithContainer<UserRepository>(
  (c) => UserRepository(
    database: c.resolve<Database>(),
  ),
);
```

---

## State Management Best Practices

### 1. Choose the Right Controller Lifecycle

```dart
// ✅ GOOD: Automatic lifecycle for normal widgets
ControllerProvider<HomeController>(
  create: (context) => HomeController(),
  lifecycle: LifecycleConfig.automatic, // Default: disposes with widget
  child: HomePage(),
)

// ✅ GOOD: Route-bound for screen controllers
JetRoute(
  path: '/profile',
  builder: (context, data) => ProfilePage(),
  // ⚠️ DEPRECATED: bindings is deprecated, use binds instead
  // bindings: ProfileBindings(), // Disposed when route is popped
  binds: ProfileBindings().dependencies(), // ✅ Use this instead
)

// ✅ GOOD: Manual for shared controllers
ControllerProvider<ThemeController>(
  create: (context) => ThemeController(),
  lifecycle: LifecycleConfig.manual, // You control disposal
  child: MyApp(),
)
```

### 2. Keep Controllers Focused

```dart
// ✅ GOOD: Single responsibility
class UserProfileController extends JetxController {
  final user = Rx<User?>(null);
  
  void updateProfile(User newUser) {
    user.value = newUser;
  }
}

// ❌ BAD: Too many responsibilities
class MegaController extends JetxController {
  // User management
  final user = Rx<User?>(null);
  
  // Theme management
  final isDark = false.obs;
  
  // Navigation logic
  void goToSettings() { ... }
  
  // API calls
  void fetchEverything() { ... }
}
```

### 3. Use Computed Values for Derived State

```dart
class CartController extends JetxController {
  final items = <CartItem>[].obs;
  
  // ✅ GOOD: Computed property
  double get total => items.fold(0, (sum, item) => sum + item.price);
  
  // ❌ BAD: Manually updated duplicate state
  // final total = 0.0.obs;
  // void updateTotal() { total.value = ...; } // Easy to forget
}
```

### 4. Clean Up in onClose()

```dart
class StreamController extends JetxController {
  StreamSubscription? _subscription;
  final TextEditingController textController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    _subscription = myStream.listen(_handleData);
  }
  
  @override
  void onClose() {
    // ✅ GOOD: Clean up all resources
    _subscription?.cancel();
    textController.dispose();
    super.onClose();
  }
}
```

---

## Navigation Best Practices

### 1. Define Routes in a Central Location

```dart
// ✅ GOOD: routes.dart
final appRoutes = [
  JetRoute(
    path: '/',
    builder: (context, data) => HomePage(),
    initialRoute: true,
  ),
  JetRoute(
    path: '/profile/:userId',
    builder: (context, data) => ProfilePage(
      userId: data.pathParams['userId']!,
    ),
    guards: [AuthGuard()],
  ),
];
```

### 2. Use Path Parameters for Dynamic Routes

```dart
// ✅ GOOD: Path parameters
JetRoute(
  path: '/user/:userId/post/:postId',
  builder: (context, data) {
    final userId = data.pathParams['userId']!;
    final postId = data.pathParams['postId']!;
    return PostDetailPage(userId: userId, postId: postId);
  },
)

// ❌ BAD: Everything in arguments (not web-friendly)
JetRoute(
  path: '/post',
  builder: (context, data) {
    final args = data.arguments as Map;
    return PostDetailPage(/* ... */);
  },
)
```

### 3. Use Route Guards for Authentication

```dart
class AuthGuard extends RouteGuard {
  @override
  Future<bool> canActivate(BuildContext context, JetRoute route) async {
    final authService = context.resolve<AuthService>();
    return authService.isAuthenticated;
  }
  
  @override
  String? redirect(BuildContext context, JetRoute route) {
    return '/login'; // Redirect if not authenticated
  }
}

JetRoute(
  path: '/dashboard',
  builder: (context, data) => DashboardPage(),
  guards: [AuthGuard()],
)
```

### 4. Handle Navigation Results

```dart
// ✅ GOOD: Await results from navigation
Future<void> editProfile() async {
  final result = await context.router.push<bool>('/edit-profile');
  
  if (result == true) {
    showSnackBar('Profile updated successfully');
    refreshProfile();
  }
}

// In the edit page
ElevatedButton(
  onPressed: () {
    saveProfile();
    context.router.pop(true); // Return success
  },
  child: Text('Save'),
)
```

---

## Testing Best Practices

### 1. Test Controllers in Isolation

```dart
test('increment increases count', () {
  // ✅ GOOD: No global state needed
  final controller = CounterController();
  
  controller.onStart(); // Manually trigger lifecycle
  expect(controller.count.value, 0);
  
  controller.increment();
  expect(controller.count.value, 1);
  
  controller.onDelete(); // Cleanup
});
```

### 2. Mock Dependencies with Container

```dart
class MockApiService extends Mock implements ApiService {}

test('controller with dependencies', () {
  final mockApi = MockApiService();
  final controller = HomeController(api: mockApi);
  
  when(mockApi.fetchData()).thenAnswer((_) async => ['data']);
  
  controller.onStart();
  await controller.loadData();
  
  expect(controller.data.value, ['data']);
  verify(mockApi.fetchData()).called(1);
  
  controller.onDelete();
});
```

### 3. Widget Testing with Container

```dart
testWidgets('HomePage displays data', (tester) async {
  // Setup test container
  final testContainer = JetContainer();
  testContainer.registerInstance<ApiService>(MockApiService());
  
  await tester.pumpWidget(
    JetContainerProvider(
      container: testContainer,
      child: MaterialApp(
        home: ControllerProvider<HomeController>(
          create: (context) => HomeController(
            api: context.resolve<ApiService>(),
          ),
          child: HomePage(),
        ),
      ),
    ),
  );
  
  expect(find.text('Home'), findsOneWidget);
});
```

### 4. Test Navigation Without Context

```dart
test('controller handles navigation logic', () {
  final controller = ProfileController();
  
  // ✅ GOOD: Test the logic, not the navigation
  expect(controller.shouldShowOnboarding(), true);
  expect(controller.getNextRoute(), '/onboarding');
  
  // Let the widget/integration test handle actual navigation
});
```

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── routes.dart              # All route definitions
│   ├── bindings/                # Route bindings
│   │   ├── home_bindings.dart
│   │   └── profile_bindings.dart
│   └── theme/
│       └── app_theme.dart
├── core/
│   ├── services/                # Global services
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── database_service.dart
│   └── guards/                  # Route guards
│       └── auth_guard.dart
├── features/
│   ├── home/
│   │   ├── controllers/
│   │   │   └── home_controller.dart
│   │   ├── views/
│   │   │   └── home_page.dart
│   │   └── widgets/
│   │       └── home_widget.dart
│   ├── profile/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   └── settings/
│       ├── controllers/
│       ├── views/
│       └── widgets/
└── shared/
    ├── widgets/             # Reusable widgets
    └── models/              # Data models
```

---

## Performance Tips

### 1. Use Obx Sparingly

```dart
// ✅ GOOD: Only wraps what changes
Widget build(BuildContext context) {
  final controller = context.controller<HomeController>();
  
  return Column(
    children: [
      Text('Static title'), // No Obx needed
      Obx(() => Text('Count: ${controller.count}')), // Only this rebuilds
    ],
  );
}

// ❌ BAD: Wraps entire tree unnecessarily
Widget build(BuildContext context) {
  final controller = context.controller<HomeController>();
  
  return Obx(() => Column( // Entire column rebuilds for any change
    children: [
      Text('Static title'),
      Text('Count: ${controller.count}'),
    ],
  ));
}
```

### 2. Use Lazy Registration for Heavy Objects

```dart
// ✅ GOOD: Only created when first needed
container.registerSingleton<HeavyService>(() => HeavyService());

// ❌ BAD: Created immediately even if never used
container.registerInstance<HeavyService>(HeavyService());
```

### 3. Dispose Controllers You Don't Need

```dart
// ✅ GOOD: Automatic disposal
ControllerProvider<TempController>(
  create: (context) => TempController(),
  lifecycle: LifecycleConfig.automatic, // Cleaned up automatically
  child: TempWidget(),
)
```

---

## Common Patterns

### Repository Pattern

```dart
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> updateUser(User user);
}

class ApiUserRepository implements UserRepository {
  final ApiService api;
  
  ApiUserRepository({required this.api});
  
  @override
  Future<User> getUser(String id) => api.get('/users/$id');
  
  @override
  Future<void> updateUser(User user) => api.put('/users/${user.id}', user);
}

// Register in container
container.registerSingletonWithContainer<UserRepository>(
  (c) => ApiUserRepository(api: c.resolve<ApiService>()),
);
```

### Loading State Pattern

```dart
class DataController extends JetxController {
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final data = Rx<List<Item>?>(null);
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = null;
      data.value = await api.fetchData();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

// In widget
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  if (controller.error.value != null) {
    return Text('Error: ${controller.error.value}');
  }
  return ListView(children: ...);
})
```

---

## Summary

- **DI**: Make dependencies explicit, use enums for names, scope appropriately
- **State**: Keep controllers focused, clean up resources, use computed values
- **Navigation**: Define routes centrally, use path params, guard sensitive routes
- **Testing**: Mock dependencies with container, test logic in isolation
- **Structure**: Organize by feature, separate concerns
- **Performance**: Use Obx sparingly, lazy load heavy objects

Following these practices will help you build maintainable, testable, and performant JetX applications! 🚀

