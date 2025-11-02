import 'package:example/pages/computed_example_page.dart';
import 'package:jetx/jet.dart';
import 'package:jetx_annotations/jetx_annotations.dart';

// Import all page files so generated code can reference them
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';

part 'router.g.dart';

@JetRouteConfig(generateForDir: ['lib'])
class AppRouter {
  static List<JetPage> get pages => [
    JetPage(name: HomePageRoute.path, page: () => HomePageRoute.page()),
    JetPage(name: ProfilePageRoute.path, page: () => ProfilePageRoute.page()),
    JetPage(name: SettingsPageRoute.path, page: () => SettingsPageRoute.page()),
    JetPage(
      name: ComputedExamplePageRoute.path,
      binds: [
        Bind.lazyPut(() => ProductController()),
      ],
      page: () => ComputedExamplePageRoute.page(),
    ),
  ];
}
