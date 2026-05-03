// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../jet_instance/src/bindings_interface.dart';
import '../../../jet_state_manager/src/simple/jet_state.dart';
import '../../jet_navigation.dart';

class JetPage<T> extends Page<T> {
  final JetPageBuilder page;
  final bool? popGesture;
  final Map<String, String>? parameters;
  final String? title;
  final Transition? transition;
  final Curve curve;

  /// Optional curve used for the reverse (pop) direction. When null the
  /// forward [curve] is used in both directions. Lets apps tune
  /// "polish": e.g. a brisk easeOutQuad on push but a slow
  /// easeInOutCubic on pop.
  final Curve? reverseCurve;
  final bool? participatesInRootNavigator;
  final Alignment? alignment;
  final bool maintainState;
  final bool opaque;
  final double Function(BuildContext context)? gestureWidth;
  final BindingsInterface? binding;
  final List<BindingsInterface> bindings;
  final List<Bind> binds;
  final CustomTransition? customTransition;
  final Duration? transitionDuration;
  final Duration? reverseTransitionDuration;
  final bool fullscreenDialog;
  final bool preventDuplicates;
  final Completer<T?>? completer;
  // @override
  // final LocalKey? key;

  // @override
  // RouteSettings get settings => this;

  @override
  final Object? arguments;

  @override
  final String name;

  final bool inheritParentPath;

  final List<JetPage> children;
  final List<JetMiddleware> middlewares;
  final PathDecoded path;
  final JetPage? unknownRoute;
  final bool showCupertinoParallax;

  final PreventDuplicateHandlingMode preventDuplicateHandlingMode;

  /// Per-route fallback widget rendered when [page] (or its synchronous
  /// build path) throws. Receives the error and stack trace. If null,
  /// JetX renders a default `Material(child: Text(...))` so the app does
  /// not blank out. Errors thrown deeper in the descendant tree fall
  /// through to Flutter's `ErrorWidget.builder`; this hook only catches
  /// synchronous build-time exceptions in the page factory.
  final Widget Function(BuildContext context, Object error, StackTrace stack)?
      errorBuilder;

  /// Optional maximum time the page may stay on its initial frame
  /// before JetX swaps it for [onTimeout]. Useful for data-loading
  /// pages: if the network is slow, the user gets a fallback UI
  /// (typically a timeout / retry screen) instead of an indefinite
  /// spinner. The timer starts at first build of the page and is
  /// cancelled when the page is popped.
  ///
  /// Has no effect unless [onTimeout] is also non-null.
  final Duration? pageTimeout;

  /// Widget rendered after [pageTimeout] elapses. Receives the same
  /// `BuildContext` as the page itself.
  final Widget Function(BuildContext context)? onTimeout;

  static void _defaultPopInvokedHandler(bool didPop, Object? result) {}

  JetPage({
    required this.name,
    required this.page,
    this.title,
    this.participatesInRootNavigator,
    this.gestureWidth,
    // RouteSettings settings,
    this.maintainState = true,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.alignment,
    this.parameters,
    this.opaque = true,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.popGesture,
    this.binding,
    this.bindings = const [],
    this.binds = const [],
    this.transition,
    this.customTransition,
    this.fullscreenDialog = false,
    this.children = const <JetPage>[],
    this.middlewares = const [],
    this.unknownRoute,
    this.arguments,
    this.showCupertinoParallax = true,
    this.preventDuplicates = true,
    this.preventDuplicateHandlingMode =
        PreventDuplicateHandlingMode.reorderRoutes,
    this.completer,
    this.inheritParentPath = true,
    this.errorBuilder,
    this.pageTimeout,
    this.onTimeout,
    LocalKey? key,
    super.canPop,
    super.onPopInvoked = _defaultPopInvokedHandler,
    super.restorationId,
  })  : path = _nameToRegex(name),
        assert(name.startsWith('/'),
            'It is necessary to start route name [$name] with a slash: /$name'),
        super(
          key: key ?? ValueKey(name),
          name: name,
          // arguments: Jet.arguments,
        );
  // settings = RouteSettings(name: name, arguments: Jet.arguments);

