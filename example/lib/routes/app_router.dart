import 'package:jetx/jetx.dart';

// These imports anchor the pages so the analyzer (and the
// jetx_builder aggregator) can see every `@JetRoute`-annotated widget
// that should be picked up.
// ignore: unused_import
import '../pages/home_page.dart';
// ignore: unused_import
import '../pages/login_page.dart';
// ignore: unused_import
import '../pages/products_page.dart';

part 'app_router.g.dart';

/// Single host for the app's typed-route table. `jetx_builder` scans
/// every `@JetRoute`-annotated widget under `lib/` and generates one
/// `app_router.g.dart` containing every typed `<Page>Route` plus the
/// `_$AppRouterPages` list referenced below — no per-page `.g.dart`
/// files, no manual route registration.
@JetXRouter()
class AppRouter {
  static List<JetPage> get pages => _$AppRouterPages;
}
