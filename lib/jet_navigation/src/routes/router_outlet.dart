import 'package:flutter/material.dart';

import '../../../jet.dart';

class RouterOutlet<TDelegate extends RouterDelegate<T>, T extends Object>
    extends StatefulWidget {
  final TDelegate routerDelegate;
  final Widget Function(BuildContext context) builder;

  RouterOutlet.builder({
    super.key,
    TDelegate? delegate,
    required this.builder,
  }) : routerDelegate = delegate ?? Jet.delegate<TDelegate, T>()!;

  RouterOutlet({
    Key? key,
    TDelegate? delegate,
    required Iterable<JetPage> Function(T currentNavStack) pickPages,
    required Widget Function(
      BuildContext context,
      TDelegate,
      Iterable<JetPage>? page,
    ) pageBuilder,
  }) : this.builder(
            builder: (context) {
              final currentConfig = context.delegate.currentConfiguration as T?;
              final rDelegate = context.delegate as TDelegate;
              var picked =
                  currentConfig == null ? null : pickPages(currentConfig);
              if (picked?.isEmpty ?? true) {
                picked = null;
              }
              return pageBuilder(context, rDelegate, picked);
            },
            delegate: delegate,
            key: key);
  @override
  RouterOutletState<TDelegate, T> createState() =>
      RouterOutletState<TDelegate, T>();
}

class RouterOutletState<TDelegate extends RouterDelegate<T>, T extends Object>
    extends State<RouterOutlet<TDelegate, T>> {
  RouterDelegate? delegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  void _listener() {
    setState(() {});
  }

  VoidCallback? disposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    disposer?.call();
    final router = Router.of(context);
    delegate ??= router.routerDelegate;
    delegate?.addListener(_listener);
    disposer = () => delegate?.removeListener(_listener);

    _backButtonDispatcher =
        router.backButtonDispatcher!.createChildBackButtonDispatcher();
  }

  @override
  void dispose() {
    super.dispose();
    disposer?.call();
  }

  @override
  Widget build(BuildContext context) {
    _backButtonDispatcher.takePriority();
    return widget.builder(context);
  }
}

class JetRouterOutlet extends RouterOutlet<JetDelegate, RouteDecoder> {
  JetRouterOutlet({
    Key? key,
    String? anchorRoute,
    required String initialRoute,
    Iterable<JetPage> Function(Iterable<JetPage> afterAnchor)? filterPages,
    JetDelegate? delegate,
    String? restorationScopeId,
  }) : this.pickPages(
          restorationScopeId: restorationScopeId,
          pickPages: (config) {
            Iterable<JetPage<dynamic>> ret;
            if (anchorRoute == null) {
              // jump the ancestor path
              final length = Uri.parse(initialRoute).pathSegments.length;

              return config.currentTreeBranch
                  .skip(length)
                  .take(length)
                  .toList();
            }
            ret = config.currentTreeBranch.pickAfterRoute(anchorRoute);
            if (filterPages != null) {
              ret = filterPages(ret);
            }
            return ret;
          },
          key: key,
          emptyPage: (delegate) =>
              delegate.matchRoute(initialRoute).route ?? delegate.notFoundRoute,
          navigatorKey: Jet.nestedKey(anchorRoute)?.navigatorKey,
          delegate: delegate,
        );
  JetRouterOutlet.pickPages({
    super.key,
    Widget Function(JetDelegate delegate)? emptyWidget,
    JetPage Function(JetDelegate delegate)? emptyPage,
    required super.pickPages,
    bool Function(Route<dynamic>, dynamic)? onPopPage,
    String? restorationScopeId,
    GlobalKey<NavigatorState>? navigatorKey,
    JetDelegate? delegate,
  }) : super(
          pageBuilder: (context, rDelegate, pages) {
            final pageRes = <JetPage?>[
              ...?pages,
              if (pages == null || pages.isEmpty) emptyPage?.call(rDelegate),
            ].whereType<JetPage>();

            if (pageRes.isNotEmpty) {
              return InheritedNavigator(
                navigatorKey: navigatorKey ??
                    Jet.rootController.rootDelegate.navigatorKey,
                child: JetNavigator(
                  restorationScopeId: restorationScopeId,
                  onPopPage: onPopPage ??
                      (route, result) {
                        final didPop = route.didPop(result);
                        if (!didPop) {
                          return false;
                        }
                        return true;
                      },
                  pages: pageRes.toList(),
                  key: navigatorKey,
                ),
              );
            }
            return (emptyWidget?.call(rDelegate) ?? const SizedBox.shrink());
          },
          delegate: delegate ?? Jet.rootController.rootDelegate,
        );

