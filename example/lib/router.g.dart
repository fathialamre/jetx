// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JetX Route Generator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// Route class for [HomePage].
class HomePageRoute {
  HomePageRoute._();

  /// Route path: '/home'
  static const String path = '/home';

  /// Creates an instance of [HomePage].
  static HomePage page() {
    return HomePage();
  }

  /// Pushes [HomePage] onto the navigation stack.
  static Future<T?>? push<T>() {
    return Jet.toNamed<T>(
      path,
    );
  }

  /// Replaces the current route with [HomePage].
  static Future<T?>? off<T>() {
    return Jet.offNamed<T>(
      path,
    );
  }

  /// Removes all routes and pushes [HomePage].
  static Future<T?>? offAll<T>() {
    return Jet.offAllNamed<T>(
      path,
    );
  }
}

/// Route class for [ProfilePage].
class ProfilePageRoute {
  ProfilePageRoute._();

  /// Route path: '/profile'
  static const String path = '/profile';

  /// Creates an instance of [ProfilePage].
  static ProfilePage page() {
    final userIdValue = Jet.parameters['userId']!;
    final nameValue = Jet.parameters['name'];
    final args = Jet.arguments;
    return ProfilePage(
      userId: userIdValue,
      profile: args as Profile,
      name: nameValue,
    );
  }

  static Map<String, String> _buildParameters({
    required String userId,
    String? name,
  }) {
    return {
      'userId': userId,
      if (name != null) 'name': name,
    };
  }

  static dynamic _buildArguments({
    required Profile profile,
  }) {
    return profile;
  }

  /// Pushes [ProfilePage] onto the navigation stack.
  static Future<T?>? push<T>({
    required String userId,
    required Profile profile,
    String? name,
  }) {
    return Jet.toNamed<T>(
      path,
      parameters: _buildParameters(userId: userId, name: name),
      arguments: _buildArguments(profile: profile),
    );
  }

  /// Replaces the current route with [ProfilePage].
  static Future<T?>? off<T>({
    required String userId,
    required Profile profile,
    String? name,
  }) {
    return Jet.offNamed<T>(
      path,
      parameters: _buildParameters(userId: userId, name: name),
      arguments: _buildArguments(profile: profile),
    );
  }

  /// Removes all routes and pushes [ProfilePage].
  static Future<T?>? offAll<T>({
    required String userId,
    required Profile profile,
    String? name,
  }) {
    return Jet.offAllNamed<T>(
      path,
      parameters: _buildParameters(userId: userId, name: name),
      arguments: _buildArguments(profile: profile),
    );
  }
}

/// Route class for [SettingsPage].
class SettingsPageRoute {
  SettingsPageRoute._();

  /// Route path: '/settings'
  static const String path = '/settings';

  /// Creates an instance of [SettingsPage].
  static SettingsPage page() {
    return SettingsPage();
  }

  /// Pushes [SettingsPage] onto the navigation stack.
  static Future<T?>? push<T>() {
    return Jet.toNamed<T>(
      path,
    );
  }

  /// Replaces the current route with [SettingsPage].
  static Future<T?>? off<T>() {
    return Jet.offNamed<T>(
      path,
    );
  }

  /// Removes all routes and pushes [SettingsPage].
  static Future<T?>? offAll<T>() {
    return Jet.offAllNamed<T>(
      path,
    );
  }
}
