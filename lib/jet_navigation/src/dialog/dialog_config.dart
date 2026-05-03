import 'package:flutter/material.dart';

/// Value-class wrapper around the parameters of `Jet.dialog(...)`.
///
/// Lets callers build a base config (brand barrier color, default
/// transition) and reuse it across dialogs without retyping every
/// named parameter.
@immutable
class JetDialogConfig {
  final Widget content;
  final bool barrierDismissible;
  final Color? barrierColor;
  final bool useSafeArea;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Object? arguments;
  final Duration? transitionDuration;
  final Curve? transitionCurve;
  final String? name;
  final RouteSettings? routeSettings;
  final String? id;

  const JetDialogConfig({
    required this.content,
    this.barrierDismissible = true,
    this.barrierColor,
    this.useSafeArea = true,
    this.navigatorKey,
    this.arguments,
    this.transitionDuration,
    this.transitionCurve,
    this.name,
    this.routeSettings,
    this.id,
  });

  JetDialogConfig copyWith({
    Widget? content,
    bool? barrierDismissible,
    Color? barrierColor,
    bool? useSafeArea,
    GlobalKey<NavigatorState>? navigatorKey,
    Object? arguments,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? name,
    RouteSettings? routeSettings,
    String? id,
  }) =>
      JetDialogConfig(
        content: content ?? this.content,
        barrierDismissible: barrierDismissible ?? this.barrierDismissible,
        barrierColor: barrierColor ?? this.barrierColor,
        useSafeArea: useSafeArea ?? this.useSafeArea,
        navigatorKey: navigatorKey ?? this.navigatorKey,
        arguments: arguments ?? this.arguments,
        transitionDuration: transitionDuration ?? this.transitionDuration,
        transitionCurve: transitionCurve ?? this.transitionCurve,
        name: name ?? this.name,
        routeSettings: routeSettings ?? this.routeSettings,
        id: id ?? this.id,
      );
}
