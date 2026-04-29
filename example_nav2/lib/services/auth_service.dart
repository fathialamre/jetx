import 'package:jetx/jetx.dart';

class AuthService extends JetxService {
  static AuthService get to => Jet.find();

  /// Mocks a login process
  final isLoggedIn = false.obs;
  bool get isLoggedInValue => isLoggedIn.value;

  void login() {
    isLoggedIn.value = true;
  }

  void logout() {
    isLoggedIn.value = false;
  }
}
