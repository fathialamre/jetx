import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../jet.dart';
import '../router_report.dart';

/// JetRoot provides initialization and state management for JetX
///
/// This widget handles:
/// - Internationalization (locale, translations)
/// - Dependency injection (bindings)
/// - Lifecycle hooks (onInit, onReady, onDispose)
/// - Smart management configuration
/// - Logging configuration
class JetRoot extends StatefulWidget {
  final Widget child;
  final Translations? translations;
  final Map<String, Map<String, String>>? translationsKeys;
  final Locale? locale;
  final Locale? fallbackLocale;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final bool? enableLog;
  final LogWriterCallback? logWriterCallback;
  final SmartManagement smartManagement;
  final List<Bind> binds;

  const JetRoot({
    super.key,
    required this.child,
    this.translations,
    this.translationsKeys,
    this.locale,
    this.fallbackLocale,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.enableLog,
    this.logWriterCallback,
    this.smartManagement = SmartManagement.full,
    this.binds = const [],
  });

  @override
  State<JetRoot> createState() => JetRootState();

  static JetRootState of(BuildContext context) {
    final JetRootState? root =
        context.findRootAncestorStateOfType<JetRootState>();

    assert(() {
      if (root == null) {
        throw FlutterError(
          'JetRoot is required in your widget tree.\n'
          'Make sure you have a JetMaterialApp at the root of your app.',
        );
      }
      return true;
    }());
    return root!;
  }
}

class JetRootState extends State<JetRoot> with WidgetsBindingObserver {
  static JetRootState? _controller;

  static JetRootState get controller {
    if (_controller == null) {
      throw Exception('JetRoot is not initialized');
    }
    return _controller!;
  }

  @override
  void initState() {
    super.initState();
    JetRootState._controller = this;
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    _cleanup();
    WidgetsBinding.instance.removeObserver(this);
    _controller = null;
    super.dispose();
  }

  /// Initialize JetX
  void _initialize() {
    // Set up locale
    if (widget.locale != null) {
      Jet.locale = widget.locale;
    }

    // Set up fallback locale
    if (widget.fallbackLocale != null) {
      Jet.fallbackLocale = widget.fallbackLocale;
    }

    // Set up translations
    if (widget.translations != null) {
      Jet.addTranslations(widget.translations!.keys);
    } else if (widget.translationsKeys != null) {
      Jet.addTranslations(widget.translationsKeys!);
    }

    // Set up smart management
    Jet.smartManagement = widget.smartManagement;

    // Set up logging
    Jet.isLogEnable = widget.enableLog ?? kDebugMode;
    if (widget.logWriterCallback != null) {
      Jet.log = widget.logWriterCallback!;
    }

    // Initialize bindings (they are widgets, mount them through build tree)
    // No need to manually call anything here

    // Call onInit callback
    widget.onInit?.call();

    // Schedule onReady callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onReady?.call();
    });
  }

  /// Clean up resources
  void _cleanup() {
    // Call onDispose callback
    widget.onDispose?.call();

    // Clear translations
    Jet.clearTranslations();

    // Dispose router report
    RouterReportManager.dispose();

    // Reset Jet instance
    Jet.resetInstance(clearRouteBindings: true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes if needed
    super.didChangeAppLifecycleState(state);
  }
}
