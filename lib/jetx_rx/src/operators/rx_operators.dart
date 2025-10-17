import '../computed/computed.dart';
import '../rx_types/rx_types.dart';
import '../rx_workers/rx_workers.dart';

/// Extensions adding reactive operators to [Rx]
///
/// These operators allow functional transformations and combinations
/// of reactive values.
extension RxOperators<T> on Rx<T> {
  /// Maps the value to a new reactive value
  ///
  /// Creates a computed value that transforms this value.
  ///
  /// Example:
  /// ```dart
  /// final count = 0.obs;
  /// final doubled = count.map((v) => v * 2);
  ///
  /// count.value = 5;
  /// print(doubled.value); // 10
  /// ```
  Computed<R> map<R>(R Function(T) transform) {
    return computed(() => transform(value), watch: [this]);
  }

  /// Filters values based on a predicate
  ///
  /// Only updates when the predicate returns true.
  ///
  /// Example:
  /// ```dart
  /// final input = ''.obs;
  /// final validInput = input.where((v) => v.length >= 3);
  ///
  /// input.value = 'ab'; // validInput doesn't update
  /// input.value = 'abc'; // validInput updates to 'abc'
  /// ```
  Rx<T> where(bool Function(T) predicate) {
    final filtered = Rx<T>(value);
    ever(this, (val) {
      if (predicate(val)) {
        filtered.value = val;
      }
    });
    return filtered;
  }

  /// Only emits distinct values
  ///
  /// Skips updates if the new value equals the previous value.
  ///
  /// Example:
  /// ```dart
  /// final rapid = 0.obs;
  /// final stable = rapid.distinct();
  ///
  /// rapid.value = 1;
  /// rapid.value = 1; // stable doesn't update (duplicate)
  /// rapid.value = 2; // stable updates
  /// ```
  Rx<T> distinct([bool Function(T, T)? equals]) {
    final distinctRx = Rx<T>(value);
    T? lastValue = value;

    ever(this, (val) {
      final isDifferent =
          equals != null ? !equals(lastValue as T, val) : lastValue != val;

      if (isDifferent) {
        lastValue = val;
        distinctRx.value = val;
      }
    });

    return distinctRx;
  }
}

/// Combines two reactive values
///
/// Creates a computed value that combines two observables.
///
/// Example:
/// ```dart
/// final firstName = 'John'.obs;
/// final lastName = 'Doe'.obs;
/// final fullName = Rx.combine2(
///   firstName,
///   lastName,
///   (first, last) => '$first $last',
/// );
///
/// print(fullName.value); // 'John Doe'
/// ```
extension RxCombine on Rx {
  static Computed<R> combine2<A, B, R>(
    Rx<A> a,
    Rx<B> b,
    R Function(A, B) combiner,
  ) {
    return computed(
      () => combiner(a.value, b.value),
      watch: [a, b],
    );
  }

  static Computed<R> combine3<A, B, C, R>(
    Rx<A> a,
    Rx<B> b,
    Rx<C> c,
    R Function(A, B, C) combiner,
  ) {
    return computed(
      () => combiner(a.value, b.value, c.value),
      watch: [a, b, c],
    );
  }

  static Computed<R> combine4<A, B, C, D, R>(
    Rx<A> a,
    Rx<B> b,
    Rx<C> c,
    Rx<D> d,
    R Function(A, B, C, D) combiner,
  ) {
    return computed(
      () => combiner(a.value, b.value, c.value, d.value),
      watch: [a, b, c, d],
    );
  }

  /// Combines a list of reactive values
  ///
  /// Example:
  /// ```dart
  /// final values = [1.obs, 2.obs, 3.obs];
  /// final sum = Rx.combineLatest(
  ///   values,
  ///   (vals) => vals.fold(0, (sum, val) => sum + val),
  /// );
  /// ```
  static Computed<R> combineLatest<T, R>(
    List<Rx<T>> observables,
    R Function(List<T>) combiner,
  ) {
    return computed(
      () => combiner(observables.map((rx) => rx.value).toList()),
      watch: observables,
    );
  }
}

/// Scan/reduce operator
///
/// Accumulates values over time.
extension RxScan<T> on Rx<T> {
  /// Accumulates values using an accumulator function
  ///
  /// Example:
  /// ```dart
  /// final clicks = 0.obs;
  /// final totalClicks = clicks.scan<int>(
  ///   0,
  ///   (acc, value, index) => acc + value,
  /// );
  ///
  /// clicks.value = 1; // totalClicks = 1
  /// clicks.value = 2; // totalClicks = 3
  /// clicks.value = 3; // totalClicks = 6
  /// ```
  Rx<R> scan<R>(
    R initialValue,
    R Function(R accumulated, T value, int index) accumulator,
  ) {
    final scanned = Rx<R>(initialValue);
    var index = 0;

    ever(this, (val) {
      scanned.value = accumulator(scanned.value, val, index);
      index++;
    });

    return scanned;
  }
}

/// Utility operators for working with nullable values
extension RxNullable<T> on Rx<T?> {
  /// Maps non-null values
  ///
  /// Only emits when value is not null.
  ///
  /// Example:
  /// ```dart
  /// final nullableValue = Rx<int?>(null);
  /// final doubled = nullableValue.whereNotNull().map((v) => v * 2);
  /// ```
  Rx<T> whereNotNull() {
    if (value == null) {
      throw StateError('Initial value is null. Cannot create whereNotNull().');
    }

    final nonNull = Rx<T>(value as T);
    ever(this, (val) {
      if (val != null) {
        nonNull.value = val;
      }
    });

    return nonNull;
  }

  /// Provides a default value for null
  ///
  /// Example:
  /// ```dart
  /// final nullable = Rx<String?>(null);
  /// final withDefault = nullable.defaultValue('N/A');
  /// print(withDefault.value); // 'N/A'
  /// ```
  Computed<T> defaultValue(T defaultVal) {
    return computed(() => value ?? defaultVal, watch: [this]);
  }
}
