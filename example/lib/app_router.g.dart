// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// JetXRouterGenerator
// **************************************************************************

class HomePageRoute extends NavigableRoute {
  const HomePageRoute();

  static String get routePath => '/home';

  static BindingsBuilder? get binding => null;

  static Widget Function() get page => () {
        return HomePage();
      };

  static JetPage build({
    BindingsInterface? binding,
    List<BindingsInterface>? bindings,
    List<Bind>? binds,
    Transition? transition,
    CustomTransition? customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    List<JetMiddleware>? middlewares,
    String? title,
    bool? fullscreenDialog,
    bool? maintainState,
    bool? preventDuplicates,
    bool? popGesture,
    bool? opaque,
    Curve? curve,
    Alignment? alignment,
    bool? participatesInRootNavigator,
    double Function(BuildContext)? gestureWidth,
    bool? showCupertinoParallax,
  }) {
    return JetPage(
      name: routePath,
      page: page,
      binding: binding,
      bindings: bindings ?? const [],
      binds: binds ?? const [],
      transition: transition,
      transitionDuration: transitionDuration,
      customTransition: customTransition,
      reverseTransitionDuration: reverseTransitionDuration,
      middlewares: middlewares ?? const [],
      title: title,
      fullscreenDialog: fullscreenDialog ?? false,
      maintainState: maintainState ?? true,
      preventDuplicates: preventDuplicates ?? true,
      popGesture: popGesture,
      opaque: opaque ?? true,
      curve: curve ?? Curves.linear,
      alignment: alignment,
      participatesInRootNavigator: participatesInRootNavigator,
      gestureWidth: gestureWidth,
      showCupertinoParallax: showCupertinoParallax ?? true,
    );
  }

  @override
  String get path => '/home';
}

class UserPageRoute extends NavigableRoute {
  const UserPageRoute({
    required this.userId,
    this.tab,
    required this.user,
    required this.tags,
  });

  final int userId;

  final String? tab;

  final User user;

  final List<String> tags;

  static String get routePath => '/user';

  static BindingsBuilder? get binding => null;

  static Widget Function() get page => () {
        final userId = int.parse(Jet.parameters['userId']!);
        final tab = Jet.parameters['tab'];
        final args = Jet.arguments as Map;
        final user = args['user'] as User;
        final tags = args['tags'] as List<String>;
        return UserPage(
          userId: userId,
          tab: tab,
          user: user,
          tags: tags,
        );
      };

  static JetPage build({
    BindingsInterface? binding,
    List<BindingsInterface>? bindings,
    List<Bind>? binds,
    Transition? transition,
    CustomTransition? customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    List<JetMiddleware>? middlewares,
    String? title,
    bool? fullscreenDialog,
    bool? maintainState,
    bool? preventDuplicates,
    bool? popGesture,
    bool? opaque,
    Curve? curve,
    Alignment? alignment,
    bool? participatesInRootNavigator,
    double Function(BuildContext)? gestureWidth,
    bool? showCupertinoParallax,
  }) {
    return JetPage(
      name: routePath,
      page: page,
      binding: binding,
      bindings: bindings ?? const [],
      binds: binds ?? const [],
      transition: transition,
      transitionDuration: transitionDuration,
      customTransition: customTransition,
      reverseTransitionDuration: reverseTransitionDuration,
      middlewares: middlewares ?? const [],
      title: title,
      fullscreenDialog: fullscreenDialog ?? false,
      maintainState: maintainState ?? true,
      preventDuplicates: preventDuplicates ?? true,
      popGesture: popGesture,
      opaque: opaque ?? true,
      curve: curve ?? Curves.linear,
      alignment: alignment,
      participatesInRootNavigator: participatesInRootNavigator,
      gestureWidth: gestureWidth,
      showCupertinoParallax: showCupertinoParallax ?? true,
    );
  }

  @override
  String get path {
    final queryParams = <String>[];
    queryParams.add('userId=$userId');
    if (tab != null) queryParams.add('tab=$tab');
    return queryParams.isEmpty ? '/user' : '/user?${queryParams.join('&')}';
  }

