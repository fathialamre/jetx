# Dependency Management

JetX provides a simple and powerful dependency manager that allows you to retrieve the same class as your Controller or Service with just one line of code. No Provider context, no inheritedWidget needed.

---

## Table of Contents

- [Introduction](#introduction)
- [Quick Reference Table](#quick-reference-table)
- [Instancing Methods](#instancing-methods)
- [Using Dependencies](#using-dependencies)
  - [Bindings](#bindings)
- [Common Patterns](#common-patterns)
- [Testing with Dependencies](#testing-with-dependencies)
- [Best Practices](#best-practices)

---

## Introduction

JetX dependency management is decoupled from other parts of the package, so you can use it with any state manager. It provides automatic memory management and intelligent cleanup.

**Key Benefits:**
- 🚀 **No Context Required** - Access dependencies from anywhere
- ⚡ **Automatic Cleanup** - Unused dependencies are removed automatically
- 🎯 **Type Safe** - Full type safety support
- 🔗 **Integrated** - Works seamlessly with state management and routing

```dart
// Register a dependency
Jet.put(ApiController());

// Use it anywhere in your app
final controller = Jet.find<ApiController>();
controller.fetchData();
```

---

## Quick Reference Table

| Method | When to Use | Memory Management | Lifecycle |
|--------|-------------|-------------------|-----------|
| `Jet.put()` | Controllers, Services | Auto-cleanup | Immediate |
| `Jet.lazyPut()` | Heavy services, Optional dependencies | Auto-cleanup | On first use |
| `Jet.putAsync()` | Async initialization (DB, API) | Auto-cleanup | Immediate (async) |
| `Jet.create()` | Unique instances (list items) | Manual | On each access |
| `Jet.find()` | Access any dependency | N/A | N/A |
| `Jet.delete()` | Manual cleanup | Immediate | N/A |

---

## Instancing Methods

### Jet.put()

The most common way of inserting a dependency. Good for controllers and services.

```dart
// Basic usage
Jet.put(ApiController());

// With options
Jet.put<ApiController>(
  ApiController(),
  permanent: true,  // Keep in memory permanently
  tag: "api",       // Unique identifier
);

// All options
Jet.put<S>(
  S dependency,           // Required: the class to register
  String? tag,            // Optional: unique identifier
  bool permanent = false, // Optional: keep permanently
  bool overrideAbstract = false, // Optional: allow override
  InstanceBuilderCallback<S>? builder, // Optional: builder function
)
```

### Jet.lazyPut()

Lazy load a dependency - it will be instantiated only when first used.

```dart
// Basic lazy loading
Jet.lazyPut(() => HeavyService());

// With options
Jet.lazyPut<ApiService>(
  () => ApiService(),
  tag: "api",
  fenix: true,  // Recreate when needed
);

// All options
Jet.lazyPut<S>(
  InstanceBuilderCallback builder, // Required: builder function
  String? tag,                     // Optional: unique identifier
  bool fenix = false,              // Optional: recreate when needed
)
```

### Jet.putAsync()

Register an asynchronous dependency.

```dart
// Async initialization
Jet.putAsync<DatabaseService>(() async {
  final db = DatabaseService();
  await db.initialize();
  return db;
});

// With options
Jet.putAsync<SharedPreferences>(
  () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', 0);
    return prefs;
  },
  tag: "prefs",
  permanent: true,
);
```

### Jet.create()

Create a new instance every time it's accessed. Useful for unique instances.

```dart
// Create unique instances
Jet.create<ProductController>(() => ProductController());

// With options
Jet.create<ItemController>(
  () => ItemController(),
  name: "item",     // Unique name
  permanent: true,  // Keep factory permanently
);
```

---

## Using Dependencies

### Jet.find()

Retrieve a dependency from anywhere in your app.

```dart
// Find by type
final controller = Jet.find<ApiController>();

// Find by tag
final apiController = Jet.find<ApiController>(tag: "api");

// Use the dependency
controller.fetchData();
```

### Jet.delete()

Remove a dependency manually.

```dart
// Delete by type
Jet.delete<ApiController>();

// Delete by tag
Jet.delete<ApiController>(tag: "api");
```

### Dependency Lifecycle

```dart
class MyController extends JetxController {
  @override
  void onInit() {
    super.onInit();
    print('Controller initialized');
  }
  
  @override
  void onClose() {
    print('Controller disposed');
    super.onClose();
  }
}

// Register
Jet.put(MyController()); // onInit() called

// Use
final controller = Jet.find<MyController>();

// Delete (when no longer needed)
Jet.delete<MyController>(); // onClose() called
```

---

## Bindings

Bindings provide a clean way to organize dependencies for specific routes or features.

### Bindings Class

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Jet.lazyPut(() => HomeController());
    Jet.lazyPut(() => HomeService());
    Jet.put(ApiService(), permanent: true);
  }
}

// Use with routes
JetPage(
  name: '/home',
  page: () => HomeScreen(),
  binding: HomeBinding(),
)
```

### BindingsBuilder

Use a function instead of a class for simpler cases.

```dart
JetPage(
  name: '/home',
  page: () => HomeScreen(),
  binding: BindingsBuilder(() {
    Jet.lazyPut(() => HomeController());
    Jet.lazyPut(() => HomeService());
  }),
)
```

### SmartManagement

Control how dependencies are managed.

```dart
JetMaterialApp(
  smartManagement: SmartManagement.full, // Default
  home: HomeScreen(),
)

// Options:
// SmartManagement.full - Auto-cleanup (default)
// SmartManagement.onlyBuilder - Only cleanup JetBuilder dependencies
// SmartManagement.keepFactory - Keep factories for recreation
```

---

## Common Patterns

### Services Pattern

```dart
// Service interface
abstract class ApiService {
  Future<List<User>> getUsers();
}

// Implementation
class ApiServiceImpl implements ApiService {
  @override
  Future<List<User>> getUsers() async {
    // Implementation
    return [];
  }
}

// Register service
Jet.put<ApiService>(ApiServiceImpl());

// Use in controller
class UserController extends JetxController {
  final apiService = Jet.find<ApiService>();
  
  Future<void> loadUsers() async {
    final users = await apiService.getUsers();
    // Handle users
  }
}
```

### Repositories Pattern

```dart
// Repository
class UserRepository {
  final ApiService _apiService;
  
  UserRepository(this._apiService);
  
  Future<List<User>> getUsers() => _apiService.getUsers();
  Future<User> getUser(int id) => _apiService.getUser(id);
}

// Register with dependencies
Jet.lazyPut(() => UserRepository(Jet.find<ApiService>()));

// Use in controller
class UserController extends JetxController {
  final userRepository = Jet.find<UserRepository>();
  
  Future<void> loadUsers() async {
    final users = await userRepository.getUsers();
    // Handle users
  }
}
```

### Controllers Pattern

```dart
// Base controller
abstract class BaseController extends JetxController {
  final ApiService apiService = Jet.find<ApiService>();
  
  Future<void> handleError(dynamic error) {
    Jet.snackbar('Error', error.toString());
  }
}

// Specific controller
class UserController extends BaseController {
  final users = <User>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }
  
  Future<void> loadUsers() async {
    try {
      users.value = await apiService.getUsers();
    } catch (e) {
      handleError(e);
    }
  }
}

// Register
Jet.lazyPut(() => UserController());
```

### Singleton Pattern

```dart
class DatabaseService extends JetxService {
  static DatabaseService? _instance;
  
  DatabaseService._internal();
  
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeDatabase();
  }
  
  Future<void> _initializeDatabase() async {
    // Initialize database
  }
}

// Register as permanent service
Jet.put(DatabaseService.instance, permanent: true);
```

---

## Testing with Dependencies

### Unit Testing

```dart
void main() {
  group('UserController Tests', () {
    late UserController controller;
    late MockApiService mockApiService;
    
    setUp(() {
      mockApiService = MockApiService();
      Jet.put<ApiService>(mockApiService);
      controller = Jet.put(UserController());
    });
    
    tearDown(() {
      Jet.delete<UserController>();
      Jet.delete<ApiService>();
    });
    
    test('should load users successfully', () async {
      // Arrange
      final users = [User(id: 1, name: 'John')];
      when(mockApiService.getUsers()).thenAnswer((_) async => users);
      
      // Act
      await controller.loadUsers();
      
      // Assert
      expect(controller.users.length, 1);
      expect(controller.users.first.name, 'John');
    });
  });
}
```

### Widget Testing

```dart
void main() {
  group('HomeScreen Tests', () {
    testWidgets('should display users', (tester) async {
      // Arrange
      final mockController = MockUserController();
      when(mockController.users).thenReturn([User(id: 1, name: 'John')].obs);
      Jet.put<UserController>(mockController);
      
      // Act
      await tester.pumpWidget(
        JetMaterialApp(home: HomeScreen()),
      );
      
      // Assert
      expect(find.text('John'), findsOneWidget);
    });
  });
}
```

### Integration Testing

```dart
void main() {
  group('App Integration Tests', () {
    testWidgets('should navigate and maintain state', (tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());
      
      // Act
      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Profile Screen'), findsOneWidget);
      
      // Navigate back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      
      // State should be maintained
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
```

### Mock Services

```dart
class MockApiService extends Mock implements ApiService {}

class MockUserController extends Mock implements UserController {
  @override
  final users = <User>[].obs;
  
  @override
  Future<void> loadUsers() async {
    users.value = [User(id: 1, name: 'Mock User')];
  }
}

// Use in tests
Jet.put<ApiService>(MockApiService());
Jet.put<UserController>(MockUserController());
```

---

## Best Practices

### 1. Choose the Right Method

```dart
// ✅ Use Jet.put() for controllers
Jet.put(HomeController());

// ✅ Use Jet.lazyPut() for heavy services
Jet.lazyPut(() => DatabaseService());

// ✅ Use Jet.putAsync() for async initialization
Jet.putAsync(() => SharedPreferences.getInstance());

// ✅ Use Jet.create() for unique instances
Jet.create(() => ProductController());
```

### 2. Organize with Bindings

```dart
// ✅ Group related dependencies
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Jet.lazyPut(() => HomeController());
    Jet.lazyPut(() => HomeService());
  }
}

// ✅ Use with routes
JetPage(
  name: '/home',
  page: () => HomeScreen(),
  binding: HomeBinding(),
)
```

### 3. Memory Management

```dart
// ✅ Use permanent for app-wide services
Jet.put(DatabaseService(), permanent: true);

// ✅ Use lazy loading for optional dependencies
Jet.lazyPut(() => AnalyticsService());

// ✅ Clean up in tests
tearDown(() {
  Jet.reset(); // Clears all dependencies
});
```

### 4. Error Handling

```dart
// ✅ Handle missing dependencies
try {
  final service = Jet.find<ApiService>();
  await service.fetchData();
} catch (e) {
  print('Service not found: $e');
}

// ✅ Provide fallbacks
final service = Jet.find<ApiService>(tag: 'fallback') ?? DefaultApiService();
```

### 5. Testing Best Practices

```dart
// ✅ Reset dependencies between tests
setUp(() {
  Jet.reset();
});

// ✅ Use mocks for external dependencies
Jet.put<ApiService>(MockApiService());

// ✅ Test dependency lifecycle
test('should call onInit when registered', () {
  final controller = Jet.put(TestController());
  expect(controller.isInitialized, true);
});
```

---

## Complete Example

### E-Commerce App Dependencies

```dart
// lib/services/api_service.dart
abstract class ApiService {
  Future<List<Product>> getProducts();
  Future<User> getUser(int id);
}

class ApiServiceImpl implements ApiService {
  @override
  Future<List<Product>> getProducts() async {
    // Implementation
    return [];
  }
  
  @override
  Future<User> getUser(int id) async {
    // Implementation
    return User(id: id, name: 'User $id');
  }
}

// lib/repositories/product_repository.dart
class ProductRepository {
  final ApiService _apiService;
  
  ProductRepository(this._apiService);
  
  Future<List<Product>> getProducts() => _apiService.getProducts();
}

// lib/controllers/product_controller.dart
class ProductController extends JetxController {
  final ProductRepository _repository;
  final products = <Product>[].obs;
  final isLoading = false.obs;
  
  ProductController(this._repository);
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      products.value = await _repository.getProducts();
    } catch (e) {
      Jet.snackbar('Error', 'Failed to load products');
    } finally {
      isLoading.value = false;
    }
  }
}

// lib/bindings/app_binding.dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Jet.put<ApiService>(ApiServiceImpl(), permanent: true);
    
    // Repositories
    Jet.lazyPut(() => ProductRepository(Jet.find<ApiService>()));
    
    // Controllers
    Jet.lazyPut(() => ProductController(Jet.find<ProductRepository>()));
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
      initialBinding: AppBinding(),
      home: HomeScreen(),
    );
  }
}

// lib/screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.find<ProductController>();
    
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('\$${product.price}'),
            );
          },
        );
      }),
    );
  }
}
```

---

## Learn More

- **[State Management](./state_management.md)** - Reactive state management
- **[Route Management](./route_management.md)** - Navigation without context
- **[UI Features](./ui_features.md)** - Dialogs, snackbars, and more
- **[Quick Reference](./quick_reference.md)** - Fast lookup for all features

---

**Ready to manage dependencies like a pro?** [Get started with JetX →](../README.md#quick-start)