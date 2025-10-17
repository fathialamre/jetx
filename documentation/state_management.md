# State Management

JetX provides powerful, high-performance state management without the complexity of other solutions. No Streams, no ChangeNotifier overhead, no code generators - just simple, reactive state management that scales.

---

## Table of Contents

- [Introduction](#introduction)
- [Quick Start](#quick-start)
- [Reactive State Manager](#reactive-state-manager)
  - [Basic Observables](#basic-observables)
  - [Using in Views](#using-in-views)
  - [Declaring Reactive Variables](#declaring-reactive-variables)
  - [Conditions to Rebuild](#conditions-to-rebuild)
  - [Workers](#workers)
- [🆕 Advanced Reactive Features](#-advanced-reactive-features)
  - [Computed Values](#computed-values)
  - [Reactive Operators](#reactive-operators)
  - [Stream Integration](#stream-integration)
- [Simple State Manager](#simple-state-manager)
- [StateMixin](#statemixin)
- [Best Practices](#best-practices)
- [Complete Examples](#complete-examples)

---

## Introduction

JetX does not use Streams or ChangeNotifier like other state managers. Why? In addition to building applications for Android, iOS, web, Windows, macOS and Linux, with JetX you can build server applications with the same syntax as Flutter/JetX. 

To improve response time and reduce RAM consumption, we created `JetValue` and `JetStream`, which are low latency solutions that deliver high performance at a low operating cost.

**Key Advantages:**

- **🚀 Performance** - No Streams or ChangeNotifier overhead
- **⚡ Simplicity** - No code generators, minimal boilerplate
- **🎯 Granular Control** - Only rebuilds what actually changed
- **🔗 No Context Required** - Access controllers from anywhere
- **📦 All-in-One** - State, navigation, and dependency injection

---

## Quick Start

Here's a complete counter app in just a few lines:

```dart
// 1. Create controller
class CounterController extends JetxController {
  var count = 0.obs;
  increment() => count++;
}

// 2. Use in view
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.put(CounterController());
    
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text('Count: ${controller.count}'))),
      body: Center(
        child: ElevatedButton(
          onPressed: controller.increment,
          child: Text('Increment'),
        ),
      ),
    );
  }
}
```

**That's it!** The UI automatically updates when `count` changes.

---

## Reactive State Manager

Reactive programming with JetX is as simple as using `setState`, but much more powerful.

### Basic Observables

Make any variable reactive by adding `.obs`:

```dart
// Basic types
var name = 'John'.obs;           // RxString
var age = 25.obs;                // RxInt
var price = 9.99.obs;            // RxDouble
var isActive = true.obs;         // RxBool

// Collections
var items = <String>[].obs;      // RxList
var user = <String, dynamic>{}.obs; // RxMap
var tags = <String>{}.obs;       // RxSet

// Custom objects
var user = User().obs;           // Rx<User>
```

### Using in Views

Wrap widgets in `Obx()` to make them reactive:

```dart
// Simple reactive text
Obx(() => Text(controller.name.value))

// Multiple observables in one Obx
Obx(() => Text('${controller.firstName.value} ${controller.lastName.value}'))

// Conditional rendering
Obx(() => controller.isLoading.value 
  ? CircularProgressIndicator()
  : Text('Data loaded!')
)
```

### Declaring Reactive Variables

You have three ways to create observables:

**1. Using `Rx{Type}`:**
```dart
final name = RxString('');
final isLogged = RxBool(false);
final count = RxInt(0);
final balance = RxDouble(0.0);
final items = RxList<String>([]);
final myMap = RxMap<String, int>({});
```

**2. Using `Rx<Type>`:**
```dart
final name = Rx<String>('');
final isLogged = Rx<Bool>(false);
final count = Rx<Int>(0);
final user = Rx<User>();
```

**3. Using `.obs` (Recommended):**
```dart
final name = ''.obs;
final isLogged = false.obs;
final count = 0.obs;
final items = <String>[].obs;
final user = User().obs;
```

### Conditions to Rebuild

JetX only rebuilds when values **actually** change:

```dart
final isOpen = false.obs;

// This won't trigger a rebuild - same value
void onButtonTap() => isOpen.value = false;

// This will trigger a rebuild - value changed
void onButtonTap() => isOpen.value = true;
```

### Workers

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

---

## 🆕 Advanced Reactive Features

JetX introduces powerful new reactive features not available in GetX.

### Computed Values

Automatically recompute reactive values when dependencies change - no manual updates needed!

#### Why Computed?

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

#### Basic Usage

```dart
// Simple computed value
final count = 0.obs;
final doubled = computed(
  () => count.value * 2,
  watch: [count],
);

print(doubled.value); // 0
count.value = 5;
print(doubled.value); // 10 (auto-updated!)

// Use with Obx for reactive UI
Obx(() => Text('Doubled: ${doubled.value}'))
```

#### Chaining Computed Values

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

#### Custom Equality

Avoid unnecessary recomputation with custom equality:

```dart
final items = <String>[].obs;

final sortedItems = computed(
  () => items.toList()..sort(),
  watch: [items],
  equals: (a, b) => listEquals(a, b),  // Deep comparison
);
```

### Reactive Operators

Functional programming patterns for reactive values - transform, filter, combine!

#### Transform Operators

**`map()` - Transform Values:**
```dart
final temperature = 0.obs;

// Celsius to Fahrenheit
final fahrenheit = temperature.map((c) => c * 9/5 + 32);

temperature.value = 100; // 212°F
```

**`where()` - Filter Values:**
```dart
final input = ''.obs;

// Only emit when length >= 3
final validInput = input.where((text) => text.length >= 3);

input.value = 'ab';  // validInput doesn't update
input.value = 'abc'; // validInput updates to 'abc'
```

**`distinct()` - Skip Duplicates:**
```dart
final clicks = 0.obs;

// Only emit when value actually changes
final uniqueClicks = clicks.distinct();

clicks.value = 1;
clicks.value = 1; // uniqueClicks doesn't update
clicks.value = 2; // uniqueClicks updates
```

**`scan()` - Accumulate Over Time:**
```dart
final events = 0.obs;

// Count total events
final totalEvents = events.scan<int>(
  0,
  (total, event, index) => total + event,
);

events.value = 1; // totalEvents = 1
events.value = 2; // totalEvents = 3
events.value = 3; // totalEvents = 6
```

#### Combine Operators

**Combine Two Observables:**
```dart
final firstName = 'John'.obs;
final lastName = 'Doe'.obs;

final fullName = Rx.combine2(
  firstName,
  lastName,
  (first, last) => '$first $last',
);

// fullName automatically updates when either changes
Obx(() => Text(fullName.value))
```

**Combine Three or More:**
```dart
final street = '123 Main St'.obs;
final city = 'Springfield'.obs;
final zip = '12345'.obs;

final address = Rx.combine3(
  street, city, zip,
  (s, c, z) => '$s, $c $z',
);
```

**Combine a List:**
```dart
final sensors = [sensor1, sensor2, sensor3];

final average = Rx.combineLatest(
  sensors,
  (values) => values.reduce((a, b) => a + b) / values.length,
);
```

#### Nullable Operators

**`whereNotNull()` - Filter Nulls:**
```dart
final nullableData = Rx<String?>(null);

// Only emit non-null values
final nonNullData = nullableData.whereNotNull();
```

**`defaultValue()` - Fallback:**
```dart
final nullable = Rx<String?>(null);

final withDefault = nullable.defaultValue('N/A');

print(withDefault.value); // 'N/A'
nullable.value = 'Hello';
print(withDefault.value); // 'Hello'
```

### Stream Integration

Seamlessly integrate Dart Streams with reactive values.

#### Auto-Managed (Widget-Based)

```dart
// Stream auto-managed by widget lifecycle
final status = Rx.fromStream(
  statusStream,
  initial: Status.idle,
);

// Subscription cleaned up when widget disposed
```

#### Manual Management

```dart
class ChatController extends JetxController {
  final messages = <Message>[].obs;
  late StreamSubscription _subscription;
  
  @override
  void onInit() {
    super.onInit();
    
    // Bind stream to reactive value
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
```

#### Controller Helper

```dart
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

---

## Simple State Manager

For cases where you don't need reactive programming, JetX provides a simple state manager.

### Advantages

1. **Lightweight** - Minimal memory usage
2. **Manual Control** - Update only when you want
3. **No Streams** - No reactive overhead
4. **Familiar** - Similar to `setState()`

### Usage

```dart
class SimpleController extends JetxController {
  int counter = 0;
  
  void increment() {
    counter++;
    update(); // Triggers rebuild
  }
}

// In your view
JetBuilder<SimpleController>(
  init: SimpleController(),
  builder: (controller) => Text('${controller.counter}'),
)
```

### When to Use

- **Simple state** - Basic counters, toggles
- **Performance critical** - When you need maximum performance
- **Batch updates** - When you want to update multiple widgets at once
- **Legacy code** - When migrating from `setState()`

---

## StateMixin

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

## Best Practices

### 1. Choose the Right Pattern

```dart
// ✅ Use computed for derived state
final total = computed(() => items.fold(...), watch: [items]);

// ✅ Use operators for transformations
final filtered = items.where((item) => item.isActive);

// ✅ Use streams for real-time data
final status = Rx.fromStream(service.statusStream, initial: Status.idle);
```

### 2. Minimize Recomputation

```dart
// ✅ Good - specific dependencies
late final filtered = computed(
  () => items.where((i) => i.category == selectedCategory.value).toList(),
  watch: [items, selectedCategory],  // Only these
);

// ❌ Bad - unnecessary dependencies
late final filtered = computed(
  () => items.where((i) => i.category == selectedCategory.value).toList(),
  watch: [items, selectedCategory, unrelatedField],  // Too many
);
```

### 3. Clean Up Streams

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
    _sub.cancel();  // Always cleanup!
    super.onClose();
  }
}
```

### 4. Performance Tips

- Use `Obx()` for reactive updates
- Use `JetBuilder()` for manual updates
- Use `computed()` for derived state
- Use `workers` for side effects
- Clean up subscriptions in `onClose()`

---

## Complete Examples

### E-Commerce Cart

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

### Search with Debouncing

```dart
class SearchController extends JetxController {
  final searchQuery = ''.obs;
  
  // Debounced and filtered search
  late final validQuery = searchQuery
      .where((q) => q.length >= 3)    // Min 3 chars
      .distinct();                     // Skip duplicates
  
  // Search results computed from valid query
  late final results = computed(
    () => _performSearch(validQuery.value),
    watch: [validQuery],
  );
  
  List<Result> _performSearch(String query) {
    // Perform search...
    return [];
  }
}
```

---

## Learn More

- **[What's New in JetX](./whats_new_in_jetx.md)** - New features not in GetX
- **[Route Management](./route_management.md)** - Navigation without context
- **[Dependency Management](./dependency_management.md)** - Smart dependency injection
- **[Quick Reference](./quick_reference.md)** - Fast lookup for all features

---

**Ready to build amazing apps with JetX?** [Get started →](../README.md#quick-start)