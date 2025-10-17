# jetx

[![pub package](https://img.shields.io/pub/v/jetx.svg?label=jetx&color=blue)](https://pub.dev/packages/jetx)
[![popularity](https://img.shields.io/pub/popularity/jetx?logo=dart)](https://pub.dev/packages/jetx/score)
[![likes](https://img.shields.io/pub/likes/jetx?logo=dart)](https://pub.dev/packages/jetx/score)
[![pub points](https://img.shields.io/pub/points/jetx?logo=dart)](https://pub.dev/packages/jetx/score)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)

**A modern, powerful, and lightweight Flutter framework for state management, dependency injection, and route management.**

*jetx is an actively maintained and enhanced fork of GetX, bringing improved performance, better organization, and modern Flutter practices.*

---

## Table of Contents

- [What is jetx?](#what-is-jetx)
- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Counter App Example](#counter-app-example)
  - [Key Concepts at a Glance](#key-concepts-at-a-glance)
- [Core Features](#core-features)
  - [State Management](#state-management)
  - [Route Management](#route-management)
  - [Dependency Injection](#dependency-injection)
- [Additional Features](#additional-features)
  - [Internationalization](#internationalization)
  - [Theme Management](#theme-management)
  - [JetConnect - HTTP & WebSockets](#jetconnect---http--websockets)
  - [Middleware](#middleware)
- [Advanced Topics](#advanced-topics)
  - [Local State Widgets](#local-state-widgets)
  - [JetView, JetWidget & JetxService](#jetview-jetwidget--jetxservice)
  - [StateMixin](#statemixin)
  - [Reactive Programming Deep Dive](#reactive-programming-deep-dive)
  - [Testing](#testing)
- [Migration Guide](#migration-guide)
- [Why jetx?](#why-jetx)
- [Community & Contributing](#community--contributing)

---

## What is jetx?

jetx combines **high-performance state management**, **intelligent dependency injection**, and **intuitive route management** into a single, cohesive package for Flutter.

**Three Core Principles:**

- **🚀 Performance** - No Streams or ChangeNotifier overhead. Minimal resource consumption.
- **⚡ Productivity** - Simple, elegant syntax that saves hours of development time.
- **📦 Organization** - Complete decoupling of UI, business logic, and navigation. No context needed.

jetx is modular by design. Use only what you need—if you only use state management, only that code is compiled. Each feature is independently usable without bloating your app.

---

## Quick Start

### Installation

Add jetx to your `pubspec.yaml`:

```yaml
dependencies:
  jetx: ^1.0.0
```

Import jetx in your files:

```dart
import 'package:jetx/jetx.dart';
```

### Counter App Example

> **The power of jetx in 26 lines of code** - A complete counter app with state management, navigation, and shared state between screens.

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

jetx offers two state managers:

- **Simple State Manager** (`JetBuilder`) - Lightweight, manual control
- **Reactive State Manager** (`Obx`) - Automatic updates when observables change

#### Reactive Example

```dart
// In your controller
var name = 'John'.obs;

// In your UI
Obx(() => Text(name.value));
```

When `name` changes, the UI updates automatically. No `setState()`, no `StreamBuilder`, no complications.

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

**📚 [Read the complete State Management guide →](./documentation/state_management.md)**

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

**📚 [Read the complete Route Management guide →](./documentation/route_management.md)**

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

**📚 [Read the complete Dependency Management guide →](./documentation/dependency_management.md)**

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

### Theme Management

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

---

### JetConnect - HTTP & WebSockets

Easy communication with your backend.

#### HTTP Requests

```dart
class UserProvider extends JetConnect {
  Future<Response> getUser(int id) => get('https://api.example.com/users/$id');
  
  Future<Response> createUser(Map data) => post('https://api.example.com/users', body: data);
  
  Future<Response> updateUser(int id, Map data) => put('https://api.example.com/users/$id', body: data);
}
```

#### Custom Configuration

```dart
class ApiProvider extends JetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://api.example.com';
    httpClient.defaultDecoder = User.fromJson;
    
    // Add auth header to all requests
    httpClient.addRequestModifier((request) {
      request.headers['Authorization'] = 'Bearer $token';
      return request;
    });
    
    // Transform responses
    httpClient.addResponseModifier((request, response) {
      // Process response
      return response;
    });
  }
}
```

#### WebSocket Support

```dart
class ChatProvider extends JetConnect {
  JetSocket chatRoom() {
    return socket('wss://api.example.com/chat');
  }
}

// Usage
final socket = provider.chatRoom();
socket.onMessage((data) => print('Message: $data'));
socket.send('Hello!');
```

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

## 🎯 Modern Reactive Features

jetx includes cutting-edge reactive programming features inspired by modern frameworks like Riverpod, while maintaining jetx's signature simplicity.

### Computed Values - Auto-Updating Derived State

Create reactive values that automatically recompute when dependencies change. No manual calculations or state updates needed!

```dart
class CartController extends JetxController {
  final items = <Item>[].obs;
  final taxRate = 0.08.obs;
  
  // Automatically recalculates when items change!
  late final subtotal = computed(
    () => items.fold(0.0, (sum, i) => sum + i.price),
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
  
  // Add an item - totals update automatically!
  void addItem(Item item) => items.add(item);
}

// UI updates automatically - no manual calculations!
Obx(() => Text('Total: \$${controller.total.value}'))
```

### Reactive Operators - Functional Transformations

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

### Stream Integration

Seamlessly bind Dart Streams to reactive values.

```dart
class ChatController extends JetxController {
  final messages = <Message>[].obs;
  late StreamSubscription _sub;
  
  @override
  void onInit() {
    super.onInit();
    // Auto-sync with stream
    _sub = messages.listenToStream(chatService.messagesStream);
  }
  
  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}

// Or use the helper
final status = Rx.fromStream(
  statusStream,
  initial: Status.idle,
);
```

**📚 Learn More:** Check out the complete [Advanced Features Guide](documentation/advanced_features.md) with real-world examples!

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

## Migration Guide

### From GetX to jetx

jetx maintains API compatibility with GetX while adding improvements. Migration is straightforward:

#### 1. Update Dependencies

```yaml
dependencies:
  jetx: ^1.0.0  # Replace 'get'
```

#### 2. Update Imports

```dart
// Old
import 'package:get/get.dart';

// New
import 'package:jetx/jetx.dart';
```

#### 3. Update API Calls

| GetX | jetx |
|------|------|
| `Get.to()` | `Jet.to()` |
| `Get.put()` | `Jet.put()` |
| `Get.find()` | `Jet.find()` |
| `GetMaterialApp` | `JetMaterialApp` |
| `GetxController` | `JetxController` |
| `GetBuilder` | `JetBuilder` |
| `GetView` | `JetView` |
| `GetWidget` | `JetWidget` |
| `GetxService` | `JetxService` |
| `GetPage` | `JetPage` |
| `GetConnect` | `JetConnect` |

Most functionality remains the same, just with the new naming convention.

### Breaking Changes from GetX 2.x

If migrating from old GetX versions:

**Rx Types Updated:**

| Old | New |
|-----|-----|
| `StringX` | `RxString` |
| `IntX` | `RxInt` |
| `MapX` | `RxMap` |
| `ListX` | `RxList` |
| `NumX` | `RxNum` |
| `DoubleX` | `RxDouble` |

**Named Routes Structure:**

```dart
// Old (GetX 2.x)
JetMaterialApp(
  namedRoutes: {
    '/': JetRoute(page: Home()),
  }
)

// New (jetx)
JetMaterialApp(
  getPages: [
    JetPage(name: '/', page: () => Home()),
  ]
)
```

---

## Why jetx?

### Compared to Other Solutions

| Feature | jetx | Provider | BLoC | Riverpod |
|---------|------|----------|------|----------|
| State Management | ✅ | ✅ | ✅ | ✅ |
| Route Management | ✅ | ❌ | ❌ | ❌ |
| Dependency Injection | ✅ | ✅ | ⚠️ | ✅ |
| No Context Required | ✅ | ❌ | ❌ | ✅ |
| No Code Generation | ✅ | ✅ | ❌ | ❌ |
| Minimal Boilerplate | ✅ | ⚠️ | ❌ | ⚠️ |
| Learning Curve | Easy | Easy | Steep | Medium |

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

jetx is built upon the foundation of GetX, created by Jonatas Borges. We're grateful to the original GetX community and all contributors who made this framework possible. jetx continues that legacy with enhanced features and active maintenance.

---

<div align="center">

**[⬆ Back to Top](#jetx)**

Made with ❤️ by the jetx community

</div>
