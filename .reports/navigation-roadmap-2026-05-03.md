# JetX Navigation Roadmap

**Date:** 2026-05-03
**Branch baseline:** `master @ 7d33c036`
**Scope:** Routing/navigation subsystem (`lib/jet_navigation/`)
**Source:** Audit conducted post-`onPopPage → onDidRemovePage` migration.

---

## Goals

1. Eliminate correctness bugs in the existing imperative API surface.
2. Close ergonomics gaps that today force users to reach into private internals or write boilerplate.
3. Reach feature parity with `go_router` on the patterns Flutter teams actually need (multi-stack, typed routes, redirects, error boundaries, predictive back).
4. Stay imperative-first — JetX's value prop is `Jet.toNamed()` without `BuildContext`, not declarative-only routing. New features must coexist with `Jet.*` calls.

---

## Phasing

| Phase | Theme | Effort | Risk | Outcome |
|------|-------|--------|------|---------|
| 0 | Bug fixes | ~0.5 day | low | Stack consistency under all pop paths |
| 1 | Ergonomics + observability | ~2 days | low | Public stack/history API, config classes, redirect listenable, error boundaries, route stream |
| 2 | Multi-stack + typed routes | ~5 days | med | StatefulShell equivalent, codegen package skeleton, hero coordination |
| 3 | Polish | ~3 days | low | Per-direction curves, predictive back, route timeouts, restoration story |
| 4 | Companion `jetx_builder` package | ~3 days | low | Type-safe routes via build_runner |

Phases run in order. Each ships as its own PR/commit so `master` stays releasable. Phase boundaries are checkpoint review points.

---

## Phase 0 — Critical bug fixes

Fix the four HIGH findings from the audit before adding any features.

### 0.1 `offNamedUntil` / `offUntil` skip middleware + skip notify
- **Files:** `lib/jet_navigation/src/routes/jet_router_delegate.dart:540-558` (`offNamedUntil`), `:594-604` (`offUntil`)
- **Bug:** Loop calls `_activePages.removeLast()` directly. Bypasses `runMiddleware`, no `notifyListeners`.
- **Fix:** Replace inner `_activePages.removeLast()` with `_popAndNotifyDispose()` (already exists at `:527`). After loop, run middleware before pushing target.
- **Test:** add cases to `test/navigation/jet_main_test.dart` — assert middleware fires on intermediate pops, assert visual stack rebuilds.

### 0.2 `_push` race on concurrent navigations
- **File:** `jet_router_delegate.dart:752-792`
- **Bug:** `await runMiddleware()` then mutate `_activePages`. Two `Jet.toNamed()` calls in flight can interleave the mutation.
- **Fix:** serialize via a `Future<void>? _navigating` chain — each `_push` `await`s the prior one before mutating. Same pattern used by Flutter's own `_NavigatorObservation` queue.
- **Test:** new `test/navigation/concurrent_navigation_test.dart` — fire two `Jet.toNamed` in same microtask, assert final stack order.

### 0.3 Completer leak on middleware-cancelled navigation
- **File:** `jet_router_delegate.dart:733-749` (`_configureRouterDecoder`)
- **Bug:** `Completer<T?>()` allocated unconditionally. If `runMiddleware` returns null (cancel), the completer is dropped, never completed → awaiters hang forever.
- **Fix:** in `_push`, when `runMiddleware` returns null, complete `decoder.route?.completer` with `null` before returning.
- **Test:** middleware that returns `null`, await `Jet.toNamed(...)`, assert resolves to `null` within timeout.

### 0.4 `RouteDecoder` mutable despite `@immutable`
- **File:** `lib/jet_navigation/src/routes/parse_route.dart:5-40`
- **Bug:** Class wears `@immutable`, but `set route(...)` mutates `currentTreeBranch[last]`. Hash + equality break, hidden state-sharing.
- **Fix:** drop `@immutable`, OR — preferred — make `RouteDecoder` truly immutable via `copyWith` and remove the setter. Update callers in `jet_router_delegate.dart` (search for `.route =`).
- **Test:** unit test in `test/navigation/route_decoder_test.dart` — two decoders with same content compare equal; setter no longer exists.

