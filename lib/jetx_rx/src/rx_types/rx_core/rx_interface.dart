part of '../rx_types.dart';

/// This class is the foundation for all reactive (Rx) classes that makes Get
/// so powerful.
/// This interface is the contract that `_RxImpl<T>` uses in all it's
/// subclass.
abstract class RxInterface<T> implements ValueListenable<T> {
  /// Close the Rx Variable
  void close();

  /// Calls `callback` with current value, when the value changes.
  StreamSubscription<T> listen(void Function(T event) onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError});
}

class ObxError {
  const ObxError();
  @override
  String toString() {
    return """
      [Get] the improper use of a JetX has been detected. 
      You should only use JetX or Obx for the specific widget that will be updated.
      If you are seeing this error, you probably did not insert any observable variables into JetX/Obx 
      or insert them outside the scope that JetX considers suitable for an update 
      (example: JetX => HeavyWidget => variableObservable).
      If you need to update a parent widget and a child widget, wrap each one in an Obx/GetX.
      """;
  }
}