  JetRouterOutlet.builder({
    super.key,
    required super.builder,
    String? route,
    JetDelegate? routerDelegate,
  }) : super.builder(
          delegate: routerDelegate ??
              (route != null
                  ? Jet.nestedKey(route)
                  : Jet.rootController.rootDelegate),
        );
}

class InheritedNavigator extends InheritedWidget {
  const InheritedNavigator({
    super.key,
    required super.child,
    required this.navigatorKey,
  });
  final GlobalKey<NavigatorState> navigatorKey;

  static InheritedNavigator? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedNavigator>();
  }

  @override
  bool updateShouldNotify(InheritedNavigator oldWidget) {
    return true;
  }
}

extension NavKeyExt on BuildContext {
  GlobalKey<NavigatorState>? get parentNavigatorKey {
    return InheritedNavigator.of(this)?.navigatorKey;
  }
}

extension PagesListExt on List<JetPage> {
  /// Returns the route and all following routes after the given route.
  Iterable<JetPage> pickFromRoute(String route) {
    return skipWhile((value) => value.name != route);
  }

  /// Returns the routes after the given route.
  Iterable<JetPage> pickAfterRoute(String route) {
    // If the provided route is root, we take the first route after root.
    if (route == '/') {
      return pickFromRoute(route).skip(1).take(1);
    }
    // Otherwise, we skip the route and take all routes after it.
    return pickFromRoute(route).skip(1);
  }
}

typedef NavigatorItemBuilderBuilder = Widget Function(
    BuildContext context, List<String> routes, int index);

class IndexedRouteBuilder<T> extends StatelessWidget {
  const IndexedRouteBuilder({
    super.key,
    required this.builder,
    required this.routes,
  });
  final List<String> routes;
  final NavigatorItemBuilderBuilder builder;

// Method to get the current index based on the route
  int _getCurrentIndex(String currentLocation) {
    for (int i = 0; i < routes.length; i++) {
      if (currentLocation.startsWith(routes[i])) {
        return i;
      }
    }
    return 0; // default index
  }

  @override
  Widget build(BuildContext context) {
    final location = context.location;
    final index = _getCurrentIndex(location);

    return builder(context, routes, index);
  }
}

mixin RouterListenerMixin<T extends StatefulWidget> on State<T> {
  RouterDelegate? delegate;

  void _listener() {
    setState(() {});
  }

  VoidCallback? disposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    disposer?.call();
    final router = Router.of(context);
    delegate ??= router.routerDelegate as JetDelegate;

    delegate?.addListener(_listener);
    disposer = () => delegate?.removeListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    disposer?.call();
  }
}

class RouterListenerInherited extends InheritedWidget {
  const RouterListenerInherited({
    super.key,
    required super.child,
  });

  static RouterListenerInherited? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RouterListenerInherited>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class RouterListener extends StatefulWidget {
  const RouterListener({
    super.key,
    required this.builder,
  });
  final WidgetBuilder builder;

  @override
  State<RouterListener> createState() => RouteListenerState();
}

class RouteListenerState extends State<RouterListener>
    with RouterListenerMixin {
  @override
  Widget build(BuildContext context) {
    return RouterListenerInherited(child: Builder(builder: widget.builder));
  }
}

class BackButtonCallback extends StatefulWidget {
  const BackButtonCallback({super.key, required this.builder});
  final WidgetBuilder builder;

  @override
  State<BackButtonCallback> createState() => RouterListenerState();
}

class RouterListenerState extends State<BackButtonCallback>
    with RouterListenerMixin {
  late ChildBackButtonDispatcher backButtonDispatcher;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = Router.of(context);
    backButtonDispatcher =
        router.backButtonDispatcher!.createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    backButtonDispatcher.takePriority();
    return widget.builder(context);
  }
}