**Phase 0 deliverable:** one PR, ~250 lines net change, all existing tests green + four new tests.

---

## Phase 1 — Ergonomics + observability

### 1.1 Public route history API
- **New API:** `Jet.history` → `List<RouteRecord>` (immutable snapshot). `RouteRecord = ({String name, Object? arguments, Map<String, String> parameters})`.
- **Stream:** `Jet.routeChanges` → `Stream<RouteRecord>` (broadcast). Emits on every push/pop/replace.
- **Files:** new `lib/jet_navigation/src/routes/route_record.dart`. Wire from `JetDelegate.notifyListeners` override.
- **Use cases:** breadcrumbs, analytics, sync external state.
- **Effort:** S.

### 1.2 Snackbar / Dialog / BottomSheet config classes
- **Problem:** `Jet.snackbar(...)` has 40+ named params (`extension_navigation.dart:414`).
- **New API:** `JetSnackbarConfig`, `JetDialogConfig`, `JetBottomSheetConfig` value classes with named params + `copyWith`. Existing `Jet.snackbar(title, message)` keeps shorthand. New form: `Jet.showSnackbar(JetSnackbarConfig(title: ..., ...))`.
- **Files:** new `lib/jet_navigation/src/snackbar/snackbar_config.dart` + same for dialog/bottomsheet. Refactor extension methods to delegate to config-based core.
- **Backwards compatible.** Old method signatures stay.
- **Effort:** S.

### 1.3 Global redirect + `refreshListenable`
- **New API on `JetMaterialApp`:** `redirect: Future<String?> Function(BuildContext, RouteRecord)?`, `refreshListenable: Listenable?`.
- **Behavior:** before every `_push`, run global redirect; if non-null, push that target instead. `refreshListenable.addListener` re-evaluates current route's redirect.
- **Use case:** auth — listener on `authState`, redirect to `/login` if unauth.
- **Files:** add fields to `ConfigData` (`lib/jet_navigation/src/root/jet_root.dart`), wire in `JetDelegate._push`.
- **Effort:** S/M.

### 1.4 Per-route `errorBuilder` + global `onException`
- **New on `JetPage`:** `errorBuilder: Widget Function(BuildContext, Object error, StackTrace)?`. New on `JetMaterialApp`: `onException: void Function(Object, StackTrace)?`.
- **Behavior:** wrap each page builder in a try/catch. On throw → call route's `errorBuilder` if set, else global error page; always call `onException` for logging.
- **Files:** `jet_route.dart` (add field + copyWith), `jet_router_delegate.dart` build path (wrap in `_SafePage` widget).
- **Effort:** S/M.

### 1.5 Promote `closeAllOverlays` + add `Jet.dismissUntilPage()`
- **Already exists:** `Jet.closeAllOverlays()` at `extension_navigation.dart:935`. Just needs README mention.
- **New helper:** `Jet.dismissUntilPage()` — pops every overlay (snackbar/dialog/bottomsheet) without touching the page stack. Common need before showing a fresh dialog.
- **Effort:** S.

### 1.6 Test bottomSheet end-to-end
- **Gap:** `test/navigation/` has zero `Jet.bottomSheet` tests.
- **Add:** `test/navigation/bottomsheet_full_test.dart` — open/close, drag-dismiss, barrier-tap-dismiss, returns value via completer.
- **Effort:** S.

**Phase 1 deliverable:** PR per item or one bundled PR. Net add ~600 LOC.

---

## Phase 2 — Multi-stack + typed routes + hero

