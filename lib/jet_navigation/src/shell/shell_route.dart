import 'package:flutter/material.dart';

import '../../../jetx.dart';

/// One independent navigation stack inside a [JetStatefulShellRoute].
///
/// Each branch owns its own [JetDelegate]: pushes inside branch A do not
/// touch branch B's history, and switching tabs preserves both
/// branches' state because the underlying widget subtrees stay alive
/// (via [IndexedStack]).
@immutable
class JetShellBranch {
  /// Stable identifier used to address this branch's delegate from
  /// imperative APIs:
  ///
  /// ```dart
  /// Jet.toNamed('/details', id: 'home');
  /// ```
  ///
  /// Must be unique within a single [JetStatefulShellRoute].
  final String name;

  /// The pages registered against this branch's [JetDelegate]. The first
  /// entry is the branch root.
  final List<JetPage> pages;

  /// Restoration scope id forwarded to the underlying [Router] so the
  /// branch's history can survive process death when the host app sets
  /// up `restorationScopeId`.
  final String? restorationScopeId;

  const JetShellBranch({
    required this.name,
    required this.pages,
    this.restorationScopeId,
  });
}

/// Shell widget hosting N independent navigation stacks (branches).
///
/// Models the bottom-navigation pattern where every tab keeps its own
/// scroll position, in-progress form input, and nested navigation
/// history when the user switches tabs and returns.
///
/// Usage:
/// ```dart
/// JetStatefulShellRoute(
///   branches: [
///     JetShellBranch(name: 'home', pages: [JetPage(name: '/', page: () => HomeTab())]),
///     JetShellBranch(name: 'feed', pages: [JetPage(name: '/', page: () => FeedTab())]),
///   ],
///   builder: (context, currentIndex, goBranch, body) => Scaffold(
///     body: body,
///     bottomNavigationBar: NavigationBar(
///       selectedIndex: currentIndex,
///       onDestinationSelected: goBranch,
///       destinations: const [
///         NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
///         NavigationDestination(icon: Icon(Icons.feed), label: 'Feed'),
///       ],
///     ),
///   ),
/// );
/// ```
///
/// Within a tab, navigate via the standard `Jet.*` API plus the `id:`
/// argument: `Jet.toNamed('/details', id: 'home')` pushes onto the
/// `home` branch's stack.
///
/// Tapping the currently-active tab pops that branch back to its root.
class JetStatefulShellRoute extends StatefulWidget {
  final List<JetShellBranch> branches;

  /// Renders the shell chrome (bottom nav, drawer, ...) around the
  /// active branch's [body]. Called every rebuild with the current
  /// branch index and a `goBranch(int)` callback for tab switching.
  final Widget Function(
    BuildContext context,
    int currentIndex,
    void Function(int) goBranch,
    Widget body,
  ) builder;

  /// Branch shown on first build.
  final int initialIndex;

  const JetStatefulShellRoute({
    super.key,
    required this.branches,
    required this.builder,
    this.initialIndex = 0,
  })  : assert(branches.length > 0, 'JetStatefulShellRoute needs >=1 branch'),
        assert(initialIndex >= 0 && initialIndex < branches.length,
            'initialIndex out of range');

  @override
  State<JetStatefulShellRoute> createState() => _JetStatefulShellRouteState();
}

class _JetStatefulShellRouteState extends State<JetStatefulShellRoute> {
  late int _currentIndex;
  late List<JetDelegate> _delegates;
  late List<JetInformationParser> _parsers;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _delegates = <JetDelegate>[];
    _parsers = <JetInformationParser>[];
    for (final branch in widget.branches) {
      // Register under the rootController's `keys` map so callers can
      // address the branch via `Jet.toNamed('/x', id: branch.name)`.
      final delegate = JetDelegate(pages: branch.pages);
      // Seed the branch with its first page; otherwise the Router below
      // would render nothing until a navigation happens (the parser-driven
      // initial route lookup races the first build).
      if (branch.pages.isNotEmpty) {
        delegate.toNamed(branch.pages.first.name);
      }
      Jet.rootController.keys[branch.name] = delegate;
      _delegates.add(delegate);
      final parser = JetInformationParser(
        initialRoute: branch.pages.isEmpty ? '/' : branch.pages.first.name,
      );
      _parsers.add(parser);
    }
  }

  @override
  void dispose() {
    for (final branch in widget.branches) {
      Jet.rootController.keys.remove(branch.name);
    }
    super.dispose();
  }

  void _goBranch(int index) {
    assert(index >= 0 && index < widget.branches.length);
    if (index == _currentIndex) {
      // Re-tapping the active tab pops to the branch root.
      final delegate = _delegates[index];
      while (delegate.activePages.length > 1) {
        delegate.back();
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _currentIndex,
      children: List.generate(widget.branches.length, (i) {
        final branch = widget.branches[i];
        return Router(
          restorationScopeId: branch.restorationScopeId,
          routerDelegate: _delegates[i],
          routeInformationParser: _parsers[i],
          backButtonDispatcher: ChildBackButtonDispatcher(
            Router.of(context).backButtonDispatcher!,
          ),
        );
      }),
    );
    return widget.builder(context, _currentIndex, _goBranch, body);
  }
}
