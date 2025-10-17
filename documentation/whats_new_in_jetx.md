# What's New in JetX

JetX is an actively maintained and enhanced fork of GetX, bringing improved performance, better organization, and modern Flutter practices. This document highlights the new features and improvements that make JetX a superior choice for Flutter development.

---

## 🆕 New Features Not in GetX

JetX introduces three major new reactive programming features that significantly enhance developer productivity and code quality.

### ✨ Computed Values - Automatic Derived State

**What it is:** Automatically recompute reactive values when dependencies change - no manual updates needed!

**Why it's powerful:** Eliminates the need for manual state synchronization and reduces bugs from forgotten updates.

```dart
class CartController extends JetxController {
  final items = <CartItem>[].obs;
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

**Benefits:**
- 🚀 **Zero boilerplate** - No manual `update()` calls
- 🎯 **Automatic synchronization** - Dependencies tracked automatically
- 🔗 **Chainable** - Build complex derived state from simple pieces
- ⚡ **Performance optimized** - Only recomputes when dependencies actually change

### ✨ Reactive Operators - Functional Transformations

**What it is:** Functional programming patterns for reactive values - transform, filter, combine with ease!

**Why it's powerful:** Enables clean, declarative data transformations without complex state management.

```dart
// Transform values
final temperature = 0.obs;
final fahrenheit = temperature.map((c) => c * 9/5 + 32);

// Filter values
final input = ''.obs;
final validInput = input.where((text) => text.length >= 3);

// Skip duplicates
final clicks = 0.obs;
final uniqueClicks = clicks.distinct();

// Accumulate over time
final events = 0.obs;
final totalEvents = events.scan<int>(
  0,
  (total, event, index) => total + event,
);

// Combine multiple observables
final firstName = 'John'.obs;
final lastName = 'Doe'.obs;
final fullName = Rx.combine2(
  firstName, lastName,
  (first, last) => '$first $last',
);
```

**Available Operators:**
- **Transform:** `map()`, `scan()`
- **Filter:** `where()`, `distinct()`, `whereNotNull()`
- **Combine:** `combine2()`, `combine3()`, `combineLatest()`
- **Nullable:** `defaultValue()`

### ✨ Stream Integration - Seamless Stream Binding

**What it is:** Seamlessly integrate Dart Streams with reactive values for real-time data.

**Why it's powerful:** Bridge the gap between reactive programming and stream-based APIs.

```dart
// Auto-managed (Widget-based)
final status = Rx.fromStream(
  statusStream,
  initial: Status.idle,
);

// Manual management in controllers
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

// Controller helper
final result = createRxFromStream<Data>(
  dataStream,
  initial: [],
);
final data = result.$1;
final subscription = result.$2;
```

**Benefits:**
- 🔄 **Automatic cleanup** - Streams managed by widget lifecycle
- 🎛️ **Manual control** - Full control over stream subscriptions
- 🔗 **Seamless integration** - Works with any Dart Stream
- 🛡️ **Memory safe** - Proper disposal prevents memory leaks

---

## 🚀 Improvements Over GetX

### Better Organization
- **Modular structure** - Each feature is independently usable
- **Clear separation** - UI, business logic, and navigation are completely decoupled
- **Consistent naming** - All APIs follow the `Jet*` convention

### Enhanced Documentation
- **Comprehensive guides** - Step-by-step tutorials for all features
- **Real-world examples** - Complete working applications
- **Best practices** - Proven patterns and performance tips
- **Quick reference** - Fast lookup for common patterns

### Bug Fixes
- **Computed Values** - Fixed critical bug where computed values weren't updating
- **Stream Registration** - Fixed stream listener registration in `JetListenable`
- **RxList Reactivity** - Fixed RxList changes not propagating through computed values
- **Memory Management** - Improved automatic cleanup of unused dependencies

### Modern Flutter Practices
- **Null safety** - Full null safety support
- **Performance optimized** - Minimal rebuilds with surgical precision
- **Testing friendly** - Easy to test with full lifecycle support
- **Platform agnostic** - Works on all Flutter platforms

---

## 🔄 Migration from GetX

### API Compatibility

JetX maintains **100% API compatibility** with GetX. Migration is straightforward:

```dart
// GetX → JetX
Get.to()           → Jet.to()
Get.put()          → Jet.put()
Get.find()         → Jet.find()
GetMaterialApp     → JetMaterialApp
GetxController     → JetxController
GetBuilder         → JetBuilder
GetView            → JetView
GetWidget          → JetWidget
GetxService        → JetxService
GetPage            → JetPage
GetConnect         → JetConnect
```

### Quick Migration Checklist

1. **Update dependencies**
   ```yaml
   dependencies:
     jetx: ^1.0.0  # Replace 'get'
   ```

2. **Update imports**
   ```dart
   // Old
   import 'package:get/get.dart';
   
   // New
   import 'package:jetx/jetx.dart';
   ```

3. **Update API calls** - Use the table above to replace `Get` with `Jet`

4. **Test your app** - Everything should work exactly the same!

### Breaking Changes from GetX 2.x

If migrating from older GetX versions:

**Rx Types Updated:**
```dart
// Old → New
StringX  → RxString
IntX     → RxInt
MapX     → RxMap
ListX    → RxList
NumX     → RxNum
DoubleX  → RxDouble
```

**Named Routes Structure:**
```dart
// Old (GetX 2.x)
JetMaterialApp(
  namedRoutes: {
    '/': JetRoute(page: Home()),
  }
)

// New (JetX)
JetMaterialApp(
  getPages: [
    JetPage(name: '/', page: () => Home()),
  ]
)
```

---

## 🗺️ Roadmap

### Planned Enhancements

**v1.1.0 (Coming Soon)**
- 🔄 **Enhanced Stream Operators** - More stream transformation utilities
- 🎨 **Theme Builder** - Declarative theme configuration
- 📱 **Responsive Helpers** - Better responsive design utilities
- 🧪 **Testing Utilities** - Enhanced testing helpers

**v1.2.0 (Future)**
- 🌐 **Web Optimizations** - Better web performance
- 📊 **DevTools Integration** - Debugging and profiling tools
- 🔌 **Plugin System** - Extensible architecture
- 📚 **More Examples** - Additional real-world applications

**Long Term**
- 🤖 **Code Generation** - Optional code generation for complex scenarios
- 🎯 **Performance Monitoring** - Built-in performance tracking
- 🔒 **Security Features** - Enhanced security utilities
- 🌍 **Community Packages** - Official community extensions

---

## 🎯 Why Choose JetX?

| Feature | GetX | JetX |
|---------|------|------|
| **Computed Values** | ❌ | ✅ |
| **Reactive Operators** | ❌ | ✅ |
| **Stream Integration** | ❌ | ✅ |
| **Active Maintenance** | ⚠️ | ✅ |
| **Modern Documentation** | ⚠️ | ✅ |
| **Bug Fixes** | ⚠️ | ✅ |
| **Performance** | ✅ | ✅ |
| **API Compatibility** | N/A | ✅ |

---

## 📚 Learn More

- **[State Management Guide](./state_management.md)** - Complete guide including new reactive features
- **[Quick Reference](./quick_reference.md)** - Fast lookup for all JetX features
- **[Advanced Features](./advanced_features.md)** - Overview of new reactive capabilities
- **[Migration Guide](../README.md#migration-guide)** - Detailed migration instructions

---

**Ready to experience the future of Flutter state management?** [Get started with JetX →](../README.md#quick-start)
