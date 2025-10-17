import 'auth_service.dart';

class UserService {
  final AuthService authService;

  UserService(this.authService);

  String getUserData() {
    if (authService.isAuthenticated()) {
      return 'User data from service (authenticated)';
    }
    return 'Not authenticated';
  }

  void updateUser(String name) {
    print('Updating user: $name with token: ${authService.getToken()}');
  }
}
