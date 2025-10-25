# JetX v2.0.0 Migration Guide

Welcome to JetX v2.0.0! This is a major architectural update that addresses the core issues of GetX while keeping the parts that work well (reactive state, animations, utilities).

## What Changed and Why

JetX v2.0.0 removes the anti-patterns from GetX and introduces modern, testable alternatives:

| Old Pattern (GetX/JetX v1) | New Pattern (JetX v2) | Why? |
|----------------------------|----------------------|------|
| `Jet.find<T>()` | `context.resolve<T>()` | Explicit dependencies, easier testing |
| `Jet.put(controller)` | `ControllerProvider` | No global state, scoped lifecycles |
| `Jet.to(Page())` | `context.router.push('/path')` | Context-aware, follows Flutter patterns |
| Tag-based instances | Named registrations | Type-safe with enums, clearer intent |

## Quick Migration Checklist

- [ ] Replace `Jet.put()` / `Jet.find()` with `JetContainer` and `ControllerProvider`
- [ ] Replace `Jet.to()` / `Jet.back()` with `context.router.*` 
- [ ] Replace `JetMaterialApp` with `JetRouterApp`
- [ ] Wrap app with `JetContainerProvider`
- [ ] Update tests to use explicit dependencies
- [ ] Remove `Get.testMode` and `Get.reset()` from tests

## Migration Guides

Choose the guide relevant to your needs:

1. [Dependency Injection Migration](#1-dependency-injection-migration)
2. [Router Migration](#2-router-migration)
3. [State Management Migration](#3-state-management-migration)
4. [Testing Migration](#4-testing-migration)

---

## 1. Dependency Injection Migration

### Problem with Old Approach

```dart
// ❌ Old way - Hidden dependencies, global state
class HomeController extends JetxController {
  void doSomething() {
    final api = Jet.find<ApiService>(); // Where did this come from?
    api.fetchData();
  }
}

// Registration happened somewhere else in the app
void main() {
  Jet.put(ApiService()); // Global registration
  runApp(MyApp());
}
```

**Issues:**
- Dependencies are hidden
- Hard to test (need to mock global state)
- Can't tell what a class needs by looking at it

### New Approach - Explicit Container

```dart
// ✅ New way - Explicit dependencies, no global state
class HomeController extends JetxController {
  final ApiService api;
  
  HomeController({required this.api}); // Dependency is explicit!
  
  void doSomething() {
    api.fetchData();
  }
}

// Setup
void main() {
  final container = JetContainer();
  container.registerSingleton<ApiService>(() => ApiService());
  
  runApp(
    JetContainerProvider(
      container: container,
      child: MyApp(),
    ),
  );
}

// In your widget
ControllerProvider<HomeController>(
  create: (context) => HomeController(
    api: context.resolve<ApiService>(), // Explicit!
  ),
  child: HomePage(),
)
```

### Multiple Instances (Tags Replacement)

```dart
// ❌ Old way with tags
Jet.put(ApiService(baseUrl: 'prod'), tag: 'prod');
Jet.put(ApiService(baseUrl: 'dev'), tag: 'dev');
final api = Jet.find<ApiService>(tag: 'prod');

// ✅ New way with named registrations
container.register<ApiService>('prod', () => ApiService(baseUrl: 'prod'));
container.register<ApiService>('dev', () => ApiService(baseUrl: 'dev'));
final api = container.resolve<ApiService>('prod');

// ✅ Even better: Type-safe with enums
enum Environment { prod, dev, staging }

container.registerNamed<ApiService>(
  Environment.prod,
  () => ApiService(baseUrl: 'prod'),
);

final api = container.resolveNamed<ApiService>(Environment.prod);
```

### Scoped Dependencies

```dart
// Feature-specific dependencies
final featureContainer = appContainer.createScope();
featureContainer.register<FeatureService>(() => FeatureService());

JetContainerProvider(
  container: featureContainer,
  child: FeatureWidget(),
)
```

---

## 2. Router Migration

### Problem with Old Approach

```dart
// ❌ Old way - Context-free navigation (anti-pattern)
class ProfileController extends JetxController {
  void goToSettings() {
    Jet.to(SettingsPage()); // No context, hard to test
  }
}
```

**Issues:**
- Violates Flutter's architecture
- Hard to test
- No compile-time safety

### New Approach - Context-Aware Router

#### Step 1: Define Routes

```dart
final routes = [
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
  ),
  JetRoute(
    path: '/settings',
    builder: (context, data) => SettingsPage(),
    guards: [AuthGuard()], // Protect with authentication
  ),
];
```

#### Step 2: Setup App

```dart
void main() {
  final container = JetContainer();
  // Register dependencies...
  
  runApp(
    JetContainerProvider(
      container: container,
      child: JetRouterApp(
        title: 'My App',
        routes: routes,
        theme: ThemeData.light(),
      ),
    ),
  );
}
```

#### Step 3: Navigate with Context

```dart
// ❌ Old way
Jet.to(ProfilePage());
Jet.back();
Jet.off(LoginPage());

// ✅ New way
context.router.push('/profile/123');
context.router.pop();
context.router.replace('/login');
```

### Navigation with Results

```dart
// Navigate and wait for result
final result = await context.router.push<String>('/edit-profile');
if (result != null) {
  print('Profile updated: $result');
}

// Return result when popping
ElevatedButton(
  onPressed: () {
    context.router.pop('changes_saved');
  },
  child: Text('Save'),
)
```

### Route-Scoped Dependencies

```dart
class ProfileBindings extends RouteBindings {
  @override
  void dependencies(JetContainer container) {
    container.register<ProfileService>(() => ProfileService());
    container.register<ProfileController>(
      () => ProfileController(
        service: container.resolve<ProfileService>(),
      ),
    );
  }
}

JetRoute(
  path: '/profile/:userId',
  builder: (context, data) => ProfilePage(),
  bindings: ProfileBindings(), // Scoped to this route
)
```

---

## 3. State Management Migration

### Reactive State (No Changes!)

The reactive state system (`.obs`, `Obx`, `RxInt`, etc.) stays the same! Only the access pattern changes.

```dart
// ✅ Still works the same
class CounterController extends JetxController {
  final count = 0.obs;
  
  void increment() => count++;
}

// ✅ Still works the same
Widget build(BuildContext context) {
  final controller = context.controller<CounterController>();
  return Obx(() => Text('${controller.count}'));
}
```

### Controller Access Pattern

```dart
// ❌ Old way - Global access
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.find<HomeController>(); // Hidden dependency
    return Text('${controller.title}');
  }
}

// ✅ New way - Explicit from tree
ControllerProvider<HomeController>(
  create: (context) => HomeController(),
  child: MyWidget(),
)

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.controller<HomeController>(); // Explicit!
    return Text('${controller.title}');
  }
}
```

### Lifecycle Configuration

```dart
ControllerProvider<HomeController>(
  create: (context) => HomeController(),
  lifecycle: LifecycleConfig.automatic, // Default: dispose when widget unmounts
  child: HomePage(),
)

// Other options:
// LifecycleConfig.manual - you control lifecycle
// LifecycleConfig.routeBound - tied to route lifecycle
```

---

## 4. Testing Migration

### Old Testing Pattern

```dart
// ❌ Old way - Global state, hard to mock
void main() {
  setUp(() {
    Get.testMode = true;
  });
  
  tearDown(() {
    Get.reset();
  });
  
  test('controller test', () {
    Jet.put(MockApiService());
    final controller = Jet.put(HomeController());
    controller.fetchData();
    expect(controller.data.value, isNotEmpty);
  });
}
```

### New Testing Pattern

```dart
// ✅ New way - Explicit dependencies, easy to mock
void main() {
  test('controller test', () {
    final mockApi = MockApiService();
    final controller = HomeController(api: mockApi);
    
    controller.onStart(); // Manually trigger lifecycle
    controller.fetchData();
    
    expect(controller.data.value, isNotEmpty);
    
    controller.onDelete(); // Manually cleanup
  });
}
```

### Widget Testing

```dart
testWidgets('MyWidget test', (tester) async {
  // Create test container with mocks
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
  
  // Test as normal
  expect(find.text('Home'), findsOneWidget);
});
```

---

## What Stays the Same

✅ **Reactive System**: `.obs`, `Obx`, `RxInt`, `RxString` - unchanged  
✅ **JetConnect**: HTTP and WebSocket client - unchanged  
✅ **Internationalization**: `.tr` extensions - unchanged  
✅ **Utilities**: Platform detection, extensions - unchanged  
✅ **Animations**: JetAnimations - unchanged  

---

## Benefits of Migration

1. **Testability**: No global state to mock
2. **Maintainability**: Dependencies are explicit and visible
3. **Scalability**: Scoped containers prevent conflicts
4. **Type Safety**: Enum-based named registrations
5. **Flutter Best Practices**: Follows official recommendations
6. **Predictable**: No magic lifecycle management

---

## Getting Help

- Check the [Best Practices Guide](./best_practices.md)
- Review the [Example App](../../example/)
- Open an issue on GitHub

---

## Timeline

- **Now**: v2.0.0 released, old APIs removed
- **Migration period**: Update your app using this guide
- **Future**: Continue improving and adding features

Welcome to the new JetX! 🚀