  JetPage<T> copyWith({
    LocalKey? key,
    String? name,
    JetPageBuilder? page,
    bool? popGesture,
    Map<String, String>? parameters,
    String? title,
    Transition? transition,
    Curve? curve,
    Alignment? alignment,
    bool? maintainState,
    bool? opaque,
    List<BindingsInterface>? bindings,
    BindingsInterface? binding,
    List<Bind>? binds,
    CustomTransition? customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool? fullscreenDialog,
    RouteSettings? settings,
    List<JetPage<T>>? children,
    JetPage? unknownRoute,
    List<JetMiddleware>? middlewares,
    bool? preventDuplicates,
    final double Function(BuildContext context)? gestureWidth,
    bool? participatesInRootNavigator,
    Object? arguments,
    bool? showCupertinoParallax,
    Completer<T?>? completer,
    bool? inheritParentPath,
    bool? canPop,
    PopInvokedWithResultCallback<T>? onPopInvoked,
    String? restorationId,
    Widget Function(BuildContext, Object, StackTrace)? errorBuilder,
    Curve? reverseCurve,
    Duration? pageTimeout,
    Widget Function(BuildContext)? onTimeout,
  }) {
    return JetPage(
      key: key ?? this.key,
      participatesInRootNavigator:
          participatesInRootNavigator ?? this.participatesInRootNavigator,
      preventDuplicates: preventDuplicates ?? this.preventDuplicates,
      name: name ?? this.name,
      page: page ?? this.page,
      popGesture: popGesture ?? this.popGesture,
      parameters: parameters ?? this.parameters,
      title: title ?? this.title,
      transition: transition ?? this.transition,
      curve: curve ?? this.curve,
      alignment: alignment ?? this.alignment,
      maintainState: maintainState ?? this.maintainState,
      opaque: opaque ?? this.opaque,
      bindings: bindings ?? this.bindings,
      binds: binds ?? this.binds,
      binding: binding ?? this.binding,
      customTransition: customTransition ?? this.customTransition,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      reverseTransitionDuration:
          reverseTransitionDuration ?? this.reverseTransitionDuration,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      children: children ?? this.children,
      unknownRoute: unknownRoute ?? this.unknownRoute,
      middlewares: middlewares ?? this.middlewares,
      gestureWidth: gestureWidth ?? this.gestureWidth,
      arguments: arguments ?? this.arguments,
      showCupertinoParallax:
          showCupertinoParallax ?? this.showCupertinoParallax,
      completer: completer ?? this.completer,
      inheritParentPath: inheritParentPath ?? this.inheritParentPath,
      canPop: canPop ?? this.canPop,
      onPopInvoked: onPopInvoked ?? this.onPopInvoked,
      restorationId: restorationId ?? this.restorationId,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      pageTimeout: pageTimeout ?? this.pageTimeout,
      onTimeout: onTimeout ?? this.onTimeout,
    );
  }

  @override
  Route<T> createRoute(BuildContext context) {
    // return JetPageRoute<T>(settings: this, page: page);
    final page = PageRedirect(
      route: this,
      settings: this,
      unknownRoute: unknownRoute,
    ).getPageToRoute<T>(this, unknownRoute, context);

    return page;
  }

  static PathDecoded _nameToRegex(String path) {
    var keys = <String?>[];

    String recursiveReplace(Match pattern) {
      var buffer = StringBuffer('(?:');

      if (pattern[1] != null) buffer.write('.');
      buffer.write('([\\w%+-._~!\$&\'()*,;=:@]+))');
      if (pattern[3] != null) buffer.write('?');

      keys.add(pattern[2]);
      return "$buffer";
    }

    var stringPath = '$path/?'
        .replaceAllMapped(RegExp(r'(\.)?:(\w+)(\?)?'), recursiveReplace)
        .replaceAll('//', '/');

    return PathDecoded(RegExp('^$stringPath\$'), keys);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JetPage<T> && other.key == key;
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'Page')}("$name", $key, $arguments)';

  @override
  int get hashCode {
    return key.hashCode;
  }
}

@immutable
class PathDecoded {
  final RegExp regex;
  final List<String?> keys;
  const PathDecoded(this.regex, this.keys);

  @override
  int get hashCode => regex.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PathDecoded &&
        other.regex == regex; // && listEquals(other.keys, keys);
  }
}
