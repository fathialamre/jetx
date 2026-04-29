import 'dart:async';

import '../jet_utils/jet_utils.dart';

extension JetNumUtils on num {
  bool isLowerThan(num b) => JetUtils.isLowerThan(this, b);

  bool isGreaterThan(num b) => JetUtils.isGreaterThan(this, b);

  bool isEqual(num b) => JetUtils.isEqual(this, b);

  /// Utility to delay some callback (or code execution).
  ///
  /// NOTE: this delay cannot be cancelled — it is a thin wrapper over
  /// [Future.delayed]. If you need a stoppable delay, build a
  /// `CancellableDelay` helper around `Timer` (`timer.cancel()` to abort) or
  /// use `Future.any([_delay, _cancellation.future])` and resolve a
  /// completer to break out early. We intentionally do not bundle a
  /// cancellable variant here because cancellation semantics (early-resolve
  /// vs. error vs. silent drop) are caller-specific and adding the wrong
  /// default is worse than leaving the helper minimal.
  ///
  /// Sample:
  /// ```
  /// void main() async {
  ///   print('+ wait for 2 seconds');
  ///   await 2.delay();
  ///   print('- 2 seconds completed');
  ///   print('+ callback in 1.2sec');
  ///   1.delay(() => print('- 1.2sec callback called'));
  ///   print('currently running callback 1.2sec');
  /// }
  ///```
  Future delay([FutureOr Function()? callback]) async => Future.delayed(
        Duration(milliseconds: (this * 1000).round()),
        callback,
      );
}