### 2.1 `JetShellRoute` + `JetStatefulShellRoute`
- **Goal:** match `go_router.StatefulShellRoute.indexedStack` — bottom-nav with N parallel stacks, each maintaining its own history + state.
- **Design:**
  - New `JetShellRoute extends JetPage` — wraps children in a builder that owns a sub-`JetDelegate`.
  - New `JetStatefulShellRoute` — owns `List<JetShellBranch>`, each branch has its own `JetDelegate` instance + `restorationScopeId`.
  - `IndexedStack` keeps off-screen branches alive. Branch switch = `delegate.notifyListeners`.
  - Public `JetShellNavigator.of(context).goBranch(int index)` API.
- **Files:** new `lib/jet_navigation/src/shell/` directory: `shell_route.dart`, `stateful_shell_route.dart`, `shell_navigator.dart`.
- **Tests:** `test/navigation/shell_route_test.dart` — switch branches preserves nested stack, scroll, form state.
- **Effort:** L.

### 2.2 Hero coordination across declarative pages
- **Gap:** `JetNavigator` includes `HeroController()` (`jet_navigator.dart:16`), but the declarative Pages API doesn't always re-bind Hero tags on rebuild. Custom transitions break Hero shuttle.
- **Fix:** ensure `HeroController` is shared across all `JetNavigator` instances within a session; expose `JetMaterialApp.heroFlightShuttle`.
- **Tests:** widget test — push page with `Hero(tag: 'x')`, assert flight animates from origin position.
- **Effort:** M.

### 2.3 Codegen-ready route classes (manual API, codegen later in Phase 4)
- **New base class:** `abstract class JetRouteData { String get location; List<JetPage> get pages; }`.
- **User writes:**
  ```dart
  class UserRoute extends JetRouteData {
    UserRoute({required this.id});
    final int id;
    @override String get location => '/user/$id';
    @override List<JetPage> get pages => [JetPage(name: '/user/:id', page: () => UserScreen())];
  }
  ```
- **Then:** `Jet.go(UserRoute(id: 123))` → resolves location, pushes typed.
- **Phase 4:** `@JetRoute` annotation auto-generates these classes via `build_runner`.
- **Files:** new `lib/jet_navigation/src/typed/jet_route_data.dart`, `Jet.go<T extends JetRouteData>(T)` method.
- **Effort:** M.

### 2.4 PredictiveBackPageTransitionsBuilder integration
- **Goal:** Android 14+ predictive back gesture shows preview of previous page during swipe.
- **Approach:** add `Transition.predictiveBack` enum value; mapping uses `PredictiveBackPageTransitionsBuilder`. Default for Android targets only via `Theme.platform`.
- **Files:** extend `transitions_type.dart`, add case in `default_transitions.dart`.
- **Effort:** M.

### 2.5 Programmatic URL building
- **Hand-rolled:** `JetRouteData.location` already provides this for typed routes (2.3).
- **For untyped:** add `Jet.buildUrl(String path, {Map<String, dynamic> pathParams, Map<String, dynamic> queryParams})` — handles encoding + `:param` substitution + `?` join.
- **Effort:** S.

**Phase 2 deliverable:** 2–3 PRs (shell route alone is its own PR). Net add ~1500 LOC + tests.

---

## Phase 3 — Polish

### 3.1 Per-direction transition curves
- **Add to `JetPage`:** `reverseCurve: Curve?` (forward curve already exists at `jet_route.dart:19`).
- **Wire:** `jet_transition_mixin.dart` uses `reverseCurve` when `isReverse`.
- **Effort:** S.

### 3.2 Per-route timeout + `onTimeout` builder
- **Add to `JetPage`:** `pageTimeout: Duration?`, `onTimeout: Widget Function(BuildContext)?`.
- **Behavior:** if a `FutureBuilder`-based async page hangs past timeout, swap to `onTimeout` widget. Useful for data-loading pages.
- **Effort:** M.

### 3.3 End-to-end state restoration audit
- **Today:** `restorationScopeId` is plumbed but no integration test proves it works after process death.
- **Plan:** add `RestorationBucket` integration test in `test/navigation/restoration_test.dart`. Document gaps in `documentation/en_US/restoration.md`.
- **Effort:** M.

