import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jet.dart';

void main() {
  group('Computed Observable Tests', () {
    test('should compute initial value', () {
      final count = 5.obs;
      final doubled = Computed(() => count.value * 2);

      expect(doubled.value, 10);
    });

    test('should auto-unwrap in string interpolation', () {
      final count = 5.obs;
      final doubled = Computed(() => count.value * 2);

      expect('$doubled', '10');
    });

    test('should recompute when dependency changes', () {
      final count = 5.obs;
      final doubled = Computed(() => count.value * 2);

      expect(doubled.value, 10);

      count.value = 10;
      expect(doubled.value, 20);
    });

    test('should track multiple dependencies', () {
      final price = 100.0.obs;
      final quantity = 2.obs;
      final total = Computed(() => price.value * quantity.value);

      expect(total.value, 200.0);

      price.value = 150.0;
      expect(total.value, 300.0);

      quantity.value = 3;
      expect(total.value, 450.0);
    });

    test('should work with list dependencies', () {
      final products = <double>[10.0, 20.0, 30.0].obs;
      final total = Computed(() => products.fold(0.0, (sum, p) => sum + p));

      expect(total.value, 60.0);

      products.add(40.0);
      expect(total.value, 100.0);

      products.remove(10.0);
      expect(total.value, 90.0);
    });

    test('should work with nested computed values', () {
      final price = 100.0.obs;
      final quantity = 2.obs;
      final subtotal = Computed(() => price.value * quantity.value);
      final tax = Computed(() => subtotal.value * 0.1);
      final total = Computed(() => subtotal.value + tax.value);

      expect(total.value, 220.0);

      price.value = 200.0;
      expect(total.value, 440.0);
    });

    test('should throw error when trying to set computed value directly', () {
      final count = 5.obs;
      final doubled = Computed(() => count.value * 2);

      expect(
        () => doubled.value = 20,
        throwsUnsupportedError,
      );
    });

    test('should handle complex computations', () {
      final numbers = <int>[1, 2, 3, 4, 5].obs;
      final evenSum = Computed(() {
        return numbers.where((n) => n % 2 == 0).fold(0, (sum, n) => sum + n);
      });

      expect(evenSum.value, 6); // 2 + 4

      numbers.add(6);
      expect(evenSum.value, 12); // 2 + 4 + 6

      numbers.removeWhere((n) => n % 2 == 0);
      expect(evenSum.value, 0);
    });

    test('should not recompute if dependencies do not change', () {
      var computeCount = 0;
      final count = 5.obs;
      final doubled = Computed(() {
        computeCount++;
        return count.value * 2;
      });

      // Initial computation happens twice (once to get value, once to set up tracking)
      expect(doubled.value, 10);
      expect(computeCount, 2);

      // Accessing value again should not recompute
      expect(doubled.value, 10);
      expect(computeCount, 2);

      // Changing dependency should mark as dirty but not recompute yet
      count.value = 10;
      // Recomputation happens lazily on next access
      expect(doubled.value, 20);
      expect(computeCount, 3);
    });

    test('should properly dispose and clean up', () {
      final count = 5.obs;
      final doubled = Computed(() => count.value * 2);

      expect(doubled.value, 10);

      doubled.close();

      // After disposal, the computed should still hold its last value
      // but should be marked as disposed
      expect(doubled.isDisposed, true);
    });

    testWidgets('should work with Obx widget', (tester) async {
      final count = 0.obs;
      final doubled = Computed(() => count.value * 2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Obx(() => Text('Doubled: $doubled')),
          ),
        ),
      );

      expect(find.text('Doubled: 0'), findsOneWidget);

      count.value = 5;
      await tester.pump();

      expect(find.text('Doubled: 10'), findsOneWidget);
    });

    testWidgets('should trigger widget rebuild when computed value changes',
        (tester) async {
      final price = 100.0.obs;
      final quantity = 2.obs;
      final total = Computed(() => price.value * quantity.value);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Obx(() => Text('Total: $total')),
                ElevatedButton(
                  onPressed: () => price.value = 150.0,
                  child: const Text('Update Price'),
                ),
                ElevatedButton(
                  onPressed: () => quantity.value = 3,
                  child: const Text('Update Quantity'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Total: 200.0'), findsOneWidget);

      await tester.tap(find.text('Update Price'));
      await tester.pump();
      expect(find.text('Total: 300.0'), findsOneWidget);

      await tester.tap(find.text('Update Quantity'));
      await tester.pump();
      expect(find.text('Total: 450.0'), findsOneWidget);
    });

    test('should work with map observables', () {
      final cart = <String, int>{'apple': 2, 'banana': 3}.obs;
      final itemCount =
          Computed(() => cart.values.fold(0, (sum, v) => sum + v));

      expect(itemCount.value, 5);

      cart['orange'] = 4;
      expect(itemCount.value, 9);

      cart.remove('apple');
      expect(itemCount.value, 7);
    });

    test('should handle conditional logic in computations', () {
      final count = 5.obs;
      final message = Computed(() {
        if (count.value > 10) {
          return 'High';
        } else if (count.value > 5) {
          return 'Medium';
        } else {
          return 'Low';
        }
      });

      expect(message.value, 'Low');

      count.value = 7;
      expect(message.value, 'Medium');

      count.value = 15;
      expect(message.value, 'High');
    });

    test('should handle nullable types', () {
      final value = Rxn<int>(null);
      final computed = Computed(() => value.value ?? 0);

      expect(computed.value, 0);

      value.value = 5;
      expect(computed.value, 5);

      value.value = null;
      expect(computed.value, 0);
    });

    test('should support toJson for compatible types', () {
      final count = 5.obs;
      final doubled = Computed(() => count.value * 2);

      expect(doubled.toJson(), 10);
    });

    test('should recompute only when accessed after dependency change', () {
      var computeCount = 0;
      final count = 5.obs;
      final doubled = Computed(() {
        computeCount++;
        return count.value * 2;
      });

      // Initial computation on first access (happens twice: setup + tracking)
      expect(doubled.value, 10);
      expect(computeCount, 2);

      // Change dependency but don't access computed yet
      count.value = 10;
      // No immediate recomputation (lazy)
      expect(computeCount, 2);

      // Accessing triggers recomputation
      expect(doubled.value, 20);
      expect(computeCount, 3);
    });

    test('should work with boolean expressions', () {
      final age = 18.obs;
      final isAdult = Computed(() => age.value >= 18);

      expect(isAdult.value, true);

      age.value = 15;
      expect(isAdult.value, false);

      age.value = 21;
      expect(isAdult.value, true);
    });

    test('should handle string computations', () {
      final firstName = 'John'.obs;
      final lastName = 'Doe'.obs;
      final fullName = Computed(() => '${firstName.value} ${lastName.value}');

      expect(fullName.value, 'John Doe');

      firstName.value = 'Jane';
      expect(fullName.value, 'Jane Doe');

      lastName.value = 'Smith';
      expect(fullName.value, 'Jane Smith');
    });
  });
}
