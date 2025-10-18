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
    HomePageRoute.build(),
    UserPageRoute.build(),
    ProfilePageRoute.build(),
    SettingsPageRoute.build(),
  ];
}
