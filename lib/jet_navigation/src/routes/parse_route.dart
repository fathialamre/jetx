import 'package:flutter/foundation.dart';

import '../../../jetx.dart';

@immutable
class RouteDecoder {
  const RouteDecoder(
    this.currentTreeBranch,
    this.pageSettings,
  );
  final List<JetPage> currentTreeBranch;
  final PageSettings? pageSettings;

  factory RouteDecoder.fromRoute(String location) {
    var uri = Uri.parse(location);
    final args = PageSettings(uri);
    final decoder =
        (Jet.rootController.rootDelegate).matchRoute(location, arguments: args);
    return decoder.replaceLast(decoder.route?.copyWith(
      completer: null,
      arguments: args,
      parameters: args.params,
    ));
  }

  JetPage? get route =>
      currentTreeBranch.isEmpty ? null : currentTreeBranch.last;

  JetPage routeOrUnknown(JetPage onUnknow) =>
      currentTreeBranch.isEmpty ? onUnknow : currentTreeBranch.last;

  /// Returns a copy of this decoder with the last entry of
  /// [currentTreeBranch] replaced by [newRoute]. If the branch is empty
  /// the new route becomes the only entry. Passing `null` returns `this`
  /// unchanged.
  ///
  /// Use this in place of mutating the previous `set route` setter; the
  /// type is `@immutable` and external mutation breaks equality + hash
  /// invariants relied on by caching and observer code.
  RouteDecoder replaceLast(JetPage? newRoute) {
    if (newRoute == null) return this;
    if (currentTreeBranch.isEmpty) {
      return RouteDecoder([newRoute], pageSettings);
    }
    final newBranch = List<JetPage>.from(currentTreeBranch);
    newBranch[newBranch.length - 1] = newRoute;
    return RouteDecoder(newBranch, pageSettings);
  }

  RouteDecoder copyWith({
    List<JetPage>? currentTreeBranch,
    PageSettings? pageSettings,
  }) =>
      RouteDecoder(
        currentTreeBranch ?? this.currentTreeBranch,
        pageSettings ?? this.pageSettings,
      );

  /// Returns a public, immutable [RouteRecord] view of the top entry on this
  /// decoder's tree branch — the snapshot exposed via `Jet.history` /
  /// `Jet.routeChanges`. Returns `null` if the branch is empty (no resolved
  /// route, e.g. an unmatched URL before fallback).
  RouteRecord? toRecord() {
    final r = route;
    if (r == null) return null;
    return RouteRecord(
      name: r.name,
      arguments: pageSettings?.arguments,
      parameters: parameters,
    );
  }

  List<JetPage>? get currentChildren => route?.children;

  Map<String, String> get parameters => pageSettings?.params ?? {};

  dynamic get args {
    return pageSettings?.arguments;
  }

  T? arguments<T>() {
    final args = pageSettings?.arguments;
    if (args is T) {
      return pageSettings?.arguments as T;
    } else {
      return null;
    }
  }

  // void replaceArguments(Object? arguments) {
  //   final newRoute = route;
  //   if (newRoute != null) {
  //     final index = currentTreeBranch.indexOf(newRoute);
  //     currentTreeBranch[index] = newRoute.copyWith(arguments: arguments);
  //   }
  // }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteDecoder &&
        listEquals(other.currentTreeBranch, currentTreeBranch) &&
        other.pageSettings == pageSettings;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(currentTreeBranch), pageSettings);

  @override
  String toString() =>
      'RouteDecoder(currentTreeBranch: $currentTreeBranch, pageSettings: $pageSettings)';
}

class ParseRouteTree {
  ParseRouteTree({
    required this.routes,
  });

  final List<JetPage> routes;

