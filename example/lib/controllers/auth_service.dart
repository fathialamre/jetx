// No dependencies - base service
class AuthService {
  bool isAuthenticated() {
    return true;
  }

  String getToken() {
    return 'mock-token-12345';
  }
}
