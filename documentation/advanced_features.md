# JetX Advanced Features Guide

Complete guide to modern reactive features in JetX, including Computed Values, Reactive Operators, and Stream Integration.

> **✨ These features are production-ready and fully tested!** All examples in this guide work out of the box. See the `/example` folder for complete working apps.

---

## 📋 Table of Contents

1. [Computed Values](#computed-values)
2. [Reactive Operators](#reactive-operators)
3. [Stream Integration](#stream-integration)
4. [Best Practices](#best-practices)

---

## Computed Values

Automatically recompute reactive values when dependencies change - no manual updates needed!

> **💡 Key Pattern:** Computed values watch their dependencies and automatically recalculate when any dependency changes. Perfect for derived state like totals, filters, and validations.

### Why Computed?

**Before:**
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

**After:**
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

### Basic Usage

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

> **📝 Note:** Always use `late final` for computed values in controllers to ensure they're initialized after the observable dependencies.

### Chaining Computed Values

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

### Custom Equality

Avoid unnecessary recomputation with custom equality:

```dart
final items = <String>[].obs;

final sortedItems = computed(
  () => items.toList()..sort(),
  watch: [items],
  equals: (a, b) => listEquals(a, b),  // Deep comparison
);
```

### Multiple Dependencies

```dart
final firstName = 'John'.obs;
final lastName = 'Doe'.obs;
final title = 'Dr.'.obs;

final fullName = computed(
  () => '${title.value} ${firstName.value} ${lastName.value}',
  watch: [title, firstName, lastName],
);
```

---

## Reactive Operators

Functional programming patterns for reactive values - transform, filter, combine!

### Transform Operators

#### map() - Transform Values

```dart
final temperature = 0.obs;

// Celsius to Fahrenheit
final fahrenheit = temperature.map((c) => c * 9/5 + 32);

temperature.value = 100; // 212°F
```

#### where() - Filter Values

```dart
final input = ''.obs;

// Only emit when length >= 3
final validInput = input.where((text) => text.length >= 3);

input.value = 'ab';  // validInput doesn't update
input.value = 'abc'; // validInput updates to 'abc'
```

#### distinct() - Skip Duplicates

```dart
final clicks = 0.obs;

// Only emit when value actually changes
final uniqueClicks = clicks.distinct();

clicks.value = 1;
clicks.value = 1; // uniqueClicks doesn't update
clicks.value = 2; // uniqueClicks updates
```

#### scan() - Accumulate Over Time

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

### Combine Operators

#### Combine Two Observables

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

#### Combine Three or More

```dart
final street = '123 Main St'.obs;
final city = 'Springfield'.obs;
final zip = '12345'.obs;

final address = Rx.combine3(
  street, city, zip,
  (s, c, z) => '$s, $c $z',
);
```

#### Combine a List

```dart
final sensors = [
  sensor1,
  sensor2,
  sensor3,
];

final average = Rx.combineLatest(
  sensors,
  (values) => values.reduce((a, b) => a + b) / values.length,
);
```

### Nullable Operators

#### whereNotNull() - Filter Nulls

```dart
final nullableData = Rx<String?>(null);

// Only emit non-null values
final nonNullData = nullableData.whereNotNull();
```

#### defaultValue() - Fallback

```dart
final nullable = Rx<String?>(null);

final withDefault = nullable.defaultValue('N/A');

print(withDefault.value); // 'N/A'
nullable.value = 'Hello';
print(withDefault.value); // 'Hello'
```

### Real-World Example

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

## Stream Integration

Seamlessly integrate Dart Streams with reactive values.

### Basic Stream Binding

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

### Controller Helper

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

### Stream Combiners

#### Combine Multiple Streams

```dart
final combined = RxStreams.combine2(
  stream1,
  stream2,
  (a, b) => Result(a, b),
);
```

#### Merge Streams

```dart
final merged = RxStreams.merge([
  clickStream,
  touchStream,
  keyStream,
]);
```

### Real-World Example: Real-Time Chat

```dart
class ChatRoomController extends JetxController {
  final messages = <Message>[].obs;
  final typingUsers = <User>[].obs;
  
  late StreamSubscription _messagesSub;
  late StreamSubscription _typingSub;
  
  @override
  void onInit() {
    super.onInit();
    
    // Bind message stream
    _messagesSub = messages.listenToStream(
      chatService.getMessages(roomId),
    );
    
    // Bind typing indicator stream
    _typingSub = typingUsers.listenToStream(
      chatService.getTypingUsers(roomId),
    );
  }
  
  @override
  void onClose() {
    _messagesSub.cancel();
    _typingSub.cancel();
    super.onClose();
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

### 2. Name Computed Values Clearly

```dart
// ✅ Good - clear intent
late final subtotal = computed(...);
late final tax = computed(...);
late final grandTotal = computed(...);

// ❌ Bad - unclear
late final value1 = computed(...);
late final temp = computed(...);
```

### 3. Minimize Recomputation

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

### 4. Clean Up Streams

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

### 5. Combine Patterns

```dart
class DashboardController extends JetxController {
  // Observable data
  final orders = <Order>[].obs;
  
  // Computed from observable
  late final orderCount = computed(
    () => orders.length,
    watch: [orders],
  );
  
  // Stream for real-time updates
  late StreamSubscription _notificationsSub;
  final notifications = <Notification>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadData();
    _notificationsSub = notifications.listenToStream(
      notificationService.stream,
    );
  }
  
  Future<void> loadData() async {
    try {
      orders.value = await api.getOrders();
    } catch (e) {
      // Handle error
    }
  }
  
  @override
  void onClose() {
    _notificationsSub.cancel();
    super.onClose();
  }
}
```

---

## Complete Example: E-Commerce Cart

```dart
// Model
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

// Controller
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

// View
class CartView extends JetView<CartController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Obx(() => Badge(
            label: Text('${controller.itemCount.value}'),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {},
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          // Items list
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.price} x ${item.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.removeItem(item.id),
                  ),
                );
              },
            )),
          ),
          
          // Totals (auto-update from computed values)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('\$${controller.subtotal.value.toStringAsFixed(2)}'),
                  ],
                )),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax:'),
                    Text('\$${controller.tax.value.toStringAsFixed(2)}'),
                  ],
                )),
                const Divider(),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                    Text(
                      '\$${controller.total.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 16),
                
                // Checkout button
                Obx(() {
                  if (controller.isCheckingOut.value) {
                    return const CircularProgressIndicator();
                  }
                  
                  if (controller.checkoutError.value != null) {
                    return Column(
                      children: [
                        Text('Error: ${controller.checkoutError.value}'),
                        ElevatedButton(
                          onPressed: controller.checkout,
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  
                  return ElevatedButton(
                    onPressed: controller.checkout,
                    child: const Text('Checkout'),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Learn More

- [State Management Guide](./state_management.md)
- [Route Management Guide](./route_management.md)
- [Dependency Management Guide](./dependency_management.md)
- [Complete Examples](/example/lib/)

---

**Happy Coding with JetX! 🚀**

