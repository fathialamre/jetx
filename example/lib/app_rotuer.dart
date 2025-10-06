import 'package:example/pages/home_page.dart';
import 'package:example/pages/profile_page.dart';
import 'package:example/pages/settings_page.dart';
import 'package:jet/jet_navigation/jet_navigation.dart';

final routes = [
  JetPage(name: '/', page: () => const HomePage(), transition: Transition.fade),
  JetPage(
    name: '/profile',
    page: () => const ProfilePage(),
    transition: Transition.rightToLeftWithFade, // Slide from right with fade
    transitionDuration: const Duration(milliseconds: 400),
  ),
  JetPage(
    name: '/settings',
    page: () => const SettingsPage(),
    transition: Transition.zoom, // Zoom transition
    transitionDuration: const Duration(milliseconds: 350),
  ),
];
