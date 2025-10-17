# JetX

[![pub package](https://img.shields.io/pub/v/jetx.svg?label=jetx&color=blue)](https://pub.dev/packages/jetx)
[![popularity](https://img.shields.io/pub/popularity/jetx?logo=dart)](https://pub.dev/packages/jetx/score)
[![likes](https://img.shields.io/pub/likes/jetx?logo=dart)](https://pub.dev/packages/jetx/score)
[![pub points](https://img.shields.io/pub/points/jetx?logo=dart)](https://pub.dev/packages/jetx/score)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)

**A modern, powerful, and lightweight Flutter framework for state management, dependency injection, and route management.**

*jetx is an actively maintained and enhanced fork of GetX, bringing improved performance, better organization, and modern Flutter practices.*

---

## Table of Contents

- [What is JetX?](#what-is-jetx)
- [🆕 What's New in JetX](#-whats-new-in-jetx)
- [Quick Start](#quick-start)
- [Core Features](#core-features)
  - [State Management](#state-management)
  - [Route Management](#route-management)
  - [Dependency Injection](#dependency-injection)
- [UI Features](#ui-features)
  - [Theming](#theming)
  - [Dialogs & Snackbars](#dialogs--snackbars)
  - [Context Extensions](#context-extensions)
- [Additional Features](#additional-features)
  - [Internationalization](#internationalization)
  - [JetNetworking - HTTP Client with Dio](#jetnetworking---http-client-with-dio)
  - [Middleware](#middleware)
- [Advanced Topics](#advanced-topics)
  - [Local State Widgets](#local-state-widgets)
  - [JetView, JetWidget & JetxService](#jetview-jetwidget--jetxservice)
  - [StateMixin](#statemixin)
  - [Reactive Programming Deep Dive](#reactive-programming-deep-dive)
  - [Testing](#testing)
- [Complete Guides](#complete-guides)
  - [Networking Guide](#networking-guide)
  - [State Management Guide](#state-management-guide)
  - [Route Management Guide](#route-management-guide)
  - [Dependency Management Guide](#dependency-management-guide)
  - [Internationalization Guide](#internationalization-guide)
  - [UI Features Guide](#ui-features-guide)
  - [Quick Reference](#quick-reference)
- [Migration Guide](#migration-guide)
- [Why JetX?](#why-jetx)
- [Community & Contributing](#community--contributing)

---

## What is JetX?

jetx combines **high-performance state management**, **intelligent dependency injection**, and **intuitive route management** into a single, cohesive package for Flutter.

**Three Core Principles:**

- **🚀 Performance** - No Streams or ChangeNotifier overhead. Minimal resource consumption.
- **⚡ Productivity** - Simple, elegant syntax that saves hours of development time.
- **📦 Organization** - Complete decoupling of UI, business logic, and navigation. No context needed.

jetx is modular by design. Use only what you need—if you only use state management, only that code is compiled. Each feature is independently usable without bloating your app.

---

## 🆕 What's New in JetX

JetX introduces powerful new reactive programming features that significantly enhance developer productivity and code quality. These features are **not available in the original GetX**.

### ✨ Computed Values - Automatic Derived State

Create reactive values that automatically recompute when dependencies change - no manual updates needed!

```dart
class CartController extends JetxController {
  final items = <Item>[].obs;
  final taxRate = 0.08.obs;
  
  // Automatically recomputes when items change!
  late final subtotal = computed(
    () => items.fold(0.0, (sum, item) => sum + item.price),
    watch: [items],
  );
  
  // Chain computed values
  late final tax = computed(
    () => subtotal.value * taxRate.value,
    watch: [subtotal, taxRate],
  );
  
  late final total = computed(
    () => subtotal.value + tax.value,
    watch: [subtotal, tax],
  );
}

// UI updates automatically when items or taxRate changes!
Obx(() => Text('Total: \$${controller.total.value}'))
```

### ✨ Reactive Operators - Functional Transformations

Transform, filter, and combine reactive values with ease.

```dart
// Transform
final temperature = 0.obs;
final fahrenheit = temperature.map((c) => c * 9/5 + 32);

// Filter
final input = ''.obs;
final validInput = input.where((text) => text.length >= 3);

// Combine
final firstName = 'John'.obs;
final lastName = 'Doe'.obs;
final fullName = Rx.combine2(
  firstName, lastName,
  (a, b) => '$a $b',
);

// Accumulate
final events = 0.obs;
final totalEvents = events.scan<int>(
  0,
  (total, event, i) => total + event,
);
```

### ✨ Stream Integration - Seamless Stream Binding

Bridge the gap between reactive programming and stream-based APIs.

```dart
// Auto-managed
final status = Rx.fromStream(statusStream, initial: Status.idle);

// Manual management in controllers
class ChatController extends JetxController {
  final messages = <Message>[].obs;
  late StreamSubscription _sub;
  
  @override
  void onInit() {
    super.onInit();
    _sub = messages.listenToStream(chatService.messagesStream);
  }
  
  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}
```

### 🚀 Why These Features Matter

- **🚀 Zero Boilerplate** - No manual state synchronization
- **⚡ Performance** - Only recomputes when dependencies change
- **🔗 Declarative** - Clean, functional programming patterns
- **🛡️ Type Safe** - Full type safety and null safety support
- **🧪 Testable** - Easy to test with predictable behavior

---

## Quick Start

### Installation

Add JetX to your `pubspec.yaml`:

```yaml
dependencies:
  jetx: ^0.1.0-alpha.1
```

Import JetX in your files:

```dart
import 'package:jetx/jetx.dart';
```

### Counter App Example

> **The power of JetX in 26 lines of code** - A complete counter app with state management, navigation, and shared state between screens.

**Step 1:** Wrap your `MaterialApp` with `JetMaterialApp`

```dart
void main() => runApp(JetMaterialApp(home: Home()));
```

> **Note:** `JetMaterialApp` is a pre-configured MaterialApp. It's only required if you use route management (`Jet.to()`, `Jet.back()`, etc.). For state management alone, it's optional.

**Step 2:** Create your controller with observable variables

```dart
class Controller extends JetxController {
  var count = 0.obs;
  increment() => count++;
}
```

**Step 3:** Build your view with reactive updates

```dart
class Home extends StatelessWidget {
  @override
  Widget build(context) {
    // Register controller
    final Controller c = Jet.put(Controller());

    return Scaffold(
      // Auto-updates when count changes
      appBar: AppBar(title: Obx(() => Text("Clicks: ${c.count}"))),
      
      body: Center(
        child: ElevatedButton(
          child: Text("Go to Other"),
          onPressed: () => Jet.to(Other()), // Navigate without context!
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: c.increment,
      ),
    );
  }
}

class Other extends StatelessWidget {
  // Find the existing controller
  final Controller c = Jet.find();

  @override
  Widget build(context) {
    // Access the same count value
    return Scaffold(
      body: Center(child: Obx(() => Text("${c.count}"))),
    );
  }
}
```

**That's it!** State management, navigation, and dependency injection working together seamlessly.

### Key Concepts at a Glance

| Feature | How to Use |
|---------|-----------|
| **Make variable reactive** | `var name = 'John'.obs;` |
| **Update UI automatically** | `Obx(() => Text(controller.name))` |
| **Navigate to screen** | `Jet.to(NextScreen());` |
| **Navigate with name** | `Jet.toNamed('/details');` |
| **Go back** | `Jet.back();` |
| **Register dependency** | `Jet.put(Controller());` |
| **Find dependency** | `Jet.find<Controller>();` |
| **Show snackbar** | `Jet.snackbar('Title', 'Message');` |
| **Show dialog** | `Jet.dialog(AlertDialog(...));` |

---

## Core Features

### State Management

> **TL;DR:** Add `.obs` to make variables reactive, wrap widgets in `Obx()` to auto-update. No code generators, no boilerplate.

jetx offers powerful state management with **new reactive features not available in GetX**:

- **Simple State Manager** (`JetBuilder`) - Lightweight, manual control
- **Reactive State Manager** (`Obx`) - Automatic updates when observables change
- **🆕 Advanced Reactive Features** - Computed values, operators, stream integration

#### Reactive Example

```dart
// In your controller
var name = 'John'.obs;

// In your UI
Obx(() => Text(name.value));
```

When `name` changes, the UI updates automatically. No `setState()`, no `StreamBuilder`, no complications.

#### 🆕 Advanced Reactive Features

**Computed Values** - Automatic derived state:
```dart
late final total = computed(
  () => items.fold(0.0, (sum, item) => sum + item.price),
  watch: [items],
);
```

**Reactive Operators** - Transform, filter, combine:
```dart
final validInput = input.where((text) => text.length >= 3);
final fullName = Rx.combine2(firstName, lastName, (a, b) => '$a $b');
```

**Stream Integration** - Seamless stream binding:
```dart
final status = Rx.fromStream(statusStream, initial: Status.idle);
```

#### Quick Reference

```dart
// Make it observable
var count = 0.obs;
var name = 'John'.obs;
var isLogged = false.obs;
var list = [].obs;

// Update values
count.value = 10;
count++;                    // Works directly!
name.value = 'Jane';
isLogged.toggle();         // Toggles true/false
list.add('item');          // List updates are reactive too
```

---

### Route Management

> **TL;DR:** Navigate without context. Use `Jet.to()`, `Jet.back()`, and named routes. Simple and powerful.

#### Basic Navigation

```dart
// Navigate to next screen
Jet.to(NextScreen());

// Navigate with name
Jet.toNamed('/profile');

// Go back
Jet.back();

// Go to next screen and remove previous
Jet.off(NextScreen());

// Go to next screen and clear all previous routes
Jet.offAll(LoginScreen());
```

#### Named Routes

```dart
JetMaterialApp(
  getPages: [
    JetPage(name: '/', page: () => HomeScreen()),
    JetPage(name: '/profile', page: () => ProfileScreen()),
    JetPage(name: '/settings', page: () => SettingsScreen()),
  ],
)
```

#### Advanced Navigation

```dart
// Navigate with arguments
Jet.toNamed('/user', arguments: {'id': 123});

// Receive arguments
final args = Jet.arguments;

// Navigate with result
var result = await Jet.to(SelectionScreen());

// Conditional navigation until
Jet.offUntil(HomeScreen(), (route) => route.isFirst);
```

---

### Dependency Injection

> **TL;DR:** Register with `Jet.put()`, retrieve with `Jet.find()`. Automatic memory management. No Provider trees needed.

#### Basic Usage

```dart
// Register a dependency
Jet.put(ApiController());

// Use it anywhere in your app
final controller = Jet.find<ApiController>();
controller.fetchData();
```

#### Lifecycle Management

```dart
// Lazy instantiation (created when first used)
Jet.lazyPut(() => HeavyController());

// Async instantiation
await Jet.putAsync(() => DatabaseService().init());

// Keep in memory permanently
Jet.put(CacheService(), permanent: true);

// Delete when not needed
Jet.delete<ApiController>();
```

#### Bindings

Group related dependencies for cleaner code:

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Jet.lazyPut(() => HomeController());
    Jet.lazyPut(() => HomeService());
  }
}

// Use with routes
JetPage(
  name: '/home',
  page: () => HomeScreen(),
  binding: HomeBinding(),
)
```

---

## UI Features

### Theming

Switch themes dynamically without boilerplate.

```dart
// Change theme
Jet.changeTheme(ThemeData.dark());

// Toggle dark mode
Jet.changeTheme(Jet.isDarkMode ? ThemeData.light() : ThemeData.dark());

// Check current theme
if (Jet.isDarkMode) {
  // Dark mode is active
}
```

### Dialogs & Snackbars

Show dialogs and snackbars without context.

```dart
// Simple dialog
Jet.defaultDialog(
  title: 'Confirmation',
  middleText: 'Are you sure?',
  onConfirm: () => Jet.back(),
);

// Snackbar
Jet.snackbar('Success', 'Operation completed!');

// Bottom sheet
Jet.bottomSheet(Container(child: Text('Content')));
```

### Context Extensions

Powerful context extensions for responsive design.

```dart
// Screen dimensions
Container(
  width: context.width * 0.8,
  height: context.height * 0.5,
)

// Responsive values
Text(
  'Responsive Text',
  style: TextStyle(
    fontSize: context.responsiveValue<double>(
      mobile: 16,
      tablet: 20,
      desktop: 24,
    ),
  ),
)
```

---

## Additional Features

### Internationalization

Simple key-value translations without complexity.

```dart
// Define translations
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {'hello': 'Hello World'},
    'es_ES': {'hello': 'Hola Mundo'},
  };
}

// Configure app
JetMaterialApp(
  translations: Messages(),
  locale: Locale('en', 'US'),
  fallbackLocale: Locale('en', 'US'),
)

// Use in UI
Text('hello'.tr);

// Change locale
Jet.updateLocale(Locale('es', 'ES'));
```

#### Advanced Translation Features

```dart
// With parameters
'welcome'.trParams({'name': 'John'});

// Plural support
'item'.trPlural('items', count);
```

---

### JetNetworking - HTTP Client with Dio

Powerful HTTP networking built on top of Dio with clean abstractions.

#### Create Custom API Service

```dart
class UserApiService extends JetApiService {
  @override
  String get baseUrl => 'https://api.example.com';
  
  @override
  List<Interceptor> get interceptors => [
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
      compact: true,
    ),
  ];
  
  Future<User> getUser(int id) async {
    return get<User>(
      '/users/$id',
      decoder: (data) => User.fromJson(data),
    );
  }
  
  Future<List<User>> getUsers() async {
    return get<List<User>>(
      '/users',
      decoder: (data) => (data as List).map((e) => User.fromJson(e)).toList(),
    );
  }
  
  Future<User> createUser(Map<String, dynamic> userData) async {
    return post<User>(
      '/users',
      data: userData,
      decoder: (data) => User.fromJson(data),
    );
  }
  
  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    return put<User>(
      '/users/$id',
      data: userData,
      decoder: (data) => User.fromJson(data),
    );
  }
}
```

#### With Authentication Interceptor

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = Jet.find<AuthService>().token;
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}

class ApiService extends JetApiService {
  @override
  String get baseUrl => 'https://api.example.com';
  
  @override
  List<Interceptor> get interceptors => [
    AuthInterceptor(),
    PrettyDioLogger(compact: true),
  ];
}
```

#### File Upload

```dart
class FileApiService extends JetApiService {
  @override
  String get baseUrl => 'https://api.example.com';
  
  Future<UploadResult> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'upload.jpg',
      ),
    });
    
    return upload<UploadResult>(
      '/upload',
      formData,
      decoder: (data) => UploadResult.fromJson(data),
      onSendProgress: (sent, total) {
        print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
      },
    );
  }
}

---

### Middleware

Control route access and lifecycle with middleware.

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

// Use with routes
JetPage(
  name: '/dashboard',
  page: () => DashboardScreen(),
  middlewares: [AuthMiddleware()],
)
```

---

## Advanced Topics

### Local State Widgets

Manage ephemeral state without creating full controllers.

#### ValueBuilder

Simple state management with callbacks:

```dart
ValueBuilder<bool>(
  initialValue: false,
  builder: (value, updateFn) => Switch(
    value: value,
    onChanged: updateFn,
  ),
  onUpdate: (value) => print("Value: $value"),
)
```

#### ObxValue

Reactive version using observables:

```dart
ObxValue(
  (data) => Switch(
    value: data.value,
    onChanged: (val) => data.value = val,
  ),
  false.obs,
)
```

---

### JetView, JetWidget & JetxService

#### JetView

A `StatelessWidget` with automatic controller access:

```dart
class HomeView extends JetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.title)),
      body: Obx(() => Text('Count: ${controller.count}')),
    );
  }
}
```

No need to call `Jet.find()` - the `controller` getter is automatically available.

#### JetWidget

Caches controller instances - useful with `Jet.create()`:

```dart
class ProductTile extends JetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.find<ProductController>();
    return ListTile(title: Text(controller.name));
  }
}
```

#### JetxService

Services that persist for the entire app lifetime:

```dart
class CacheService extends JetxService {
  @override
  Future<void> onInit() async {
    super.onInit();
    await loadCache();
  }
}

// Initialize before app runs
Future<void> main() async {
  await initServices();
  runApp(MyApp());
}

void initServices() async {
  await Jet.putAsync(() => CacheService());
  await Jet.putAsync(() => DatabaseService());
}
```

**JetxService** cannot be removed from memory except with `Jet.reset()` - perfect for app-wide services.

---

### StateMixin

Handle UI states (loading, success, error, empty) elegantly.

```dart
class UserController extends JetxController with StateMixin<User> {
  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  void fetchUser() async {
    change(null, status: RxStatus.loading());
    
    try {
      final user = await api.getUser();
      change(user, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}

// In your view
class UserView extends JetView<UserController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.obx(
        (user) => Text('Hello ${user.name}'),
        onLoading: CircularProgressIndicator(),
        onError: (error) => Text('Error: $error'),
        onEmpty: Text('No user found'),
      ),
    );
  }
}
```

---

### Reactive Programming Deep Dive

#### Observable Types

```dart
// Basic types
final name = 'John'.obs;           // RxString
final age = 25.obs;                // RxInt
final price = 9.99.obs;            // RxDouble
final isActive = true.obs;         // RxBool

// Collections
final items = <String>[].obs;      // RxList
final user = <String, dynamic>{}.obs; // RxMap
final tags = <String>{}.obs;       // RxSet

// Custom objects
final user = User().obs;           // Rx<User>
```

#### Reactive Operators

```dart
final count = 0.obs;

// Direct operations
count++;                           // Increments and notifies
count += 5;
count.value = 10;

// Boolean operations
final flag = false.obs;
flag.toggle();                     // Switches true/false

// List operations (all are reactive)
final list = [].obs;
list.add('item');
list.addAll(['a', 'b']);
list.remove('item');
list.clear();

// Workers - React to changes
ever(count, (value) => print('Count changed to $value'));
once(count, (value) => print('Executed once'));
debounce(count, (value) => print('Debounced'), time: Duration(seconds: 1));
interval(count, (value) => print('Every second'), time: Duration(seconds: 1));
```

#### Custom Reactive Models

```dart
class User {
  String name;
  int age;
  User({required this.name, required this.age});
}

final user = User(name: 'John', age: 25).obs;

// Update and notify
user.update((val) {
  val!.name = 'Jane';
  val.age = 26;
});

// Or manually refresh
user.value.name = 'Bob';
user.refresh();
```

---

### Testing

jetx controllers are easy to test with full lifecycle support.

```dart
class CounterController extends JetxController {
  var count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    count.value = 5;
  }
  
  void increment() => count++;
  
  @override
  void onClose() {
    count.value = 0;
    super.onClose();
  }
}

void main() {
  test('Counter lifecycle test', () {
    // Without lifecycle
    final controller = CounterController();
    expect(controller.count.value, 0);
    
    // With lifecycle
    Jet.put(controller); // Calls onInit
    expect(controller.count.value, 5);
    
    controller.increment();
    expect(controller.count.value, 6);
    
    Jet.delete<CounterController>(); // Calls onClose
    expect(controller.count.value, 0);
  });
}
```

#### Testing Tips

**Mock Services:**

```dart
class ApiServiceMock extends JetxService with Mock implements ApiService {}

// Use in tests
Jet.put<ApiService>(ApiServiceMock());
```

**Test Mode:**

```dart
void main() {
  Jet.testMode = true; // Enable test mode for navigation
  
  // Your tests...
}
```

**Reset Between Tests:**

```dart
tearDown(() {
  Jet.reset(); // Clears all dependencies
});
```

---

## Complete Guides

This section contains comprehensive guides for all JetX features. Each guide includes detailed explanations, best practices, and complete working examples.

### Networking Guide

JetX provides a powerful HTTP client built on Dio with clean abstractions, type safety, and seamless integration with JetX's dependency injection.

**Quick Example:**

```dart
class UserApiService extends JetApiService {
  @override
  String get baseUrl => 'https://api.example.com';
  
  @override
  List<Interceptor> get interceptors => [
    PrettyDioLogger(compact: true),
  ];
  
  Future<User> getUser(int id) async {
    return get<User>(
      '/users/$id',
      decoder: (data) => User.fromJson(data),
    );
  }
}

// Usage in controller
class UserController extends JetxController {
  final api = Jet.find<UserApiService>();
  
  Future<void> loadUser() async {
    try {
      final user = await api.getUser(1);
      // Handle success
    } on DioException catch (e) {
      // Handle error
    }
  }
}
```

**Features:**

- ✅ Type-safe API calls with required decoders
- ✅ Authentication with interceptors
- ✅ File upload/download with progress
- ✅ Request cancellation
- ✅ Pretty logging with `pretty_dio_logger`
- ✅ Full Dio feature support

---

### State Management Guide

JetX provides powerful, high-performance state management without the complexity of other solutions. No Streams, no ChangeNotifier overhead, no code generators - just simple, reactive state management that scales.

#### Introduction

JetX does not use Streams or ChangeNotifier like other state managers. To improve response time and reduce RAM consumption, we created `JetValue` and `JetStream`, which are low latency solutions that deliver high performance at a low operating cost.

**Key Advantages:**

- **🚀 Performance** - No Streams or ChangeNotifier overhead
- **⚡ Simplicity** - No code generators, minimal boilerplate
- **🎯 Granular Control** - Only rebuilds what actually changed
- **🔗 No Context Required** - Access controllers from anywhere
- **📦 All-in-One** - State, navigation, and dependency injection

#### Workers - React to Changes

Workers help you react to changes in observables:

```dart
class MyController extends JetxController {
  final count = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Called every time count changes
    ever(count, (value) => print('Count changed to $value'));
    
    // Called only the first time count changes
    once(count, (value) => print('Count changed once to $value'));
    
    // Called after user stops changing count for 1 second
    debounce(count, (value) => print('Debounced: $value'), 
      time: Duration(seconds: 1));
    
    // Called at most once per second
    interval(count, (value) => print('Interval: $value'), 
      time: Duration(seconds: 1));
  }
}
```

**Worker Types:**
- **`ever`** - Every change
- **`once`** - First change only
- **`debounce`** - After inactivity (great for search)
- **`interval`** - Periodic (great for rate limiting)

#### Advanced Computed Values

Create reactive values that automatically recompute when dependencies change!

**Why Computed?**

**Before (Manual):**
```dart
class CartController extends JetxController {
  final items = <CartItem>[].obs;
  final total = 0.0.obs;
  
  void addItem(CartItem item) {
    items.add(item);
    _recalculateTotal();  // Manual!
  }
  
  void _recalculateTotal() {
    total.value = items.fold(0.0, (sum, item) => sum + item.price);
  }
}
```

**After (Automatic):**
```dart
class CartController extends JetxController {
  final items = <CartItem>[].obs;
  
  // Automatically recomputes when items change!
  late final total = computed(
    () => items.fold(0.0, (sum, item) => sum + item.price),
    watch: [items],
  );
}
```

**Chaining Computed Values:**

```dart
class ShoppingCartController extends JetxController {
  final items = <Item>[].obs;
  final taxRate = 0.08.obs;
  
  // Chain computed values
  late final subtotal = computed(
    () => items.fold(0.0, (sum, i) => sum + i.price),
    watch: [items],
  );
  
  late final tax = computed(
    () => subtotal.value * taxRate.value,
    watch: [subtotal, taxRate],
  );
  
  late final total = computed(
    () => subtotal.value + tax.value,
    watch: [subtotal, tax],
  );
}

// UI updates automatically when items or taxRate changes!
Obx(() => Text('\$${controller.total.value.toStringAsFixed(2)}'))
```

**Custom Equality:**

```dart
final items = <String>[].obs;

final sortedItems = computed(
  () => items.toList()..sort(),
  watch: [items],
  equals: (a, b) => listEquals(a, b),  // Deep comparison
);
```

#### Complete Reactive Operators Guide

**Transform Operators:**

```dart
// map - Transform Values
final temperature = 0.obs;
final fahrenheit = temperature.map((c) => c * 9/5 + 32);
temperature.value = 100; // 212°F

// where - Filter Values
final input = ''.obs;
final validInput = input.where((text) => text.length >= 3);
input.value = 'ab';  // validInput doesn't update
input.value = 'abc'; // validInput updates to 'abc'

// distinct - Skip Duplicates
final clicks = 0.obs;
final uniqueClicks = clicks.distinct();
clicks.value = 1;
clicks.value = 1; // uniqueClicks doesn't update
clicks.value = 2; // uniqueClicks updates

// scan - Accumulate Over Time
final events = 0.obs;
final totalEvents = events.scan<int>(
  0,
  (total, event, index) => total + event,
);
events.value = 1; // totalEvents = 1
events.value = 2; // totalEvents = 3
events.value = 3; // totalEvents = 6
```

**Combine Operators:**

```dart
// Combine Two Observables
final firstName = 'John'.obs;
final lastName = 'Doe'.obs;
final fullName = Rx.combine2(
  firstName,
  lastName,
  (first, last) => '$first $last',
);

// Combine Three or More
final street = '123 Main St'.obs;
final city = 'Springfield'.obs;
final zip = '12345'.obs;
final address = Rx.combine3(
  street, city, zip,
  (s, c, z) => '$s, $c $z',
);

// Combine a List
final sensors = [sensor1, sensor2, sensor3];
final average = Rx.combineLatest(
  sensors,
  (values) => values.reduce((a, b) => a + b) / values.length,
);
```

**Nullable Operators:**

```dart
// whereNotNull - Filter Nulls
final nullableData = Rx<String?>(null);
final nonNullData = nullableData.whereNotNull();

// defaultValue - Fallback
final nullable = Rx<String?>(null);
final withDefault = nullable.defaultValue('N/A');
print(withDefault.value); // 'N/A'
nullable.value = 'Hello';
print(withDefault.value); // 'Hello'
```

#### Stream Integration Deep Dive

```dart
// Auto-Managed (Widget-Based)
final status = Rx.fromStream(
  statusStream,
  initial: Status.idle,
);

// Manual Management
class ChatController extends JetxController {
  final messages = <Message>[].obs;
  late StreamSubscription _subscription;
  
  @override
  void onInit() {
    super.onInit();
    _subscription = messages.listenToStream(
      chatService.messagesStream,
    );
  }
  
  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}

// Controller Helper
class NotificationController extends JetxController {
  late final Rx<int> unreadCount;
  late StreamSubscription _sub;
  
  @override
  void onInit() {
    super.onInit();
    final result = createRxFromStream<int>(
      notificationService.unreadCountStream,
      initial: 0,
    );
    unreadCount = result.$1;
    _sub = result.$2;
  }
  
  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}
```

#### State Management Best Practices

**1. Choose the Right Pattern**

```dart
// ✅ Use computed for derived state
final total = computed(() => items.fold(...), watch: [items]);

// ✅ Use operators for transformations
final filtered = items.where((item) => item.isActive);

// ✅ Use streams for real-time data
final status = Rx.fromStream(service.statusStream, initial: Status.idle);
```

**2. Minimize Recomputation**

```dart
// ✅ Good - specific dependencies
late final filtered = computed(
  () => items.where((i) => i.category == selectedCategory.value).toList(),
  watch: [items, selectedCategory],
);

// ❌ Bad - unnecessary dependencies
late final filtered = computed(
  () => items.where((i) => i.category == selectedCategory.value).toList(),
  watch: [items, selectedCategory, unrelatedField],
);
```

**3. Clean Up Streams**

```dart
// ✅ Good - cleanup in onClose
class MyController extends JetxController {
  late StreamSubscription _sub;
  
  @override
  void onInit() {
    super.onInit();
    _sub = data.listenToStream(stream);
  }
  
  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}
```

#### Complete E-Commerce Cart Example

```dart
class CartController extends JetxController {
  // Base state
  final items = <CartItem>[].obs;
  final taxRate = 0.08.obs;
  final discount = 0.0.obs;
  
  // Computed values (auto-update)
  late final subtotal = computed(
    () => items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
    watch: [items],
  );
  
  late final tax = computed(
    () => subtotal.value * taxRate.value,
    watch: [subtotal, taxRate],
  );
  
  late final total = computed(
    () => subtotal.value + tax.value - discount.value,
    watch: [subtotal, tax, discount],
  );
  
  late final itemCount = computed(
    () => items.fold(0, (sum, item) => sum + item.quantity),
    watch: [items],
  );
  
  // Operators
  late final expensiveItems = items.map(
    (list) => list.where((i) => i.price > 100).toList(),
  );
  
  // Checkout state
  final isCheckingOut = false.obs;
  final checkoutError = Rxn<String>();
  
  void addItem(CartItem item) => items.add(item);
  void removeItem(String id) => items.removeWhere((i) => i.id == id);
  
  void updateQuantity(String id, int quantity) {
    final index = items.indexWhere((i) => i.id == id);
    if (index != -1) {
      items[index] = CartItem(
        id: items[index].id,
        name: items[index].name,
        price: items[index].price,
        quantity: quantity,
      );
      items.refresh();
    }
  }
  
  Future<void> checkout() async {
    isCheckingOut.value = true;
    checkoutError.value = null;
    try {
      await api.processCheckout(items, total.value);
      items.clear();
    } catch (e) {
      checkoutError.value = e.toString();
    } finally {
      isCheckingOut.value = false;
    }
  }
}
```

---

### Route Management Guide

JetX provides powerful route management without requiring context. Navigate anywhere in your app with simple, intuitive APIs.

#### Dynamic URLs

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

#### Query Parameters

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

#### Route Middleware

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

#### Route Guards

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

#### Route Organization Best Practices

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

#### Complete Multi-Screen App with Authentication

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
    
    if (route == AppRoutes.login || route == AppRoutes.splash) {
      return null;
    }
    
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
      await authService.login(email, password);
      isAuthenticated.value = true;
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
```

---

### Dependency Management Guide

JetX provides a simple and powerful dependency manager that allows you to retrieve the same class as your Controller or Service with just one line of code.

#### Quick Reference Table

| Method | When to Use | Memory Management | Lifecycle |
|--------|-------------|-------------------|-----------|
| `Jet.put()` | Controllers, Services | Auto-cleanup | Immediate |
| `Jet.lazyPut()` | Heavy services, Optional dependencies | Auto-cleanup | On first use |
| `Jet.putAsync()` | Async initialization (DB, API) | Auto-cleanup | Immediate (async) |
| `Jet.create()` | Unique instances (list items) | Manual | On each access |
| `Jet.find()` | Access any dependency | N/A | N/A |
| `Jet.delete()` | Manual cleanup | Immediate | N/A |

#### Instancing Methods

**Jet.put()**

```dart
// Basic usage
Jet.put(ApiController());

// With options
Jet.put<ApiController>(
  ApiController(),
  permanent: true,  // Keep in memory permanently
  tag: "api",       // Unique identifier
);
```

**Jet.lazyPut()**

```dart
// Basic lazy loading
Jet.lazyPut(() => HeavyService());

// With options
Jet.lazyPut<ApiService>(
  () => ApiService(),
  tag: "api",
  fenix: true,  // Recreate when needed
);
```

**Jet.putAsync()**

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

**Jet.create()**

```dart
// Create unique instances
Jet.create<ProductController>(() => ProductController());

// With options
Jet.create<ItemController>(
  () => ItemController(),
  name: "item",
  permanent: true,
);
```

#### Common Patterns

**Services Pattern:**

```dart
abstract class ApiService {
  Future<List<User>> getUsers();
}

class ApiServiceImpl implements ApiService {
  @override
  Future<List<User>> getUsers() async {
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
  }
}
```

**Repositories Pattern:**

```dart
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
  }
}
```

#### Testing with Dependencies

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
      final users = [User(id: 1, name: 'John')];
      when(mockApiService.getUsers()).thenAnswer((_) async => users);
      
      await controller.loadUsers();
      
      expect(controller.users.length, 1);
      expect(controller.users.first.name, 'John');
    });
  });
}
```

---

### Internationalization Guide

JetX provides simple and powerful internationalization (i18n) support.

#### Dynamic Locale Switching

```dart
// Change locale programmatically
Jet.updateLocale(Locale('es', 'ES'));

// Locale Controller
class LocaleController extends JetxController {
  final currentLocale = Locale('en', 'US').obs;
  
  final supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
  ];
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }
  
  void _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      final locale = Locale(savedLocale.split('_')[0], savedLocale.split('_')[1]);
      changeLocale(locale);
    }
  }
  
  void changeLocale(Locale locale) async {
    currentLocale.value = locale;
    Jet.updateLocale(locale);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', '${locale.languageCode}_${locale.countryCode}');
  }
  
  String get currentLanguageName {
    switch (currentLocale.value.languageCode) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      default: return 'English';
    }
  }
}
```

#### Locale Selection UI

```dart
class LocaleSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.put(LocaleController());
    
    return Obx(() => DropdownButton<Locale>(
      value: controller.currentLocale.value,
      items: controller.supportedLocales.map((locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(_getLanguageName(locale)),
        );
      }).toList(),
      onChanged: (locale) {
        if (locale != null) {
          controller.changeLocale(locale);
        }
      },
    ));
  }
  
  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      default: return locale.languageCode;
    }
  }
}
```

---

### UI Features Guide

JetX provides powerful UI utilities for theming, dialogs, snackbars, bottom sheets, and context extensions.

#### Complete Theming Example

```dart
class ThemeController extends JetxController {
  final isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }
  
  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getBool('isDarkMode') ?? false;
    isDarkMode.value = savedTheme;
    Jet.changeTheme(savedTheme ? ThemeData.dark() : ThemeData.light());
  }
  
  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Jet.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }
}
```

#### Complete Dialog Example

```dart
class DialogController extends JetxController {
  final name = ''.obs;
  final email = ''.obs;
  
  Future<void> showUserDialog() async {
    final result = await Jet.dialog(
      AlertDialog(
        title: Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter name',
              ),
              onChanged: (value) => name.value = value,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email',
              ),
              onChanged: (value) => email.value = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Jet.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name.value.isNotEmpty && email.value.isNotEmpty) {
                Jet.back(result: {'name': name.value, 'email': email.value});
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      print('User added: $result');
    }
  }
}
```

#### Notification System

```dart
class NotificationController extends JetxController {
  void showSuccess(String message) {
    Jet.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }
  
  void showError(String message) {
    Jet.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 5),
    );
  }
  
  void showInfo(String message) {
    Jet.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: Icon(Icons.info, color: Colors.white),
    );
  }
  
  void showWarning(String message) {
    Jet.snackbar(
      'Warning',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: Icon(Icons.warning, color: Colors.white),
    );
  }
}
```

---

### Quick Reference

This section provides fast lookup for common JetX patterns and features.

#### Computed Values

```dart
// Basic
final count = 0.obs;
final doubled = computed(() => count.value * 2, watch: [count]);

// Chained
final items = <Item>[].obs;
final taxRate = 0.08.obs;

late final subtotal = computed(
  () => items.fold(0.0, (s, i) => s + i.price),
  watch: [items],
);

late final tax = computed(
  () => subtotal.value * taxRate.value,
  watch: [subtotal, taxRate],
);

late final total = computed(
  () => subtotal.value + tax.value,
  watch: [subtotal, tax],
);
```

#### Reactive Operators

```dart
// Transform
final celsius = 0.obs;
final fahrenheit = celsius.map((c) => c * 9/5 + 32);

// Filter
final input = ''.obs;
final valid = input.where((t) => t.length >= 3);

// Distinct
final rapid = 0.obs;
final stable = rapid.distinct();

// Scan
final events = 0.obs;
final total = events.scan<int>(0, (acc, val, i) => acc + val);

// Combine
final fullName = Rx.combine2(firstName, lastName, (a, b) => '$a $b');
final address = Rx.combine3(street, city, zip, (s, c, z) => '$s, $c $z');
```

#### Lifecycle

```dart
class MyController extends JetxController {
  @override
  void onInit() {
    super.onInit();
    // Called when controller is created
  }
  
  @override
  void onReady() {
    super.onReady();
    // Called after first build
  }
  
  @override
  void onClose() {
    // Cleanup
    super.onClose();
  }
}
```

#### Common Patterns

**Loading Data:**

```dart
class DataController extends JetxController {
  final data = <Item>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();
  
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  
  Future<void> loadData() async {
    isLoading.value = true;
    error.value = null;
    try {
      data.value = await api.getData();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refresh() => loadData();
}
```

**Form Validation:**

```dart
class FormController extends JetxController {
  final email = ''.obs;
  final password = ''.obs;
  
  late final isEmailValid = computed(
    () => email.value.contains('@'),
    watch: [email],
  );
  
  late final isPasswordValid = computed(
    () => password.value.length >= 6,
    watch: [password],
  );
  
  late final isFormValid = computed(
    () => isEmailValid.value && isPasswordValid.value,
    watch: [isEmailValid, isPasswordValid],
  );
}
```

**Search with Debouncing:**

```dart
class SearchController extends JetxController {
  final searchQuery = ''.obs;
  
  late final validQuery = searchQuery
      .where((q) => q.length >= 3)
      .distinct();
  
  late final results = computed(
    () => _performSearch(validQuery.value),
    watch: [validQuery],
  );
  
  List<Result> _performSearch(String query) {
    return [];
  }
}
```

---

## Migration Guide

### From GetX to JetX

jetx maintains API compatibility with GetX while adding improvements. Migration is straightforward:

#### 1. Update Dependencies

```yaml
dependencies:
  jetx: ^0.1.0-alpha.1  # Replace 'get'
```
### Key Advantages

**1. All-in-One Solution**
- State management, routing, and dependency injection in one cohesive package
- No need to mix and match multiple packages
- Consistent API across all features

**2. Performance First**
- No Streams or ChangeNotifier overhead
- Smart memory management - unused dependencies are automatically removed
- Lazy loading by default
- Minimal rebuilds with surgical precision

**3. Developer Productivity**
- Simple, intuitive syntax
- No context required for navigation or dependency access
- No code generators or build runners
- Less boilerplate = faster development

**4. Production Ready**
- Battle-tested by thousands of apps (GetX heritage)
- Actively maintained with regular updates
- Comprehensive documentation and examples
- Strong community support

**5. Flexibility**
- Use only what you need - modular by design
- Mix with other packages if desired
- Works with any architecture (MVC, MVVM, Clean, etc.)

---

## Community & Contributing

### Get Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/alamre/jetx/issues)
- **Discussions**: [Ask questions and share ideas](https://github.com/alamre/jetx/discussions)
- **Stack Overflow**: Tag your questions with `[jetx]`

### Contributing

We welcome contributions! Here's how you can help:

- 🐛 **Report bugs** - Open an issue with details
- 💡 **Suggest features** - Share your ideas for improvements
- 📖 **Improve docs** - Help make documentation clearer
- 🔧 **Submit PRs** - Fix bugs or add features
- ⭐ **Star the repo** - Show your support

#### Development Setup

```bash
# Clone the repository
git clone https://github.com/alamre/jetx.git
cd jetx

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example
cd example
flutter run
```

### Code of Conduct

Be respectful, constructive, and welcoming. We're here to build great software together.

---

## License

jetx is released under the [MIT License](LICENSE).

---

## Acknowledgments

jetx is built upon the foundation of GetX, created by Jonatas Borges. We're grateful to the original GetX community and all contributors who made this framework possible. JetX continues that legacy with enhanced features and active maintenance.

---

<div align="center">

**[⬆ Back to Top](#jetx)**

Made with ❤️ by the JetX community

</div>
