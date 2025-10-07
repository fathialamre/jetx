import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../instance_manager.dart';

import '../../../jet_state_manager/jet_state_manager.dart';
import '../../jet_navigation.dart';
import '../router/jet_router_config.dart';
import 'jet_root.dart';

/// JetX Material App with pure Navigator 2.0 implementation
///
/// This is the main app widget that provides Navigator 2.0 navigation,
/// state management, internationalization, and more.
///
/// Example:
/// ```dart
/// JetMaterialApp(
///   title: 'My App',
///   routes: [
///     JetPage(name: '/', page: () => HomePage()),
///     JetPage(name: '/profile', page: () => ProfilePage()),
///   ],
///   initialRoute: '/',
/// )
/// ```
class JetMaterialApp extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Color? color;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;
  final ThemeMode themeMode;
  final Locale? locale;
  final Locale? fallbackLocale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool debugShowMaterialGrid;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<LogicalKeySet, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final ScrollBehavior? scrollBehavior;
  final TransitionBuilder? builder;

  // JetX-specific properties
  final List<JetPage> routes;
  final String initialRoute;
  final JetPage? notFoundPage;
  final List<NavigatorObserver>? navigatorObservers;
  final Map<String, Map<String, String>>? translationsKeys;
  final Translations? translations;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final bool enableLog;
  final LogWriterCallback? logWriterCallback;
  final SmartManagement smartManagement;
  final List<Bind> binds;
  final ValueChanged<Routing?>? routingCallback;

  const JetMaterialApp({
    super.key,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.fallbackLocale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.scrollBehavior,
    this.builder,
    required this.routes,
    this.initialRoute = '/',
    this.notFoundPage,
    this.navigatorObservers,
    this.translationsKeys,
    this.translations,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.enableLog = kDebugMode,
    this.logWriterCallback,
    this.smartManagement = SmartManagement.full,
    this.binds = const [],
    this.routingCallback,
  });

  @override
  Widget build(BuildContext context) {
    return JetRoot(
      translations: translations,
      translationsKeys: translationsKeys,
      locale: locale,
      fallbackLocale: fallbackLocale,
      onInit: onInit,
      onReady: onReady,
      onDispose: onDispose,
      smartManagement: smartManagement,
      binds: binds,
      enableLog: enableLog,
      logWriterCallback: logWriterCallback,
      child: MaterialApp.router(
        routerConfig: JetRouterConfig(
          routes: routes,
          initialRoute: initialRoute,
          notFoundPage: notFoundPage,
          navigatorObservers: navigatorObservers,
          navigatorKey: navigatorKey,
          enableLog: enableLog,
        ),
        title: title,
        onGenerateTitle: onGenerateTitle,
        color: color,
        theme: theme,
        darkTheme: darkTheme,
        highContrastTheme: highContrastTheme,
        highContrastDarkTheme: highContrastDarkTheme,
        themeMode: themeMode,
        localizationsDelegates: localizationsDelegates,
        localeListResolutionCallback: localeListResolutionCallback,
        localeResolutionCallback: localeResolutionCallback,
        supportedLocales: supportedLocales,
        debugShowMaterialGrid: debugShowMaterialGrid,
        showPerformanceOverlay: showPerformanceOverlay,
        checkerboardRasterCacheImages: checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: checkerboardOffscreenLayers,
        showSemanticsDebugger: showSemanticsDebugger,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        shortcuts: shortcuts,
        actions: actions,
        scrollBehavior: scrollBehavior,
        scaffoldMessengerKey: scaffoldMessengerKey,
        builder: builder,
      ),
    );
  }
}
