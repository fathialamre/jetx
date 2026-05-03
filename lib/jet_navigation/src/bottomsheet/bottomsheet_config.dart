import 'package:flutter/material.dart';

/// Value-class wrapper around the parameters of `Jet.bottomSheet(...)`.
///
/// Same motivation as the snackbar / dialog configs: replace a
/// 16-parameter call site with a reusable, copyWith-friendly value.
@immutable
class JetBottomSheetConfig {
  final Widget bottomsheet;
  final Color? backgroundColor;
  final double? elevation;
  final bool persistent;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final Color? barrierColor;
  final bool? ignoreSafeArea;
  final bool isScrollControlled;
  final bool useRootNavigator;
  final bool isDismissible;
  final bool enableDrag;
  final RouteSettings? settings;
  final Duration? enterBottomSheetDuration;
  final Duration? exitBottomSheetDuration;
  final Curve? curve;

  const JetBottomSheetConfig({
    required this.bottomsheet,
    this.backgroundColor,
    this.elevation,
    this.persistent = true,
    this.shape,
    this.clipBehavior,
    this.barrierColor,
    this.ignoreSafeArea,
    this.isScrollControlled = false,
    this.useRootNavigator = false,
    this.isDismissible = true,
    this.enableDrag = true,
    this.settings,
    this.enterBottomSheetDuration,
    this.exitBottomSheetDuration,
    this.curve,
  });

  JetBottomSheetConfig copyWith({
    Widget? bottomsheet,
    Color? backgroundColor,
    double? elevation,
    bool? persistent,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool? ignoreSafeArea,
    bool? isScrollControlled,
    bool? useRootNavigator,
    bool? isDismissible,
    bool? enableDrag,
    RouteSettings? settings,
    Duration? enterBottomSheetDuration,
    Duration? exitBottomSheetDuration,
    Curve? curve,
  }) =>
      JetBottomSheetConfig(
        bottomsheet: bottomsheet ?? this.bottomsheet,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        elevation: elevation ?? this.elevation,
        persistent: persistent ?? this.persistent,
        shape: shape ?? this.shape,
        clipBehavior: clipBehavior ?? this.clipBehavior,
        barrierColor: barrierColor ?? this.barrierColor,
        ignoreSafeArea: ignoreSafeArea ?? this.ignoreSafeArea,
        isScrollControlled: isScrollControlled ?? this.isScrollControlled,
        useRootNavigator: useRootNavigator ?? this.useRootNavigator,
        isDismissible: isDismissible ?? this.isDismissible,
        enableDrag: enableDrag ?? this.enableDrag,
        settings: settings ?? this.settings,
        enterBottomSheetDuration:
            enterBottomSheetDuration ?? this.enterBottomSheetDuration,
        exitBottomSheetDuration:
            exitBottomSheetDuration ?? this.exitBottomSheetDuration,
        curve: curve ?? this.curve,
      );
}
