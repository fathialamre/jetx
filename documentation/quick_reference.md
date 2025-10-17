# JetX Quick Reference

Fast lookup for common JetX patterns and features.

---

## 🆕 What's New in JetX

### Quick Links
- **[Computed Values](#computed-values)** - Automatic derived state
- **[Reactive Operators](#reactive-operators)** - Functional transformations
- **[Stream Integration](#stream-integration)** - Seamless stream binding
- **[Full Documentation →](./whats_new_in_jetx.md)**

### New Features Summary
```dart
// Computed Values - Auto-updating derived state
late final total = computed(() => items.fold(0.0, (s, i) => s + i.price), watch: [items]);

// Reactive Operators - Transform, filter, combine
final validInput = input.where((text) => text.length >= 3);
final fullName = Rx.combine2(firstName, lastName, (a, b) => '$a $b');

// Stream Integration - Bind streams to reactive values
final status = Rx.fromStream(statusStream, initial: Status.idle);
```

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

### Custom Equality
```dart
final sortedItems = computed(
  () => items.toList()..sort(),
  watch: [items],
  equals: (a, b) => listEquals(a, b),
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

### Middleware
```dart
class AuthMiddleware extends JetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Jet.find<AuthService>();
    return authService.isAuthenticated ? null : RouteSettings(name: '/login');
  }
}

// Use with route
JetPage(
  name: '/dashboard',
  page: () => DashboardScreen(),
  middlewares: [AuthMiddleware()],
)
```

---

## Dependency Injection

### Basic Methods
```dart
// Put (immediate)
Jet.put(MyController());

// Lazy put (on first use)
Jet.lazyPut(() => HeavyService());

// Put async (async initialization)
Jet.putAsync(() => DatabaseService().init());

// Create (new instance each time)
Jet.create(() => ProductController());

// Find
final controller = Jet.find<MyController>();

// Delete
Jet.delete<MyController>();
```

### Bindings
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

---

## 🆕 Theming

### Change Theme
```dart
// Change to dark theme
Jet.changeTheme(ThemeData.dark());

// Toggle theme
Jet.changeTheme(Jet.isDarkMode ? ThemeData.light() : ThemeData.dark());

// Check current theme
if (Jet.isDarkMode) {
  // Dark mode is active
}
```

### Access Theme
```dart
// Get current theme
final currentTheme = Jet.theme;

// Use in widgets
Container(
  color: Jet.theme.primaryColor,
  child: Text('Themed Text', style: Jet.theme.textTheme.headline6),
)
```

### Reactive Theme
```dart
class ThemeController extends JetxController {
  final isDarkMode = false.obs;
  
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Jet.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }
}
```

---

## 🆕 Dialogs & Snackbars

### Dialogs
```dart
// Default dialog
Jet.defaultDialog(
  title: 'Title',
  middleText: 'Content',
  onConfirm: () => Jet.back(),
);

// Custom dialog
Jet.dialog(
  AlertDialog(
    title: Text('Custom Dialog'),
    content: Text('This is a custom dialog.'),
    actions: [
      TextButton(
        onPressed: () => Jet.back(),
        child: Text('Close'),
      ),
    ],
  ),
);

// Dialog with result
final result = await Jet.dialog(MyDialog());
```

### Snackbars
```dart
// Basic snackbar
Jet.snackbar('Title', 'Message');

// Customized snackbar
Jet.snackbar(
  'Success',
  'Operation completed!',
  backgroundColor: Colors.green,
  colorText: Colors.white,
  icon: Icon(Icons.check, color: Colors.white),
  snackPosition: SnackPosition.TOP,
);
```

### Bottom Sheets
```dart
// Basic bottom sheet
Jet.bottomSheet(
  Container(
    padding: EdgeInsets.all(20),
    child: Text('Bottom Sheet Content'),
  ),
);

// Customized bottom sheet
Jet.bottomSheet(
  Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Custom Bottom Sheet'),
        ElevatedButton(
          onPressed: () => Jet.back(),
          child: Text('Close'),
        ),
      ],
    ),
  ),
);
```

---

## 🆕 Internationalization

### Setup
```dart
class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'hello': 'Hello',
      'welcome': 'Welcome to JetX',
    },
    'es_ES': {
      'hello': 'Hola',
      'welcome': 'Bienvenido a JetX',
    },
  };
}

// Configure app
JetMaterialApp(
  translations: Messages(),
  locale: Locale('en', 'US'),
  fallbackLocale: Locale('en', 'US'),
  home: HomeScreen(),
)
```

### Usage
```dart
// Basic translation
Text('hello'.tr);

// With parameters
Text('welcome_user'.trParams({'name': 'John'}));

// Pluralization
Text('item'.trPlural('items', count));
```

### Dynamic Locale
```dart
// Change locale
Jet.updateLocale(Locale('es', 'ES'));

// Locale controller
class LocaleController extends JetxController {
  final currentLocale = Locale('en', 'US').obs;
  
  void changeLocale(Locale locale) {
    currentLocale.value = locale;
    Jet.updateLocale(locale);
  }
}
```

---

## Context Extensions

### Screen Dimensions
```dart
// Get screen dimensions
final width = context.width;
final height = context.height;

// Responsive container
Container(
  width: context.width * 0.8,  // 80% of screen width
  height: context.height * 0.5, // 50% of screen height
)
```

### Theme Access
```dart
// Access theme
final primaryColor = context.theme.primaryColor;
final isDark = context.isDarkMode;

// Responsive values
final fontSize = context.responsiveValue<double>(
  mobile: 16,
  tablet: 20,
  desktop: 24,
);
```

### Platform Detection
```dart
// Check platform
if (JetPlatform.isMobile) { }
if (JetPlatform.isTablet) { }
if (JetPlatform.isDesktop) { }
if (JetPlatform.isWeb) { }
if (JetPlatform.isAndroid) { }
if (JetPlatform.isIOS) { }
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

### Integration Test
```dart
testWidgets('Navigation works', (tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.tap(find.text('Go to Details'));
  await tester.pumpAndSettle();
  
  expect(find.text('Details Screen'), findsOneWidget);
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

### Search with Debouncing
```dart
class SearchController extends JetxController {
  final searchQuery = ''.obs;
  
  // Debounced and filtered search
  late final validQuery = searchQuery
      .where((q) => q.length >= 3)
      .distinct();
  
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

## 📚 For detailed examples, see:

- **[What's New in JetX](./whats_new_in_jetx.md)** - New features and improvements
- **[State Management Guide](./state_management.md)** - Complete reactive state management
- **[Route Management Guide](./route_management.md)** - Navigation without context
- **[Dependency Management Guide](./dependency_management.md)** - Smart dependency injection
- **[UI Features Guide](./ui_features.md)** - Theming, dialogs, snackbars, and more
- **[Internationalization Guide](./internationalization.md)** - Multi-language support

---

**Happy Coding with JetX! 🚀**