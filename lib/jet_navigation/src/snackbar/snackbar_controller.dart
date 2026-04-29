import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../jetx.dart';
import '../root/jet_root.dart';

/// Default snackbar enter animation duration. Used when an animation finishes
/// from the swipe-dismiss path before resetting the controller.
const Duration kSnackbarEnterDuration = Duration(milliseconds: 200);

/// Default bottom sheet enter / exit animation durations.
const Duration kBottomSheetEnterDuration = Duration(milliseconds: 250);
const Duration kBottomSheetExitDuration = Duration(milliseconds: 200);

/// Default modal route transition for [JetModalBottomSheetRoute].
const Duration kBottomSheetTransitionDuration = Duration(milliseconds: 700);

/// Default dialog transition duration shared across [JetDialogRoute] and
/// helpers in `extension_navigation.dart`.
const Duration kDialogTransitionDuration = Duration(milliseconds: 200);

/// Reasons a snackbar may be dismissed; used to coalesce concurrent close
/// signals from overlay tap, swipe-dismiss, and timer expiration.
enum SnackbarDismissReason { none, timer, swipe, tap, programmatic }

class SnackbarController {
  final key = GlobalKey<JetSnackBarState>();

  static bool get isSnackbarBeingShown =>
      JetRootState.controller.config.snackBarQueue.isJobInProgress;

  late Animation<double> _filterBlurAnimation;
  late Animation<Color?> _filterColorAnimation;

  final JetSnackBar snackbar;
  final _transitionCompleter = Completer();

  late SnackbarStatusCallback? _snackbarStatus;
  late final Alignment? _initialAlignment;
  late final Alignment? _endAlignment;

  /// Coalesces dismissal signals (overlay tap, swipe, timer, programmatic)
  /// to prevent double-close races.
  SnackbarDismissReason _dismissReason = SnackbarDismissReason.none;

  /// Atomic guard around close paths. Set on first dismissal regardless of
  /// reason; consulted before kicking off another close.
  bool _isClosing = false;

  /// Tracks AnimationController lifecycle so dispose is idempotent across
  /// the early-close + swipe-dismiss + status-listener paths.
  bool _controllerDisposed = false;

  Timer? _timer;

  /// The animation that drives the route's transition and the previous route's
  /// forward transition.
  late final Animation<Alignment> _animation;

  /// The animation controller that the route uses to drive the transitions.
  ///
  /// The animation itself is exposed by the [animation] property.
  late final AnimationController _controller;

  SnackbarStatus? _currentStatus;

  final _overlayEntries = <OverlayEntry>[];

  OverlayState? _overlayState;

  SnackbarController(this.snackbar);

  Future<void> get future => _transitionCompleter.future;

  /// Close the snackbar with animation
  Future<void> close({bool withAnimations = true}) async {
    if (_isClosing && _dismissReason == SnackbarDismissReason.none) {
      // already closing via another path; just await final transition.
      if (!withAnimations) _removeOverlay();
      await future;
      return;
    }
    _isClosing = true;
    if (_dismissReason == SnackbarDismissReason.none) {
      _dismissReason = SnackbarDismissReason.programmatic;
    }
    if (!withAnimations) {
      _removeOverlay();
      return;
    }
    _removeEntry();
    await future;
  }

  /// Adds JetSnackbar to a view queue.
  /// Only one JetSnackbar will be displayed at a time, and this method returns
  /// a future to when the snackbar disappears.
  Future<void> show() {
    return JetRootState.controller.config.snackBarQueue.addJob(this);
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _timer = null;
  }

  // ignore: avoid_returning_this
  void _configureAlignment(SnackPosition snackPosition) {
    switch (snackbar.snackPosition) {
      case SnackPosition.top:
        {
          _initialAlignment = const Alignment(-1.0, -2.0);
          _endAlignment = const Alignment(-1.0, -1.0);
          break;
        }
      case SnackPosition.bottom:
        {
          _initialAlignment = const Alignment(-1.0, 2.0);
          _endAlignment = const Alignment(-1.0, 1.0);
          break;
        }
    }
  }

  bool _isTesting = false;

