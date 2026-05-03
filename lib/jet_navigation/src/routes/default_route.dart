import 'dart:async';

import 'package:flutter/material.dart';

import '../../../jetx.dart';
import '../root/jet_root.dart';
import '../router_report.dart';

@optionalTypeArgs
mixin RouteReportMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  @override
  void dispose() {
    super.dispose();
    RouterReportManager.instance.reportRouteDispose(this);
  }
}

mixin PageRouteReportMixin<T> on Route<T> {
  @override
  void install() {
    super.install();
    RouterReportManager.instance.reportCurrentRoute(this);
  }

  @override
  void dispose() {
    super.dispose();
    RouterReportManager.instance.reportRouteDispose(this);
  }
}

class JetPageRoute<T> extends PageRoute<T>
    with JetPageRouteTransitionMixin<T>, PageRouteReportMixin {
  /// Creates a page route for use in an iOS designed app.
  ///
  /// The [builder], [maintainState], and [fullscreenDialog] arguments must not
  /// be null.
  JetPageRoute({
    super.settings,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.parameter,
    this.gestureWidth,
    this.curve,
    this.alignment,
    this.transition,
    this.popGesture,
    this.customTransition,
    this.barrierDismissible = false,
    this.barrierColor,
    BindingsInterface? binding,
    List<BindingsInterface> bindings = const [],
    this.binds,
    this.routeName,
    this.page,
    this.title,
    this.showCupertinoParallax = true,
    this.barrierLabel,
    this.maintainState = true,
    super.fullscreenDialog,
    this.middlewares,
    this.errorBuilder,
    this.reverseCurve,
    this.pageTimeout,
    this.onTimeout,
  })  : bindings = (binding == null) ? bindings : [...bindings, binding],
        _middlewareRunner = MiddlewareRunner(middlewares);

  @override
  final Duration transitionDuration;
  @override
  final Duration reverseTransitionDuration;

  final JetPageBuilder? page;
  final String? routeName;
  //final String reference;
  final CustomTransition? customTransition;
  final List<BindingsInterface> bindings;
  final Map<String, String>? parameter;
  final List<Bind>? binds;

  @override
  final bool showCupertinoParallax;

  @override
  final bool opaque;
  final bool? popGesture;

  @override
  final bool barrierDismissible;
  final Transition? transition;
  final Curve? curve;
  final Alignment? alignment;
  final List<JetMiddleware>? middlewares;
  final Widget Function(BuildContext context, Object error, StackTrace stack)?
      errorBuilder;
  final Curve? reverseCurve;
  final Duration? pageTimeout;
  final Widget Function(BuildContext context)? onTimeout;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  final MiddlewareRunner _middlewareRunner;

  @override
  void dispose() {
    super.dispose();
    _middlewareRunner.runOnPageDispose();
    _child = null;
  }

  Widget? _child;

  Widget _getChild() {
    if (_child != null) return _child!;

    final localBinds = [if (binds != null) ...binds!];

    final bindingsToBind = _middlewareRunner
        .runOnBindingsStart(bindings.isNotEmpty ? bindings : localBinds);

    final pageToBuild = _middlewareRunner.runOnPageBuildStart(page)!;

    Widget safeBuild() {
      try {
        final built = pageToBuild();
        // Phase 3.2: optional per-route timeout host. Wraps the built
        // widget; after `pageTimeout` elapses, swaps to `onTimeout`.
        if (pageTimeout != null && onTimeout != null) {
          return _PageTimeoutHost(
            timeout: pageTimeout!,
            onTimeout: onTimeout!,
            child: built,
          );
        }
        return built;
      } catch (error, stack) {
        // Pull global onException via JetRootState if the tree is up; the
        // null check protects test harnesses that build a JetPageRoute
        // outside a JetRoot subtree.
        if (JetRoot.treeInitialized) {
          Jet.rootController.config.onException?.call(error, stack);
        }
        return _ErrorPageHost(
            errorBuilder: errorBuilder, error: error, stack: stack);
      }
    }

    if (bindingsToBind != null && bindingsToBind.isNotEmpty) {
      if (bindingsToBind is List<BindingsInterface>) {
        for (final item in bindingsToBind) {
          final dep = item.dependencies();
          if (dep is List<Bind>) {
            _child = Binds(
              binds: dep,
              child: _middlewareRunner.runOnPageBuilt(safeBuild()),
            );
          }
        }
      } else if (bindingsToBind is List<Bind>) {
        _child = Binds(
          binds: bindingsToBind,
          child: _middlewareRunner.runOnPageBuilt(safeBuild()),
        );
      }
    }

    return _child ??= _middlewareRunner.runOnPageBuilt(safeBuild());
  }

  @override
  Widget buildContent(BuildContext context) {
    return _getChild();
  }

  @override
  final String? title;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  final double Function(BuildContext context)? gestureWidth;
}

/// Internal widget used by [JetPageRoute] to render either the per-route
/// `errorBuilder` (if supplied) or a default Material fallback when the
/// page factory throws synchronously. Lives in the widget tree so the
/// builder runs with a real `BuildContext`.
class _ErrorPageHost extends StatelessWidget {
  const _ErrorPageHost({
    required this.errorBuilder,
    required this.error,
    required this.stack,
  });

  final Widget Function(BuildContext context, Object error, StackTrace stack)?
      errorBuilder;
  final Object error;
  final StackTrace stack;

  @override
  Widget build(BuildContext context) {
    if (errorBuilder != null) return errorBuilder!(context, error, stack);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error building page:\n$error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

/// Internal widget that swaps its child for an `onTimeout` widget after
/// a deadline. Used by [JetPageRoute] when the source [JetPage]
/// declares both `pageTimeout` and `onTimeout`.
///
/// Contract: timer starts on first [State.initState] of this widget
/// (i.e. the page's first build), is cancelled if the page is popped
/// before the deadline, and shows the [onTimeout] widget for the rest
/// of the page's lifetime once it fires.
class _PageTimeoutHost extends StatefulWidget {
  const _PageTimeoutHost({
    required this.timeout,
    required this.onTimeout,
    required this.child,
  });

  final Duration timeout;
  final Widget Function(BuildContext context) onTimeout;
  final Widget child;

  @override
  State<_PageTimeoutHost> createState() => _PageTimeoutHostState();
}

class _PageTimeoutHostState extends State<_PageTimeoutHost> {
  Timer? _timer;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.timeout, () {
      if (!mounted) return;
      setState(() => _expired = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _expired ? widget.onTimeout(context) : widget.child;
}