  @override
  Future<T?>? push<T>() {
    return Jet.toNamed<T>(
      path,
      arguments: {'user': user, 'tags': tags},
    );
  }

  @override
  Future<T?>? pushReplacement<T>() {
    return Jet.offNamed<T>(
      path,
      arguments: {'user': user, 'tags': tags},
    );
  }

  @override
  Future<T?>? pushAndRemoveUntil<T>(bool Function(JetPage)? predicate) {
    return Jet.offNamedUntil<T>(
      path,
      predicate,
      arguments: {'user': user, 'tags': tags},
    );
  }

  @override
  Future<T?>? pushAndRemoveAll<T>() {
    return Jet.offAllNamed<T>(
      path,
      arguments: {'user': user, 'tags': tags},
    );
  }
}

class ProfilePageRoute extends NavigableRoute {
  const ProfilePageRoute();

  static String get routePath => '/profile';

  static BindingsBuilder? get binding => null;

  static Widget Function() get page => () {
        return ProfilePage();
      };

  static JetPage build({
    BindingsInterface? binding,
    List<BindingsInterface>? bindings,
    List<Bind>? binds,
    Transition? transition,
    CustomTransition? customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    List<JetMiddleware>? middlewares,
    String? title,
    bool? fullscreenDialog,
    bool? maintainState,
    bool? preventDuplicates,
    bool? popGesture,
    bool? opaque,
    Curve? curve,
    Alignment? alignment,
    bool? participatesInRootNavigator,
    double Function(BuildContext)? gestureWidth,
    bool? showCupertinoParallax,
  }) {
    return JetPage(
      name: routePath,
      page: page,
      binding: binding,
      bindings: bindings ?? const [],
      binds: binds ?? const [],
      transition: transition,
      transitionDuration: transitionDuration,
      customTransition: customTransition,
      reverseTransitionDuration: reverseTransitionDuration,
      middlewares: middlewares ?? const [],
      title: title,
      fullscreenDialog: fullscreenDialog ?? false,
      maintainState: maintainState ?? true,
      preventDuplicates: preventDuplicates ?? true,
      popGesture: popGesture,
      opaque: opaque ?? true,
      curve: curve ?? Curves.linear,
      alignment: alignment,
      participatesInRootNavigator: participatesInRootNavigator,
      gestureWidth: gestureWidth,
      showCupertinoParallax: showCupertinoParallax ?? true,
    );
  }

  @override
  String get path => '/profile';
}

class SettingsPageRoute extends NavigableRoute {
  const SettingsPageRoute();

  static String get routePath => '/settings';

  static BindingsBuilder? get binding => null;

  static Widget Function() get page => () {
        return SettingsPage();
      };

  static JetPage build({
    BindingsInterface? binding,
    List<BindingsInterface>? bindings,
    List<Bind>? binds,
    Transition? transition,
    CustomTransition? customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    List<JetMiddleware>? middlewares,
    String? title,
    bool? fullscreenDialog,
    bool? maintainState,
    bool? preventDuplicates,
    bool? popGesture,
    bool? opaque,
    Curve? curve,
    Alignment? alignment,
    bool? participatesInRootNavigator,
    double Function(BuildContext)? gestureWidth,
    bool? showCupertinoParallax,
  }) {
    return JetPage(
      name: routePath,
      page: page,
      binding: binding,
      bindings: bindings ?? const [],
      binds: binds ?? const [],
      transition: transition,
      transitionDuration: transitionDuration,
      customTransition: customTransition,
      reverseTransitionDuration: reverseTransitionDuration,
      middlewares: middlewares ?? const [],
      title: title,
      fullscreenDialog: fullscreenDialog ?? false,
      maintainState: maintainState ?? true,
      preventDuplicates: preventDuplicates ?? true,
      popGesture: popGesture,
      opaque: opaque ?? true,
      curve: curve ?? Curves.linear,
      alignment: alignment,
      participatesInRootNavigator: participatesInRootNavigator,
      gestureWidth: gestureWidth,
      showCupertinoParallax: showCupertinoParallax ?? true,
    );
  }

  @override
  String get path => '/settings';
}
