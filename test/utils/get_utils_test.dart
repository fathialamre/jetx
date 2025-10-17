import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

class TestClass {
  final name = "John";
}

class EmptyClass {}

void main() {
  dynamic newId(dynamic e) => e;

  test('null isNullOrBlank should be true for null', () {
    expect(JetUtils.isNullOrBlank(null), true);
  });

  test('isNullOrBlank should be false for unsupported types', () {
    expect(JetUtils.isNullOrBlank(5), false);
    expect(JetUtils.isNullOrBlank(0), false);

    expect(JetUtils.isNullOrBlank(5.0), equals(false));
    expect(JetUtils.isNullOrBlank(0.0), equals(false));

    TestClass? testClass;
    expect(JetUtils.isNullOrBlank(testClass), equals(true));
    expect(JetUtils.isNullOrBlank(TestClass()), equals(false));
    expect(JetUtils.isNullOrBlank(EmptyClass()), equals(false));
  });

  test('isNullOrBlank should validate strings', () {
    expect(JetUtils.isNullOrBlank(""), true);
    expect(JetUtils.isNullOrBlank("  "), true);

    expect(JetUtils.isNullOrBlank("foo"), false);
    expect(JetUtils.isNullOrBlank(" foo "), false);

    expect(JetUtils.isNullOrBlank("null"), false);
  });

  test('isNullOrBlank should validate iterables', () {
    expect(JetUtils.isNullOrBlank([].map(newId)), true);
    expect(JetUtils.isNullOrBlank([1].map(newId)), false);
  });

  test('isNullOrBlank should validate lists', () {
    expect(JetUtils.isNullOrBlank(const []), true);
    expect(JetUtils.isNullOrBlank(['oi', 'foo']), false);
    expect(JetUtils.isNullOrBlank([{}, {}]), false);
    expect(JetUtils.isNullOrBlank(['foo'][0]), false);
  });

  test('isNullOrBlank should validate sets', () {
    expect(JetUtils.isNullOrBlank(<dynamic>{}), true);
    expect(JetUtils.isNullOrBlank({1}), false);
    expect(JetUtils.isNullOrBlank({'fluorine', 'chlorine', 'bromine'}), false);
  });

  test('isNullOrBlank should validate maps', () {
    expect(JetUtils.isNullOrBlank({}), true);
    expect(JetUtils.isNullOrBlank({1: 1}), false);
    expect(JetUtils.isNullOrBlank({"other": "thing"}), false);

    final map = {"foo": 'bar', "one": "um"};
    expect(JetUtils.isNullOrBlank(map["foo"]), false);
    expect(JetUtils.isNullOrBlank(map["other"]), true);
  });
  group('JetUtils.isLength* functions', () {
    test('isLengthEqualTo should validate iterable lengths', () {
      // iterables should cover list and set
      expect(JetUtils.isLengthEqualTo([].map(newId), 0), true);
      expect(JetUtils.isLengthEqualTo([1, 2].map(newId), 2), true);

      expect(JetUtils.isLengthEqualTo({}, 0), true);
      expect(JetUtils.isLengthEqualTo({1: 1, 2: 1}, 2), true);
      expect(JetUtils.isLengthEqualTo({}, 2), false);

      expect(JetUtils.isLengthEqualTo("", 0), true);
      expect(JetUtils.isLengthEqualTo("a", 0), false);
      expect(JetUtils.isLengthEqualTo("a", 1), true);
    });

    test('isLengthGreaterOrEqual should validate lengths', () {
      // iterables should cover list and set
      expect(JetUtils.isLengthGreaterOrEqual([].map(newId), 0), true);
      expect(JetUtils.isLengthGreaterOrEqual([1, 2].map(newId), 2), true);
      expect(JetUtils.isLengthGreaterOrEqual([1, 2].map(newId), 1), true);

      expect(JetUtils.isLengthGreaterOrEqual({}, 0), true);
      expect(JetUtils.isLengthGreaterOrEqual({1: 1, 2: 1}, 1), true);
      expect(JetUtils.isLengthGreaterOrEqual({1: 1, 2: 1}, 2), true);
      expect(JetUtils.isLengthGreaterOrEqual({}, 2), false);

      expect(JetUtils.isLengthGreaterOrEqual("", 0), true);
      expect(JetUtils.isLengthGreaterOrEqual("a", 0), true);
      expect(JetUtils.isLengthGreaterOrEqual("", 1), false);
    });

    test('isLengthLessOrEqual should validate lengths', () {
      // iterables should cover list and set
      expect(JetUtils.isLengthLessOrEqual([].map(newId), 0), true);
      expect(JetUtils.isLengthLessOrEqual([1, 2].map(newId), 2), true);
      expect(JetUtils.isLengthLessOrEqual([1, 2].map(newId), 1), false);

      expect(JetUtils.isLengthLessOrEqual({}, 0), true);
      expect(JetUtils.isLengthLessOrEqual({1: 1, 2: 1}, 1), false);
      expect(JetUtils.isLengthLessOrEqual({1: 1, 2: 1}, 3), true);
      expect(JetUtils.isLengthLessOrEqual({}, 2), true);

      expect(JetUtils.isLengthLessOrEqual("", 0), true);
      expect(JetUtils.isLengthLessOrEqual("a", 2), true);
      expect(JetUtils.isLengthLessOrEqual("a", 0), false);
    });
  });
}
