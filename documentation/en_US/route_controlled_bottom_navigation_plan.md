### Route-controlled Bottom Navigation (Tabs) — Architecture and Plan

**Goal**: Provide an AutoRoute-like experience where the bottom navigation bar is controlled by the router. Each tab has its own independent navigation stack, deep linking selects the correct tab and internal route, and programmatic APIs allow switching tabs and pushing routes within the active tab without context.

### Principles
- **Single source of truth**: Route configuration defines tabs and their child routes.
- **Independent stacks**: Each tab maintains its own navigation stack (push/pop) without affecting other tabs.
- **URL sync and deep-linking**: The active tab and its sub-routes are represented in the URL.
- **Programmatic control**: Simple APIs to switch tabs and navigate within tabs via `Jet` or `BuildContext`.
- **State restoration**: Active tab and each tab's stack are restorable.

### Core Concepts
- **TabsRoute**: A route node that declares a shell with bottom navigation and multiple tab trees.
- **TabItem**: Metadata for a single tab (name, path segment, label, icon, initial flag, restoration id).
- **Per-tab Nested Routers**: A `Navigator` per tab managed by `JetNavigationStateManager`.
- **Tabs Controller**: A `JetTabsController` coordinating the active tab, URL updates, and stack preservation.

### Proposed Public API
- **Route config (DSL)**
  ```dart
  final routes = [
    TabsRoute(
      path: '/app',
      tabs: [
        TabItem(
          name: 'home',
          path: 'home',
          label: 'Home',
          icon: Icons.home,
          initial: true,
          routes: [
            JetRoute(path: '', page: HomePage()),
            JetRoute(path: 'details', page: DetailsPage()),
          ],
        ),
        TabItem(
          name: 'search',
          path: 'search',
          label: 'Search',
          icon: Icons.search,
          routes: [
            JetRoute(path: '', page: SearchPage()),
            JetRoute(path: 'filters', page: FiltersPage()),
          ],
        ),
        TabItem(
          name: 'profile',
          path: 'profile',
          label: 'Profile',
          icon: Icons.person,
          routes: [
            JetRoute(path: '', page: ProfilePage()),
            JetRoute(path: 'settings', page: SettingsPage()),
          ],
        ),
      ],
    ),
  ];
  ```

- **Shell widget**
  ```dart
  JetTabsShell(
    route: '/app', // optional: inferred from context
    navigationBarBuilder: (context, controller, tabs, currentIndex) {
      return NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: controller.switchToIndex,
        destinations: tabs
            .map((t) => NavigationDestination(
                  icon: t.icon,
                  label: t.label,
                ))
            .toList(),
      );
    },
  );
  ```

- **Programmatic control**
  ```dart
  // Select a tab by name or index
  Jet.router.switchTab(name: 'profile');
  context.router.switchTab(index: 1);

  // Navigate inside current tab
  Jet.router.pushNamed('settings'); // relative to active tab root
  context.router.pushNamed('/app/search/filters'); // absolute
  ```

- **State access**
  ```dart
  final activeTab = context.router.activeTab; // name or index
  final canPopInTab = context.router.canPopCurrentTab;
  ```

### URL Structure
- **Preferred**: `/app/<tab>(/<child>*)`
  - Examples: `/app/home`, `/app/search/filters`, `/app/profile/settings`.
  - Selecting a tab updates the URL to its root path; pushing within tab appends child path.

### Back Button and Pop Behavior
- If the active tab can pop, pop within that tab.
- If the active tab cannot pop, and there is a tab back-history, go to the previous tab.
- Otherwise, pop the shell (exit `/app`).

### Restoration
- Persist `activeTab` and each tab's back stack via `RestorationMixin` bridges in `JetTabsShell` and `JetNavigationStateManager`.
- Provide `restorationId` on `TabsRoute` and `TabItem`.

### Internal Design
- **Models**
  - `TabItem { name, path, label, icon, initial, restorationId, routes }`
  - `TabsRoute { path, tabs, restorationId }`
- **Controller**: `JetTabsController`
  - `ValueNotifier<int> index`
  - `List<GlobalKey<NavigatorState>> perTabNavigators`
  - `switchToIndex(int)` / `switchToName(String)`
  - `pushNamed(String path, {bool relativeToActiveTab = true})`
  - `canPopCurrentTab`, `popCurrentTab()`
- **State Manager**: Extend `JetNavigationStateManager`
  - `switchTab({int? index, String? name})`
  - `currentTabIndex`, `currentTabName`
  - `pushInActiveTab(...)`, `popInActiveTab()`
  - URL sync with `JetRouteInformationParser` and `JetRouterDelegate`
- **Shell**: `JetTabsShell`
  - Composes `NavigationBar`/`BottomNavigationBar` via builder
  - Hosts an `IndexedStack` of `Navigator` keyed per tab
  - Integrates with restoration and back handling

### Migration Guidance
- Replace ad-hoc bottom bars with `TabsRoute` + `JetTabsShell`.
- Move tab sub-pages under each tab's `routes` tree.
- Update deep links to `/app/<tab>/...`.

### Example
```dart
final router = JetRouterConfig(
  routes: [
    TabsRoute(
      path: '/app',
      tabs: [
        TabItem(name: 'home', path: 'home', label: 'Home', icon: Icon(Icons.home), initial: true, routes: [
          JetRoute(path: '', page: HomePage()),
          JetRoute(path: 'details', page: DetailsPage()),
        ]),
        TabItem(name: 'search', path: 'search', label: 'Search', icon: Icon(Icons.search), routes: [
          JetRoute(path: '', page: SearchPage()),
          JetRoute(path: 'filters', page: FiltersPage()),
        ]),
        TabItem(name: 'profile', path: 'profile', label: 'Profile', icon: Icon(Icons.person), routes: [
          JetRoute(path: '', page: ProfilePage()),
          JetRoute(path: 'settings', page: SettingsPage()),
        ]),
      ],
    ),
  ],
);
```

### Phased Implementation Plan
1. Add models: `TabItem`, `TabsRoute` (data-only) and exports.
2. Add `JetTabsController` with API parity and tests.
3. Extend `JetNavigationStateManager` to manage per-tab navigators and switching.
4. Implement `JetTabsShell` with `IndexedStack` and builder for the bar.
5. Wire URL parsing and delegate updates to reflect `/app/<tab>`.
6. Add restoration hooks and Android back behavior.
7. Update example app to demonstrate 3 tabs and deep links.
8. Documentation and API reference updates.

### Open Questions / Decisions
- Should we support multiple nested `TabsRoute` shells? (recommend: yes, as nested shells)
- How do we encode tab back-history in URL? (recommend: keep in memory; optional feature flag)
- Provide default `NavigationBar` vs require builder? (recommend: provide default, allow override)

### Acceptance Criteria
- Selecting a tab updates URL and shows tab root.
- Deep link `/app/profile/settings` selects Profile and shows Settings.
- Back pops inside tab if possible; otherwise switches to previous tab if available; otherwise exits shell.
- `Jet.router.switchTab(...)` and `context.router.switchTab(...)` work without context navigation pitfalls.