### 3.4 Curve customization per (from, to) page pair
- **Optional:** advanced. Add `JetMaterialApp.transitionResolver: Transition Function(JetPage from, JetPage to)?`. Lets app tune transitions per route pair without per-route config bloat.
- **Effort:** S.

**Phase 3 deliverable:** 1 PR.

---

## Phase 4 — `jetx_builder` companion package

### 4.1 Package skeleton
- **New repo / package:** `packages/jetx_builder/` (in mono-repo) or separate package.
- **Annotations:** `@JetRoute(path: '/user/:id')`, `@JetShellRoute(...)`. Class fields = path/query params (typed: `int id`, `String? tab`).
- **Generator:** uses `source_gen` + `build_runner`. Emits `*.g.dart` with concrete `JetRouteData` classes from Phase 2.3.
- **Files:** `packages/jetx_builder/lib/builder.dart`, `packages/jetx_builder/lib/src/jet_route_generator.dart`.
- **Effort:** L.

### 4.2 README + example app demo
- **Files:** update root `README.md` with codegen quickstart, update `example/` with one `@JetRoute`-annotated page.
- **Effort:** S.

**Phase 4 deliverable:** new package + docs.

---

## Cross-cutting work

### Code cleanup (do during Phase 0–1)
- Remove dead commented blocks: `jet_router_delegate.dart:75, 153-157, 393-396`; `parse_route.dart:59-65`.
- Drop hand-rolled `firstWhereOrNull` (`parse_route.dart:287`); use `package:collection`.
- Tighten `dynamic arguments, dynamic id` → `Object?` everywhere in `jet_router_delegate.dart`.
- `Routing` class (`route_observer.dart:175`) → switch to immutable `copyWith`. Listed as MED in audit; cosmetic but kills a class of bugs.

### Test coverage backfill (Phase 0–1)
- `Jet.bottomSheet` (zero tests today).
- `Jet.backAndtoNamed`, `Jet.removeRoute`, `Jet.popHistory` (zero coverage).
- Middleware exception handling (`route_middleware.dart:114` swallows silently).
- `offUntil` on single-route stack.

### Docs (Phase 1+)
- `documentation/en_US/navigation.md` — current public API reference. Today `documentation/` only has translated READMEs.
- New `migration_to_jetx.md` — for users coming from GetX 4.x. Catalogs renamed APIs + behavior diffs.

---

## Verification per phase

| Phase | Verification |
|-------|--------------|
| 0 | All existing 223 tests + 4 new bug-regression tests; `flutter analyze` clean. |
| 1 | + 6+ new tests for new APIs; example app demonstrates each new API. |
| 2 | + shell route widget tests with state-preservation assertions; predictive-back manual test on Android 14 emulator. |
| 3 | + restoration test with `RestorationBucket`; reverse-curve visual diff test. |
| 4 | + golden file for generated `*.g.dart`; CI runs `build_runner build` on example. |

---

## Public API breakage

- **Phase 0–1:** zero breaks.
- **Phase 2:** `JetPage` gets new optional fields → non-breaking. `Jet.go()` is additive.
- **Phase 3:** `Transition` enum gets new value (additive); `JetPage.reverseCurve` optional.
- **Phase 4:** annotations are opt-in.

Project is `1.0.0-dev.1` — minor breakages acceptable, but the plan above stays additive throughout.

---

## Out of scope (explicitly)

- Replacing core with `go_router` (defeats JetX's no-`BuildContext` value prop).
- Removing imperative `Jet.toNamed` etc. (would break every consumer).
- Rewriting overlay/snackbar machinery (works fine; only ergonomic shell needs update).
- Renaming any public symbol (`JetX` is now stable).

---

## Questions to answer before starting

1. Mono-repo for `jetx_builder` or separate package? (Affects Phase 4 layout.)
2. Drop or keep deprecated `Bindings extends BindingsInterface<void>`?
3. Should `Jet.routeChanges` stream replay last value to late subscribers (BehaviorSubject-style) or be pure broadcast?
4. Predictive back: Android-only feature gate via `Theme.of(context).platform`, or expose unconditionally?
