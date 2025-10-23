part of '../rx_types.dart';

/// A computed observable that automatically tracks dependencies and recomputes
/// when any of its dependencies change.
///
/// Example:
/// ```dart
/// final products = <Product>[].obs;
/// final totalPrice = Computed(() =>
///   products.fold(0.0, (sum, p) => sum + p.price)
/// );
///
/// // In UI - auto-unwraps in string interpolation
/// Obx(() => Text('Total: $totalPrice'))
///
/// // Adding product triggers automatic recomputation
/// products.add(Product(price: 10.0));
/// ```
class Computed<T> extends GetListenable<T> with RxObjectMixin<T> {
  /// The computation function that produces the value
  final T Function() _computation;

  /// List of disposers for dependency subscriptions
  final List<VoidCallback> _disposers = [];

  /// Whether the computed value needs to be recalculated
  bool _isDirty = false;

  /// Whether we're currently computing (to prevent infinite loops)
  bool _isComputing = false;

  /// Creates a computed observable with the given computation function.
  /// The computation will be executed immediately with dependency tracking.
  Computed(this._computation) : super(_initialCompute(_computation)) {
    // Perform initial computation with dependency tracking
    // Note: we need to recompute to set up dependency tracking
    _recomputeInitial();
  }

  /// Helper to compute initial value without dependency tracking
  static T _initialCompute<T>(T Function() computation) {
    // Compute once without tracking to get initial value
    return computation();
  }

  /// Initial recomputation to set up dependency tracking
  void _recomputeInitial() {
    _isComputing = true;
    _isDirty = false;

    // Track dependencies during computation
    final disposers = <VoidCallback>[];
    final T newValue = Notifier.instance.append(
      NotifyData(
        updater: _onDependencyChanged,
        disposers: disposers,
        throwException: false,
      ),
      _computation,
    );

    // Store the new disposers
    _disposers.addAll(disposers);

    // Update the value if it changed (don't use setter to avoid triggering notifications during init)
    if (super.value != newValue) {
      super.value = newValue;
    }

    _isComputing = false;
  }

  @override
  T get value {
    if (_isDirty && !_isComputing) {
      _recompute();
    }
    reportRead();
    return super.value;
  }

  @override
  set value(T val) {
    // Computed values cannot be set directly
    throw UnsupportedError('Cannot set value directly on a Computed. '
        'The value is derived from its dependencies.');
  }

  /// Recomputes the value and tracks dependencies
  void _recompute() {
    if (_isComputing) {
      throw StateError('Circular dependency detected in Computed');
    }

    _isComputing = true;
    _isDirty = false;

    // Clear old subscriptions
    _clearDependencies();

    // Track dependencies during computation
    final disposers = <VoidCallback>[];
    final T newValue = Notifier.instance.append(
      NotifyData(
        updater: _onDependencyChanged,
        disposers: disposers,
        throwException: false, // Don't throw if no observables accessed
      ),
      _computation,
    );

    // Store the new disposers
    _disposers.addAll(disposers);

    // Update the value if it changed
    if (super.value != newValue) {
      super.value = newValue;
    }

    _isComputing = false;
  }

  /// Called when any dependency changes
  void _onDependencyChanged() {
    if (!_isDirty) {
      _isDirty = true;
      // Mark as dirty and notify listeners, but don't recompute yet (lazy)
      refresh();
    }
  }

  /// Clears all dependency subscriptions
  void _clearDependencies() {
    for (final disposer in _disposers) {
      disposer();
    }
    _disposers.clear();
  }

  @override
  void close() {
    _clearDependencies();
    super.close();
  }

  /// Returns the computed value as a string (enables auto-unwrapping)
  @override
  String toString() => value.toString();

  /// Returns the json representation of the computed value
  @override
  dynamic toJson() {
    final val = value;
    // Check if the value has a toJson method
    if (val == null) return null;

    // Try to call toJson if it exists, otherwise return the value itself
    try {
      return (val as dynamic).toJson();
    } catch (_) {
      // If toJson doesn't exist or fails, just return the value
      return val;
    }
  }
}
