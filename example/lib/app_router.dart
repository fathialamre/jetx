import 'package:example/controllers/auth_service.dart';
import 'package:example/controllers/user_controller.dart';
import 'package:example/controllers/user_service.dart';
import 'package:flutter/material.dart';
import 'package:jetx/jetx.dart';
import 'package:jetx_annotations/jetx_annotations.dart';
import 'pages/home_page.dart';
import 'pages/user_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';

part 'app_router.g.dart';

@JetRouter()
class AppRouter {
  static List<JetPage> get pages => [
    // Home page - no bindings needed
    JetPage(name: HomePageRoute.routePath, page: HomePageRoute.page),

    // User page - with manual bindings
    JetPage(
      name: UserPageRoute.routePath,
      page: UserPageRoute.page,
      binding: BindingsBuilder(() {
        Jet.put(AuthService());
        Jet.lazyPut(() => UserService(Jet.find<AuthService>()));
        Jet.lazyPut(() => UserController(Jet.find<UserService>()));
      }),
    ),

    // Profile page - with manual bindings
    JetPage(
      name: ProfilePageRoute.routePath,
      page: ProfilePageRoute.page,
      binding: BindingsBuilder(() {
        Jet.put(AuthService());
        Jet.lazyPut(() => UserService(Jet.find<AuthService>()));
        Jet.lazyPut(() => UserController(Jet.find<UserService>()));
      }),
    ),

    // Settings page - with manual bindings
    JetPage(
      name: SettingsPageRoute.routePath,
      page: SettingsPageRoute.page,
      binding: BindingsBuilder(() {
        Jet.put(AuthService());
        Jet.lazyPut(() => UserService(Jet.find<AuthService>()));
        Jet.lazyPut(() => UserController(Jet.find<UserService>()));
      }),
    ),
  ];
}
