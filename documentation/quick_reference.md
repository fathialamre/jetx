# JetX Quick Reference

Fast lookup for common JetX patterns and features.

---

## Computed Values

### Basic
```dart
final count = 0.obs;
final doubled = computed(
  () => count.value * 2,
  watch: [count],
);
```

### Chained
```dart
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

---

## Reactive Operators

### Transform
```dart
// map
final celsius = 0.obs;
final fahrenheit = celsius.map((c) => c * 9/5 + 32);

// where (filter)
final input = ''.obs;
final valid = input.where((t) => t.length >= 3);

// distinct
final rapid = 0.obs;
final stable = rapid.distinct();

// scan (accumulate)
final events = 0.obs;
final total = events.scan<int>(0, (acc, val, i) => acc + val);
```

### Combine
```dart
// Two values
final fullName = Rx.combine2(
  firstName, lastName,
  (a, b) => '$a $b',
);

// Three values
final address = Rx.combine3(
  street, city, zip,
  (s, c, z) => '$s, $c $z',
);

// Multiple values
final average = Rx.combineLatest(
  sensors,
  (values) => values.reduce((a, b) => a + b) / values.length,
);
```

### Nullable
```dart
// whereNotNull
final nonNull = nullable.whereNotNull();

// defaultValue
final withDefault = nullable.defaultValue('N/A');
```

---

## Stream Integration

### Auto-Managed
```dart
final status = Rx.fromStream(
  statusStream,
  initial: Status.idle,
);
```

### Manual Management
```dart
class MyController extends JetxController {
  final data = <Data>[].obs;
  late StreamSubscription _sub;
  
  @override
  void onInit() {
    super.onInit();
    _sub = data.listenToStream(dataStream);
  }
  
  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}
```

### Controller Helper
```dart
final result = createRxFromStream<Data>(
  dataStream,
  initial: [],
);
final data = result.$1;
final subscription = result.$2;
```

---

## State Management

### Controller
```dart
class CounterController extends JetxController {
  var count = 0.obs;
  increment() => count++;
}
```

### View
```dart
class Home extends JetView<CounterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Text('${controller.count}')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
      ),
    );
  }
}
```

### Dependency Injection
```dart
// Put
Jet.put(CounterController());

// Lazy put
Jet.lazyPut(() => CounterController());

// Find
final controller = Jet.find<CounterController>();

// Delete
Jet.delete<CounterController>();
```

---

## Route Management

### Basic Navigation
```dart
// Go to screen
Jet.to(NextScreen());

// Named route
Jet.toNamed('/details');

// With arguments
Jet.toNamed('/user', arguments: userId);

// Back
Jet.back();

// Back with result
Jet.back(result: data);
```

### Named Routes
```dart
JetMaterialApp(
  initialRoute: '/home',
  getPages: [
    JetPage(name: '/home', page: () => HomeScreen()),
    JetPage(name: '/details', page: () => DetailsScreen()),
  ],
)
```

### Dialogs & Snackbars
```dart
// Dialog
Jet.defaultDialog(
  title: 'Title',
  middleText: 'Content',
);

// Snackbar
Jet.snackbar(
  'Title',
  'Message',
  snackPosition: SnackPosition.BOTTOM,
);

// Bottom sheet
Jet.bottomSheet(
  Container(child: Text('Content')),
);
```

---

## Lifecycle

### Controller Lifecycle
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

### Full Lifecycle
```dart
class MyController extends FullLifeCycleController {
  @override
  void onInit() => print('onInit');
  
  @override
  void onReady() => print('onReady');
  
  @override
  void onClose() => print('onClose');
  
  @override
  void onDetached() => print('onDetached');
  
  @override
  void onInactive() => print('onInactive');
  
  @override
  void onPaused() => print('onPaused');
  
  @override
  void onResumed() => print('onResumed');
}
```

---

## Reactive Workers

### ever - Every change
```dart
ever(count, (value) => print('Changed to $value'));
```

### once - First change only
```dart
once(count, (value) => print('Changed once to $value'));
```

### debounce - After inactivity
```dart
debounce(
  search,
  (value) => searchApi(value),
  time: Duration(milliseconds: 500),
);
```

### interval - Periodic
```dart
interval(
  count,
  (value) => print('Interval: $value'),
  time: Duration(seconds: 1),
);
```

---

## Bindings

### Simple Binding
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Jet.put(HomeController());
    Jet.lazyPut(() => ApiService());
  }
}

// Use with route
JetPage(
  name: '/home',
  page: () => HomeScreen(),
  binding: HomeBinding(),
)
```

### Bindings Builder
```dart
JetPage(
  name: '/home',
  page: () => HomeScreen(),
  binding: BindingsBuilder(() {
    Jet.put(HomeController());
  }),
)
```

---

## Utilities

### Context Extensions
```dart
context.width     // Screen width
context.height    // Screen height
context.theme     // Theme data
context.isDarkMode // Is dark mode
context.mediaQuery // Media query
```

### Responsive
```dart
// Responsive value
final value = context.responsiveValue<int>(
  mobile: 1,
  tablet: 2,
  desktop: 3,
);

// Screen type
if (context.isPhone) { }
if (context.isTablet) { }
if (context.isDesktop) { }
```

### Platform
```dart
JetPlatform.isWeb
JetPlatform.isAndroid
JetPlatform.isIOS
JetPlatform.isMobile
JetPlatform.isDesktop
```

---

## Testing

### Controller Test
```dart
test('Counter increments', () {
  final controller = CounterController();
  expect(controller.count.value, 0);
  
  controller.increment();
  expect(controller.count.value, 1);
});
```

### Widget Test
```dart
testWidgets('Counter displays value', (tester) async {
  Jet.put(CounterController());
  
  await tester.pumpWidget(
    JetMaterialApp(home: CounterView()),
  );
  
  expect(find.text('0'), findsOneWidget);
});
```

---

## Common Patterns

### Loading Data
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

### Form Validation
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

### Pagination
```dart
class PaginatedController extends JetxController {
  final items = <Item>[].obs;
  var page = 1;
  var hasMore = true;
  
  Future<void> loadMore() async {
    if (!hasMore) return;
    
    final newItems = await api.getItems(page);
    items.addAll(newItems);
    
    if (newItems.isEmpty) hasMore = false;
    page++;
  }
}
```

---

**📚 For detailed examples, see:**
- [Advanced Features Guide](./advanced_features.md)
- [State Management Guide](./state_management.md)
- [Route Management Guide](./route_management.md)

