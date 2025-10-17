# JetX Advanced Features

JetX introduces powerful new reactive programming features that significantly enhance developer productivity and code quality. These features are not available in the original GetX.

---

## 🆕 What's New in JetX

JetX adds three major new reactive features:

### ✨ Computed Values
Automatically recompute reactive values when dependencies change - no manual updates needed!

```dart
class CartController extends JetxController {
  final items = <Item>[].obs;
  
  // Automatically recomputes when items change!
  late final total = computed(
    () => items.fold(0.0, (sum, item) => sum + item.price),
    watch: [items],
  );
}
```

### ✨ Reactive Operators
Functional programming patterns for reactive values - transform, filter, combine!

```dart
// Transform
final fahrenheit = celsius.map((c) => c * 9/5 + 32);

// Filter
final validInput = input.where((text) => text.length >= 3);

// Combine
final fullName = Rx.combine2(firstName, lastName, (a, b) => '$a $b');
```

### ✨ Stream Integration
Seamlessly integrate Dart Streams with reactive values.

```dart
// Auto-managed
final status = Rx.fromStream(statusStream, initial: Status.idle);

// Manual management
_subscription = data.listenToStream(stream);
```

---

## 📚 Full Documentation

For complete documentation with detailed examples, see:

### **[State Management Guide](./state_management.md#-advanced-reactive-features)**
- **Computed Values** - Automatic derived state with examples
- **Reactive Operators** - Transform, filter, combine operators
- **Stream Integration** - Seamless stream binding
- **Best Practices** - Performance tips and patterns

### **[What's New in JetX](./whats_new_in_jetx.md)**
- Complete overview of new features
- Migration guide from GetX
- Performance comparisons
- Roadmap and future plans

### **[Quick Reference](./quick_reference.md)**
- Fast lookup for all advanced features
- Code snippets and patterns
- Common use cases

---

## 🚀 Quick Examples

### Computed Values
```dart
// Shopping cart with automatic totals
late final subtotal = computed(() => items.fold(0.0, (s, i) => s + i.price), watch: [items]);
late final tax = computed(() => subtotal.value * 0.08, watch: [subtotal]);
late final total = computed(() => subtotal.value + tax.value, watch: [subtotal, tax]);
```

### Reactive Operators
```dart
// Search with debouncing and filtering
late final validQuery = searchQuery
    .where((q) => q.length >= 3)
    .distinct();

// Temperature conversion
final fahrenheit = celsius.map((c) => c * 9/5 + 32);
```

### Stream Integration
```dart
// Real-time chat
_subscription = messages.listenToStream(chatService.messagesStream);

// Status updates
final status = Rx.fromStream(api.statusStream, initial: Status.idle);
```

---

## 🎯 Why Use Advanced Features?

- **🚀 Zero Boilerplate** - No manual state synchronization
- **⚡ Performance** - Only recomputes when dependencies change
- **🔗 Declarative** - Clean, functional programming patterns
- **🛡️ Type Safe** - Full type safety and null safety support
- **🧪 Testable** - Easy to test with predictable behavior

---

## 📖 Learn More

- **[Complete State Management Guide](./state_management.md)** - Everything about JetX state management
- **[What's New in JetX](./whats_new_in_jetx.md)** - New features and improvements
- **[Quick Reference](./quick_reference.md)** - Fast lookup for all features
- **[Examples](../example/)** - Working example applications

---

**Ready to experience the power of modern reactive programming?** [Get started with JetX →](../README.md#quick-start)