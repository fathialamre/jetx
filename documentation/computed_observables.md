# Computed Observables

Computed observables are derived reactive values that automatically track their dependencies and recompute when any dependency changes. This feature is similar to computed values in MobX and provides a powerful way to derive state without manual management.

## What is a Computed Observable?

A computed observable is a reactive value that is calculated from other observables. It automatically:
- Tracks which observables are accessed during computation
- Subscribes to those observables
- Recomputes when any dependency changes
- Notifies its own listeners when the computed value changes

## Basic Usage

```dart
import 'package:jetx/jet.dart';

// Create observable data
final count = 5.obs;

// Create a computed value
final doubled = Computed(() => count.value * 2);

// Use in UI with auto-unwrapping
Obx(() => Text('Count: $count, Doubled: $doubled'))

// When count changes, doubled automatically updates
count.value = 10; // doubled will automatically become 20
```

## Multiple Dependencies

Computed values can automatically track multiple dependencies:

```dart
final price = 100.0.obs;
final quantity = 2.obs;
final taxRate = 0.1.obs;

final subtotal = Computed(() => price.value * quantity.value);
final tax = Computed(() => subtotal.value * taxRate.value);
final total = Computed(() => subtotal.value + tax.value);

// Changes to price, quantity, or taxRate automatically propagate
price.value = 150.0; // All dependent computed values update
```

## Working with Collections

Computed values work seamlessly with observable collections:

```dart
final products = <Product>[].obs;

final totalPrice = Computed(() => 
  products.fold(0.0, (sum, p) => sum + p.price)
);

final itemCount = Computed(() => products.length);

final averagePrice = Computed(() {
  if (products.isEmpty) return 0.0;
  return totalPrice.value / products.length;
});

// Add/remove items - computed values update automatically
products.add(Product('Widget', 29.99));
products.add(Product('Gadget', 49.99));
```

## String Interpolation (Auto-unwrapping)

Computed values automatically unwrap when used in string interpolation:

```dart
final name = 'John'.obs;
final age = 30.obs;

final greeting = Computed(() => 'Hello, ${name.value}!');
final description = Computed(() => '${name.value} is ${age.value} years old');

// In UI - no need for .value
Obx(() => Text('$greeting')) // Automatically unwraps
Obx(() => Text('$description'))
```

## Conditional Logic

Computed values can contain complex logic:

```dart
final score = 85.obs;

final grade = Computed(() {
  final s = score.value;
  if (s >= 90) return 'A';
  if (s >= 80) return 'B';
  if (s >= 70) return 'C';
  if (s >= 60) return 'D';
  return 'F';
});

final passed = Computed(() => score.value >= 60);
```

## Nested Computed Values

Computed values can depend on other computed values:

```dart
final price = 100.0.obs;
final quantity = 2.obs;

final subtotal = Computed(() => price.value * quantity.value);
final tax = Computed(() => subtotal.value * 0.1);
final total = Computed(() => subtotal.value + tax.value);

// Changing price updates subtotal, tax, and total automatically
```

## Lazy Recomputation

Computed values use lazy evaluation:
- They compute immediately when created (to set up dependency tracking)
- When a dependency changes, they mark themselves as dirty
- Recomputation happens only when the value is accessed
- Multiple accesses without dependency changes don't trigger recomputation

```dart
final count = 5.obs;
var computeCount = 0;

final doubled = Computed(() {
  computeCount++;
  return count.value * 2;
});

doubled.value; // computeCount = 2 (initial setup + tracking)
doubled.value; // computeCount = 2 (no recomputation)

count.value = 10; // Marks as dirty, but doesn't recompute yet

doubled.value; // computeCount = 3 (recomputes now)
doubled.value; // computeCount = 3 (no recomputation)
```

## Disposal

Computed values should be disposed when no longer needed:

```dart
final computed = Computed(() => someExpensiveCalculation());

// Later, when done
computed.close();
```

When used in JetX controllers, they'll be disposed automatically with the controller.

## Important Notes

1. **Read-only**: Computed values cannot be set directly. They're derived from their dependencies.

```dart
final doubled = Computed(() => count.value * 2);
doubled.value = 20; // ❌ Throws UnsupportedError
```

2. **Automatic Tracking**: Dependencies are tracked automatically. You don't need to manually specify them.

3. **Performance**: Computed values cache their result and only recompute when dependencies change.

4. **Circular Dependencies**: Avoid creating circular dependencies as they will throw a StateError.

```dart
// ❌ DON'T DO THIS
final a = Computed(() => b.value + 1);
final b = Computed(() => a.value + 1); // Circular!
```

## Example: Shopping Cart

Here's a complete example showing computed observables in action:

```dart
class CartController extends JetController {
  final products = <Product>[].obs;
  
  late final itemCount = Computed(() => products.length);
  
  late final subtotal = Computed(() => 
    products.fold(0.0, (sum, p) => sum + p.price)
  );
  
  late final shipping = Computed(() {
    if (subtotal.value >= 50) return 0.0; // Free shipping over $50
    return 5.99;
  });
  
  late final tax = Computed(() => subtotal.value * 0.1);
  
  late final total = Computed(() => 
    subtotal.value + shipping.value + tax.value
  );
  
  void addProduct(Product product) {
    products.add(product);
    // All computed values update automatically
  }
  
  void removeProduct(Product product) {
    products.remove(product);
    // All computed values update automatically
  }
}

// In your UI
class CartView extends JetView<CartController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(() => Text('Items: ${ controller.itemCount}')),
          Obx(() => Text('Subtotal: \$${controller.subtotal}')),
          Obx(() => Text('Shipping: \$${controller.shipping}')),
          Obx(() => Text('Tax: \$${controller.tax}')),
          Obx(() => Text('Total: \$${controller.total}', 
            style: TextStyle(fontWeight: FontWeight.bold)
          )),
        ],
      ),
    );
  }
}
```

## Best Practices

1. **Use for Derived State**: Use computed values for state that can be calculated from other observables.

2. **Keep Computations Pure**: Computed functions should not have side effects. They should only read observables and return a value.

3. **Avoid Heavy Computations**: While computed values cache their result, the computation itself should be reasonably fast.

4. **Break Down Complex Computations**: Use multiple computed values for complex calculations instead of one large computation.

```dart
// ✅ Good
final subtotal = Computed(() => calculateSubtotal());
final tax = Computed(() => subtotal.value * taxRate.value);
final total = Computed(() => subtotal.value + tax.value);

// ❌ Avoid
final everything = Computed(() {
  // Lots of complex logic here
  // Hard to debug and maintain
});
```

## Comparison with Manual Approach

**Without Computed:**
```dart
class Counter extends JetController {
  final count = 0.obs;
  final doubled = 0.obs;
  
  void increment() {
    count.value++;
    doubled.value = count.value * 2; // Manual update
  }
  
  void decrement() {
    count.value--;
    doubled.value = count.value * 2; // Manual update
  }
}
```

**With Computed:**
```dart
class Counter extends JetController {
  final count = 0.obs;
  late final doubled = Computed(() => count.value * 2); // Automatic!
  
  void increment() => count.value++;
  void decrement() => count.value--;
}
```

The computed approach is cleaner, less error-prone, and ensures consistency.