  RouteDecoder matchRoute(String name, {PageSettings? arguments}) {
    final uri = Uri.parse(name);
    final split = uri.path.split('/').where((element) => element.isNotEmpty);
    var curPath = '/';
    final cumulativePaths = <String>[
      '/',
    ];
    for (var item in split) {
      if (curPath.endsWith('/')) {
        curPath += item;
      } else {
        curPath += '/$item';
      }
      cumulativePaths.add(curPath);
    }

    final treeBranch = cumulativePaths
        .map((e) => MapEntry(e, _findRoute(e)))
        .where((element) => element.value != null)

        ///Prevent page be disposed
        .map((e) => MapEntry(e.key, e.value!.copyWith(key: ValueKey(e.key))))
        .toList();

    final params = Map<String, String>.from(uri.queryParameters);
    if (treeBranch.isNotEmpty) {
      //route is found, do further parsing to get nested query params
      final lastRoute = treeBranch.last;
      final parsedParams = _parseParams(name, lastRoute.value.path);
      if (parsedParams.isNotEmpty) {
        params.addAll(parsedParams);
      }
      //copy parameters to all pages.
      final mappedTreeBranch = treeBranch
          .map(
            (e) => e.value.copyWith(
              parameters: {
                if (e.value.parameters != null) ...e.value.parameters!,
                ...params,
              },
              name: e.key,
            ),
          )
          .toList();
      arguments?.params.clear();
      arguments?.params.addAll(params);
      return RouteDecoder(
        mappedTreeBranch,
        arguments,
      );
    }

    arguments?.params.clear();
    arguments?.params.addAll(params);

    //route not found
    return RouteDecoder(
      treeBranch.map((e) => e.value).toList(),
      arguments,
    );
  }

  void addRoutes<T>(List<JetPage<T>> getPages) {
    for (final route in getPages) {
      addRoute(route);
    }
  }

  void removeRoutes<T>(List<JetPage<T>> getPages) {
    for (final route in getPages) {
      removeRoute(route);
    }
  }

  void removeRoute<T>(JetPage<T> route) {
    routes.remove(route);
    for (var page in _flattenPage(route)) {
      removeRoute(page);
    }
  }

  void addRoute<T>(JetPage<T> route) {
    routes.add(route);

    // Add Page children.
    for (var page in _flattenPage(route)) {
      addRoute(page);
    }
  }

  List<JetPage> _flattenPage(JetPage route) {
    final result = <JetPage>[];
    if (route.children.isEmpty) {
      return result;
    }

    final parentPath = route.name;
    for (var page in route.children) {
      // Add Parent middlewares to children
      final parentMiddlewares = [
        if (page.middlewares.isNotEmpty) ...page.middlewares,
        if (route.middlewares.isNotEmpty) ...route.middlewares
      ];

      final parentBindings = [
        if (page.binding != null) page.binding!,
        if (page.bindings.isNotEmpty) ...page.bindings,
        if (route.bindings.isNotEmpty) ...route.bindings
      ];

      final parentBinds = [
        if (page.binds.isNotEmpty) ...page.binds,
        if (route.binds.isNotEmpty) ...route.binds
      ];

      result.add(
        _addChild(
          page,
          parentPath,
          parentMiddlewares,
          parentBindings,
          parentBinds,
        ),
      );

      final children = _flattenPage(page);
      for (var child in children) {
        result.add(_addChild(
          child,
          parentPath,
          [
            ...parentMiddlewares,
            if (child.middlewares.isNotEmpty) ...child.middlewares,
          ],
          [
            ...parentBindings,
            if (child.binding != null) child.binding!,
            if (child.bindings.isNotEmpty) ...child.bindings,
          ],
          [
            ...parentBinds,
            if (child.binds.isNotEmpty) ...child.binds,
          ],
        ));
      }
    }
    return result;
  }

  /// Change the Path for a [JetPage]
  JetPage _addChild(
    JetPage origin,
    String parentPath,
    List<JetMiddleware> middlewares,
    List<BindingsInterface> bindings,
    List<Bind> binds,
  ) {
    return origin.copyWith(
      middlewares: middlewares,
      name: origin.inheritParentPath
          ? (parentPath + origin.name).replaceAll(r'//', '/')
          : origin.name,
      bindings: bindings,
      binds: binds,
      // key:
    );
  }

  JetPage? _findRoute(String name) {
    final value = routes.firstWhereOrNull(
      (route) => route.path.regex.hasMatch(name),
    );

    return value;
  }

  Map<String, String> _parseParams(String path, PathDecoded routePath) {
    final params = <String, String>{};
    var idx = path.indexOf('?');
    final uri = Uri.tryParse(path);
    if (uri == null) return params;
    if (idx > -1) {
      params.addAll(uri.queryParameters);
    }
    var paramsMatch = routePath.regex.firstMatch(uri.path);
    if (paramsMatch == null) {
      return params;
    }
    for (var i = 0; i < routePath.keys.length; i++) {
      var param = Uri.decodeQueryComponent(paramsMatch[i + 1]!);
      params[routePath.keys[i]!] = param;
    }
    return params;
  }
}

extension FirstWhereOrNullExt<T> on List<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