  void _configureOverlay() {
    _isTesting = Jet.overlayContext == null;
    _overlayState = _isTesting ? OverlayState() : Jet.key.currentState?.overlay;
    _overlayEntries.clear();
    _overlayEntries.addAll(_createOverlayEntries(_getBodyWidget()));
    if (!_isTesting) {
      _overlayState!.insertAll(_overlayEntries);
    }

    _configureSnackBarDisplay();
  }

  void _configureSnackBarDisplay() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot configure a snackbar after disposing it.');
    _controller = _createAnimationController();
    _configureAlignment(snackbar.snackPosition);
    _snackbarStatus = snackbar.snackbarStatus;
    _filterBlurAnimation = _createBlurFilterAnimation();
    _filterColorAnimation = _createColorOverlayColor();
    _animation = _createAnimation();
    _animation.addStatusListener(_handleStatusChanged);
    _configureTimer();
    _controller.forward();
  }

  void _configureTimer() {
    // Always cancel + null any existing timer before creating a new one
    // so a previously scheduled fire cannot survive replacement.
    _timer?.cancel();
    _timer = null;
    if (snackbar.duration != null) {
      _timer = Timer(snackbar.duration!, _removeEntry);
    }
  }

  /// Called to create the animation that exposes the current progress of
  /// the transition controlled by the animation controller created by
  /// `createAnimationController()`.
  Animation<Alignment> _createAnimation() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animation from a disposed snackbar');
    return AlignmentTween(begin: _initialAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _controller,
        curve: snackbar.forwardAnimationCurve,
        reverseCurve: snackbar.reverseAnimationCurve,
      ),
    );
  }

  /// Called to create the animation controller that will drive the transitions
  /// to this route from the previous one, and back to the previous route
  /// from this one.
  AnimationController _createAnimationController() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animationController from a disposed snackbar');
    assert(snackbar.animationDuration >= Duration.zero);
    return AnimationController(
      duration: snackbar.animationDuration,
      debugLabel: '$runtimeType',
      vsync: _overlayState!,
    );
  }

  Animation<double> _createBlurFilterAnimation() {
    return Tween(begin: 0.0, end: snackbar.overlayBlur).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Animation<Color?> _createColorOverlayColor() {
    return ColorTween(
            begin: const Color(0x00000000), end: snackbar.overlayColor)
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Iterable<OverlayEntry> _createOverlayEntries(Widget child) {
    return <OverlayEntry>[
      if (snackbar.overlayBlur > 0.0) ...[
        OverlayEntry(
          builder: (context) => GestureDetector(
            onTap: () {
              if (snackbar.isDismissible && !_isClosing) {
                _isClosing = true;
                _dismissReason = SnackbarDismissReason.tap;
                close();
              }
            },
            child: AnimatedBuilder(
              animation: _filterBlurAnimation,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: max(0.001, _filterBlurAnimation.value),
                    sigmaY: max(0.001, _filterBlurAnimation.value),
                  ),
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    color: _filterColorAnimation.value,
                  ),
                );
              },
            ),
          ),
          maintainState: false,
          opaque: false,
        ),
      ],
      OverlayEntry(
        builder: (context) => Semantics(
          focused: false,
          container: true,
          explicitChildNodes: true,
          child: AlignTransition(
            alignment: _animation,
            child: snackbar.isDismissible
                ? _getDismissibleSnack(child)
                : _getSnackbarContainer(child),
          ),
        ),
        maintainState: false,
        opaque: false,
      ),
    ];
  }

  Widget _getBodyWidget() {
    return Builder(builder: (_) {
      return MouseRegion(
        onEnter: (_) =>
            snackbar.onHover?.call(snackbar, SnackHoverState.entered),
        onExit: (_) => snackbar.onHover?.call(snackbar, SnackHoverState.exited),
        child: GestureDetector(
          behavior: snackbar.hitTestBehavior ?? HitTestBehavior.deferToChild,
          onTap: snackbar.onTap != null
              ? () => snackbar.onTap?.call(snackbar)
              : null,
          child: snackbar,
        ),
      );
    });
  }

  DismissDirection _getDefaultDismissDirection() {
    if (snackbar.snackPosition == SnackPosition.top) {
      return DismissDirection.up;
    }
    return DismissDirection.down;
  }

  Widget _getDismissibleSnack(Widget child) {
    return Dismissible(
      behavior: snackbar.hitTestBehavior ?? HitTestBehavior.opaque,
      direction: snackbar.dismissDirection ?? _getDefaultDismissDirection(),
      resizeDuration: null,
      confirmDismiss: (_) {
        if (_currentStatus == SnackbarStatus.opening ||
            _currentStatus == SnackbarStatus.closing) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      key: const Key('dismissible'),
      onDismissed: (_) {
        if (!_isClosing) {
          _isClosing = true;
        }
        _dismissReason = SnackbarDismissReason.swipe;
        _removeEntry();
      },
      child: _getSnackbarContainer(child),
    );
  }

  Widget _getSnackbarContainer(Widget child) {
    return Container(
      margin: snackbar.margin,
      child: child,
    );
  }

  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _currentStatus = SnackbarStatus.open;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;

        break;
      case AnimationStatus.forward:
        _currentStatus = SnackbarStatus.opening;
        _snackbarStatus?.call(_currentStatus);
        break;
      case AnimationStatus.reverse:
        _currentStatus = SnackbarStatus.closing;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        // Guard: overlay may already be cleared via early `_removeOverlay`.
        assert(_overlayEntries.isEmpty || !_overlayEntries.first.opaque);
        _currentStatus = SnackbarStatus.closed;
        _snackbarStatus?.call(_currentStatus);
        _removeOverlay();
        break;
    }
  }

  void _removeEntry() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot remove entry from a disposed snackbar',
    );

    _cancelTimer();

    if (_dismissReason == SnackbarDismissReason.swipe) {
      Timer(kSnackbarEnterDuration, () {
        if (!_controllerDisposed) {
          _controller.reset();
        }
      });
      _dismissReason = SnackbarDismissReason.none;
    } else {
      if (!_controllerDisposed) {
        _controller.reverse();
      }
    }
  }

  void _disposeController() {
    if (_controllerDisposed) return;
    _controllerDisposed = true;
    _controller.dispose();
  }

  void _removeOverlay() {
    if (!_isTesting) {
      for (var element in _overlayEntries) {
        element.remove();
      }
    }

    assert(!_transitionCompleter.isCompleted,
        'Cannot remove overlay from a disposed snackbar');
    _disposeController();
    _overlayEntries.clear();
    if (!_transitionCompleter.isCompleted) {
      _transitionCompleter.complete();
    }
  }

  Future<void> _show() {
    _configureOverlay();
    return future;
  }

  static Future<void> cancelAllSnackbars() async {
    await JetRootState.controller.config.snackBarQueue.cancelAllJobs();
  }

  static Future<void> closeCurrentSnackbar() async {
    await JetRootState.controller.config.snackBarQueue.closeCurrentJob();
  }
}

class SnackBarQueue {
  final _queue = JetQueue();
  final _snackbarList = <SnackbarController>[];

  SnackbarController? get _currentSnackbar {
    if (_snackbarList.isEmpty) return null;
    return _snackbarList.first;
  }

  bool get isJobInProgress => _snackbarList.isNotEmpty;

  Future<void> addJob(SnackbarController job) async {
    _snackbarList.add(job);
    final data = await _queue.add(job._show);
    _snackbarList.remove(job);
    return data;
  }

  Future<void> cancelAllJobs() async {
    await _currentSnackbar?.close();
    _queue.cancelAllJobs();
    _snackbarList.clear();
  }

  void disposeControllers() {
    final current = _currentSnackbar;
    if (current != null) {
      current._removeOverlay();
      current._disposeController();
      _snackbarList.remove(current);
    }

    _queue.cancelAllJobs();

    // Snapshot via toList() so dispose() side-effects on _snackbarList
    // (e.g. addJob removing entries) cannot mutate our iteration target.
    for (final element in _snackbarList.toList()) {
      element._disposeController();
    }
    _snackbarList.clear();
  }

  Future<void> closeCurrentJob() async {
    if (_currentSnackbar == null) return;
    await _currentSnackbar!.close();
  }
}
