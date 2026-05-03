import 'package:flutter/material.dart';

import '../snackbar/snackbar.dart';

/// Value-class wrapper around the parameters of `Jet.snackbar(...)`.
///
/// The legacy method signature has 30+ named parameters which makes it
/// painful to extend, share defaults, or pass around. This config class
/// captures the same surface as a single immutable value with a
/// `copyWith` so callers can build a base config (brand colors, default
/// duration) and tweak per-call.
@immutable
class JetSnackbarConfig {
  final String title;
  final String message;
  final Color? colorText;
  final Duration? duration;
  final bool instantInit;
  final SnackPosition? snackPosition;
  final Widget? titleText;
  final Widget? messageText;
  final Widget? icon;
  final bool? shouldIconPulse;
  final double? maxWidth;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final Color? backgroundColor;
  final Color? leftBarIndicatorColor;
  final List<BoxShadow>? boxShadows;
  final Gradient? backgroundGradient;
  final TextButton? mainButton;
  final OnTap? onTap;
  final OnHover? onHover;
  final bool? isDismissible;
  final bool? showProgressIndicator;
  final DismissDirection? dismissDirection;
  final AnimationController? progressIndicatorController;
  final Color? progressIndicatorBackgroundColor;
  final Animation<Color>? progressIndicatorValueColor;
  final SnackStyle? snackStyle;
  final Curve? forwardAnimationCurve;
  final Curve? reverseAnimationCurve;
  final Duration? animationDuration;
  final double? barBlur;
  final double? overlayBlur;
  final SnackbarStatusCallback? snackbarStatus;
  final Color? overlayColor;
  final Form? userInputForm;

  const JetSnackbarConfig({
    required this.title,
    required this.message,
    this.colorText,
    this.duration = const Duration(seconds: 3),
    this.instantInit = true,
    this.snackPosition,
    this.titleText,
    this.messageText,
    this.icon,
    this.shouldIconPulse,
    this.maxWidth,
    this.margin,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.leftBarIndicatorColor,
    this.boxShadows,
    this.backgroundGradient,
    this.mainButton,
    this.onTap,
    this.onHover,
    this.isDismissible,
    this.showProgressIndicator,
    this.dismissDirection,
    this.progressIndicatorController,
    this.progressIndicatorBackgroundColor,
    this.progressIndicatorValueColor,
    this.snackStyle,
    this.forwardAnimationCurve,
    this.reverseAnimationCurve,
    this.animationDuration,
    this.barBlur,
    this.overlayBlur,
    this.snackbarStatus,
    this.overlayColor,
    this.userInputForm,
  });

  JetSnackbarConfig copyWith({
    String? title,
    String? message,
    Color? colorText,
    Duration? duration,
    bool? instantInit,
    SnackPosition? snackPosition,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool? shouldIconPulse,
    double? maxWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    TextButton? mainButton,
    OnTap? onTap,
    OnHover? onHover,
    bool? isDismissible,
    bool? showProgressIndicator,
    DismissDirection? dismissDirection,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackStyle? snackStyle,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Duration? animationDuration,
    double? barBlur,
    double? overlayBlur,
    SnackbarStatusCallback? snackbarStatus,
    Color? overlayColor,
    Form? userInputForm,
  }) =>
      JetSnackbarConfig(
        title: title ?? this.title,
        message: message ?? this.message,
        colorText: colorText ?? this.colorText,
        duration: duration ?? this.duration,
        instantInit: instantInit ?? this.instantInit,
        snackPosition: snackPosition ?? this.snackPosition,
        titleText: titleText ?? this.titleText,
        messageText: messageText ?? this.messageText,
        icon: icon ?? this.icon,
        shouldIconPulse: shouldIconPulse ?? this.shouldIconPulse,
        maxWidth: maxWidth ?? this.maxWidth,
        margin: margin ?? this.margin,
        padding: padding ?? this.padding,
        borderRadius: borderRadius ?? this.borderRadius,
        borderColor: borderColor ?? this.borderColor,
        borderWidth: borderWidth ?? this.borderWidth,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        leftBarIndicatorColor:
            leftBarIndicatorColor ?? this.leftBarIndicatorColor,
        boxShadows: boxShadows ?? this.boxShadows,
        backgroundGradient: backgroundGradient ?? this.backgroundGradient,
        mainButton: mainButton ?? this.mainButton,
        onTap: onTap ?? this.onTap,
        onHover: onHover ?? this.onHover,
        isDismissible: isDismissible ?? this.isDismissible,
        showProgressIndicator:
            showProgressIndicator ?? this.showProgressIndicator,
        dismissDirection: dismissDirection ?? this.dismissDirection,
        progressIndicatorController:
            progressIndicatorController ?? this.progressIndicatorController,
        progressIndicatorBackgroundColor: progressIndicatorBackgroundColor ??
            this.progressIndicatorBackgroundColor,
        progressIndicatorValueColor:
            progressIndicatorValueColor ?? this.progressIndicatorValueColor,
        snackStyle: snackStyle ?? this.snackStyle,
        forwardAnimationCurve:
            forwardAnimationCurve ?? this.forwardAnimationCurve,
        reverseAnimationCurve:
            reverseAnimationCurve ?? this.reverseAnimationCurve,
        animationDuration: animationDuration ?? this.animationDuration,
        barBlur: barBlur ?? this.barBlur,
        overlayBlur: overlayBlur ?? this.overlayBlur,
        snackbarStatus: snackbarStatus ?? this.snackbarStatus,
        overlayColor: overlayColor ?? this.overlayColor,
        userInputForm: userInputForm ?? this.userInputForm,
      );
}
