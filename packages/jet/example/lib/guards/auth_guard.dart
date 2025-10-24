import 'package:flutter/material.dart';
import 'package:jet/jet_router.dart';

/// Simple authentication service for demonstration
class AuthService {
  static bool _isAuthenticated = false;
  static String? _userName;

  static bool get isAuthenticated => _isAuthenticated;
  static String? get userName => _userName;

  static Future<void> login(String userName) async {
    // Simulate async login
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    _userName = userName;
  }

  static Future<void> logout() async {
    // Simulate async logout
    await Future.delayed(const Duration(milliseconds: 300));
    _isAuthenticated = false;
    _userName = null;
  }
}

/// Authentication guard that protects routes requiring login
class AuthGuard extends RouteGuard {
  const AuthGuard();

  @override
  Future<bool> canActivate(BuildContext context, JetRoute route) async {
    // Simulate checking authentication status
    return AuthService.isAuthenticated;
  }

  @override
  String? redirect(BuildContext context, JetRoute route) {
    // Redirect to login page if not authenticated
    return '/login';
  }
}
