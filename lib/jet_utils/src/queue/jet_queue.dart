import 'dart:async';

class JetMicrotask {
  int _version = 0;
  int _microtask = 0;

  int get microtask => _microtask;
  int get version => _version;

  void exec(Function callback) {
    if (_microtask == _version) {
      _microtask++;
      scheduleMicrotask(() {
        _version++;
        _microtask = _version;
        callback();
      });
    }
  }
}

class JetQueue {
  final List<_Item<dynamic>> _queue = [];
  bool _active = false;

  Future<T> add<T>(Future<T> Function() job) {
    final completer = Completer<T>();
    _queue.add(_Item<T>(completer, job));
    _check();
    return completer.future;
  }

  void cancelAllJobs() {
    _queue.clear();
  }

  Future<void> _check() async {
    if (_active) return;
    _active = true;
    try {
      while (_queue.isNotEmpty) {
        final item = _queue.removeAt(0);
        try {
          final result = await item.job();
          item.completer.complete(result);
        } on Exception catch (e, st) {
          item.completer.completeError(e, st);
        }
      }
    } finally {
      _active = false;
    }
  }
}

/// A queued unit of work. Generic in [T] so the [Completer] preserves the
/// caller's return type instead of decaying to `dynamic`.
class _Item<T> {
  final Completer<T> completer;
  final Future<T> Function() job;

  _Item(this.completer, this.job);
}
