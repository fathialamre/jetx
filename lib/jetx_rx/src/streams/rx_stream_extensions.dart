import 'dart:async';

import '../../../jetx_state_manager/src/simple/jet_controllers.dart';
import '../rx_types/rx_types.dart';

/// Extensions for binding streams to reactive values with manual management
extension RxStreamManualBinding<T> on Rx<T> {
  /// Binds a stream and returns the subscription for manual management
  ///
  /// Unlike the built-in `bindStream()` which auto-manages the subscription,
  /// this returns a [StreamSubscription] that you must manually cancel.
  ///
  /// Example:
  /// ```dart
  /// final status = Status.idle.obs;
  ///
  /// // Auto-update status from stream
  /// final subscription = status.listenToStream(statusStream);
  ///
  /// // Later: manually cancel subscription
  /// subscription.cancel();
  /// ```
  StreamSubscription<T> listenToStream(Stream<T> stream) {
    return stream.listen(
      (value) => this.value = value,
      onError: (error) {
        // Optionally handle errors - for now we just ignore them
        // Users can handle errors in their stream
      },
    );
  }
}

/// Controller extension for stream lifecycle management
///
/// Controllers should store subscriptions and cancel them in onClose().
///
/// Example:
/// ```dart
/// class MyController extends JetxController {
///   final messages = <Message>[].obs;
///   late StreamSubscription _messageSub;
///
///   @override
///   void onInit() {
///     super.onInit();
///     _messageSub = messages.listenToStream(chatService.messagesStream);
///   }
///
///   @override
///   void onClose() {
///     _messageSub.cancel();
///     super.onClose();
///   }
/// }
/// ```
extension RxStreamControllerBinding on JetxController {
  /// Creates an Rx from a stream
  ///
  /// **Important:** You must cancel the subscription in onClose().
  ///
  /// Example:
  /// ```dart
  /// class MyController extends JetxController {
  ///   late final StreamSubscription _sub;
  ///
  ///   late final status = () {
  ///     final result = Rx<Status>.fromStreamManaged(statusStream, initial: Status.idle);
  ///     _sub = result.$2;
  ///     return result.$1;
  ///   }();
  ///
  ///   @override
  ///   void onClose() {
  ///     _sub.cancel();
  ///     super.onClose();
  ///   }
  /// }
  /// ```
  (Rx<T>, StreamSubscription<T>) createRxFromStream<T>(
    Stream<T> stream, {
    required T initial,
  }) {
    final rx = Rx<T>(initial);
    // ignore: cancel_subscriptions - returned to caller for manual management
    final subscription = rx.listenToStream(stream);
    return (rx, subscription);
  }
}

/// Static constructor extension for Rx
extension RxFromStream on Rx {
  /// Creates an Rx from a stream
  ///
  /// **Note:** You are responsible for cancelling the subscription.
  /// For automatic lifecycle management in controllers, use
  /// [RxStreamControllerBinding.rxFromStream] instead.
  ///
  /// Example:
  /// ```dart
  /// final sub = Rx.fromStreamWithSubscription(
  ///   statusStream,
  ///   initial: Status.idle,
  /// );
  /// final status = sub.$1;  // The Rx value
  /// final subscription = sub.$2;  // The subscription
  ///
  /// // Later: cancel when done
  /// subscription.cancel();
  /// status.close();
  /// ```
  static (Rx<T>, StreamSubscription<T>) fromStreamWithSubscription<T>(
    Stream<T> stream, {
    required T initial,
  }) {
    final rx = Rx<T>(initial);
    // ignore: cancel_subscriptions - returned to caller for manual management
    final subscription = rx.listenToStream(stream);
    return (rx, subscription);
  }

  /// Creates an Rx from a stream (simple version with auto-management)
  ///
  /// Uses the built-in `bindStream()` which automatically manages the
  /// subscription lifecycle based on widget observers.
  ///
  /// Example:
  /// ```dart
  /// final status = Rx.fromStream(
  ///   statusStream,
  ///   initial: Status.idle,
  /// );
  /// ```
  static Rx<T> fromStream<T>(
    Stream<T> stream, {
    required T initial,
  }) {
    final rx = Rx<T>(initial);
    rx.bindStream(stream); // Uses built-in auto-management
    return rx;
  }
}

/// Stream combining utilities
class RxStreams {
  /// Combines multiple streams into one
  ///
  /// Emits whenever any input stream emits.
  ///
  /// Example:
  /// ```dart
  /// final combined = RxStreams.combine2(
  ///   stream1,
  ///   stream2,
  ///   (a, b) => Result(a, b),
  /// );
  /// ```
  static Stream<R> combine2<A, B, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    R Function(A, B) combiner,
  ) async* {
    A? lastA;
    B? lastB;
    bool hasA = false;
    bool hasB = false;

    final controller = StreamController<R>();

    void tryEmit() {
      if (hasA && hasB) {
        controller.add(combiner(lastA as A, lastB as B));
      }
    }

    final subA = streamA.listen((a) {
      lastA = a;
      hasA = true;
      tryEmit();
    });

    final subB = streamB.listen((b) {
      lastB = b;
      hasB = true;
      tryEmit();
    });

    try {
      yield* controller.stream;
    } finally {
      await subA.cancel();
      await subB.cancel();
      await controller.close();
    }
  }

  /// Merges multiple streams into one
  ///
  /// Emits values from all input streams.
  ///
  /// Example:
  /// ```dart
  /// final merged = RxStreams.merge([
  ///   clickStream,
  ///   touchStream,
  ///   keyStream,
  /// ]);
  /// ```
  static Stream<T> merge<T>(List<Stream<T>> streams) async* {
    final controller = StreamController<T>();

    final subscriptions = <StreamSubscription<T>>[];
    for (final stream in streams) {
      subscriptions.add(
        stream.listen(
          (value) => controller.add(value),
          onError: (error) => controller.addError(error),
        ),
      );
    }

    try {
      yield* controller.stream;
    } finally {
      for (final sub in subscriptions) {
        await sub.cancel();
      }
      await controller.close();
    }
  }
}
