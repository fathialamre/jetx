import '../../../jetx_state_manager/src/rx_flutter/rx_notifier.dart';
import '../rx_types/rx_types.dart';
import '../rx_workers/rx_workers.dart';

/// A computed reactive value that recomputes when specified dependencies change.
///
/// Unlike automatic tracking, you explicitly provide the dependencies to watch.
/// This makes the behavior predictable and performant.
///
/// Example:
/// ```dart
/// final firstName = 'John'.obs;
/// final lastName = 'Doe'.obs;
///
/// final fullName = computed(
///   () => '${firstName.value} ${lastName.value}',
///   watch: [firstName, lastName],
/// );
///
/// print(fullName.value); // 'John Doe'
/// firstName.value = 'Jane';
/// // fullName automatically recomputes
/// print(fullName.value); // 'Jane Doe'
/// ```
class Computed<T> extends Rx<T> {
  /// The computation function
  final T Function() _compute;

  /// Custom equality function
  final bool Function(T, T)? _equals;

  /// Dependencies to watch
  final List<JetListenable> _dependencies;

  /// Workers for each dependency
  final List<Worker> _workers = [];

  /// Creates a computed reactive value
  ///
  /// The [compute] function will be called to calculate the value.
  ///
  /// [watch] specifies the reactive values to observe. When any of them change,
  /// the computed value will be recalculated.
  ///
  /// [equals] can be provided for custom equality checking. If not provided,
  /// uses `==` operator to avoid unnecessary updates.
  ///
  /// Example:
  /// ```dart
  /// final items = <Item>[].obs;
  ///
  /// // Recomputes total when items change
  /// final total = computed(
  ///   () => items.fold(0.0, (sum, item) => sum + item.price),
  ///   watch: [items],
  /// );
  ///
  /// // Multiple dependencies
  /// final tax = 0.08.obs;
  /// final subtotal = computed(() => items.fold(0.0, (s, i) => s + i.price), watch: [items]);
  /// final grandTotal = computed(() => subtotal.value * (1 + tax.value), watch: [subtotal, tax]);
  /// ```
  Computed(
    this._compute, {
    required List<JetListenable> watch,
    bool Function(T, T)? equals,
  })  : _equals = equals,
        _dependencies = watch,
        super(_compute()) {
    // Set up workers to recompute when dependencies change
    for (final dependency in _dependencies) {
      final worker = ever(dependency, (_) => _recompute());
      _workers.add(worker);
    }
  }

  @override
  set value(T newValue) {
    // Computed values cannot be set directly
    throw UnsupportedError(
      'Cannot set value of a Computed. '
      'Computed values are read-only and automatically recompute based on dependencies.',
    );
  }

  /// Recomputes the value and updates if changed
  void _recompute() {
    final newValue = _compute();

    // Check if value actually changed
    final hasChanged =
        _equals != null ? !_equals(value, newValue) : value != newValue;

    if (hasChanged) {
      // Update the internal value (this will also notify via refresh())
      super.value = newValue;
    }
  }

  /// Manually trigger recomputation
  ///
  /// Normally not needed as computed values automatically update
  /// when dependencies change, but can be useful in some cases.
  void recompute() {
    _recompute();
  }

  @override
  void close() {
    // Dispose all workers
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.close();
  }
}

/// Global function to create a computed value
///
/// This is a convenience function that creates a [Computed] instance.
///
/// Example:
/// ```dart
/// final count = 0.obs;
/// final doubled = computed(() => count.value * 2, watch: [count]);
///
/// // With custom equality
/// final items = <String>[].obs;
/// final sorted = computed(
///   () => items.toList()..sort(),
///   watch: [items],
///   equals: (a, b) => listEquals(a, b),
/// );
/// ```
Computed<T> computed<T>(
  T Function() compute, {
  required List<JetListenable> watch,
  bool Function(T, T)? equals,
}) {
  return Computed<T>(compute, watch: watch, equals: equals);
}
