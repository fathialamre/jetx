/// Navigator 2.0 implementation for JetX
///
/// This is a pure, declarative Navigator 2.0 implementation with state-driven
/// navigation, deep linking, nested navigation, and custom transitions.
///
/// ## Features
/// - ✅ Declarative, state-driven navigation
/// - ✅ Deep linking with path and query parameters
/// - ✅ Nested navigation support
/// - ✅ State restoration
/// - ✅ Browser history integration (web)
/// - ✅ Custom transitions with 15+ built-in animations
/// - ✅ Type-safe navigation with arguments
/// - ✅ Route observers and lifecycle management
///
/// ## Getting Started
///
/// ### Basic Usage
/// ```dart
/// JetMaterialApp(
///   routes: [
///     JetPage(
///       name: '/',
///       page: () => HomePage(),
///       transition: Transition.fade,
///     ),
///     JetPage(
///       name: '/profile',
///       page: () => ProfilePage(),
///       transition: Transition.rightToLeftWithFade,
///     ),
///   ],
///   initialRoute: '/',
/// )
/// ```
///
/// ### Navigation
/// ```dart
/// // Push with arguments
/// context.nav.pushNamed('/profile', arguments: {'id': 123});
///
/// // Go back
/// context.nav.pop();
///
/// // Replace
/// context.nav.replaceNamed('/home');
///
/// // Clear stack
/// context.nav.offAll('/');
/// ```
///
/// ### Access Route Data
/// ```dart
/// final arguments = context.nav.state.currentPage?.arguments;
/// final parameters = context.nav.state.currentPage?.parameters;
/// ```
library;

// Core navigation state
export 'jet_navigation_state.dart';
export 'jet_navigation_state_manager.dart';

// Router components (Navigator 2.0)
export 'jet_router_delegate.dart';
export 'jet_route_information_parser.dart';
export 'jet_router_config.dart';

// Nested navigation
export 'jet_nested_router.dart';

// State restoration
export 'jet_navigation_restoration.dart';

// Context extension (context.nav API)
export 'context_router_extension.dart';

// Pages (route definitions, parsing, lifecycle)
export 'pages/index.dart';

// Transitions (animations and effects)
export 'transitions/index.dart';

// Observers (route lifecycle)
export 'observers/index.dart';

// Tabs (bottom navigation)
export 'tabs/index.dart';
