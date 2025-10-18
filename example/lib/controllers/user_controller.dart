import 'package:jetx/jetx.dart';
import 'user_service.dart';

class UserController extends JetxController {
  final UserService service;

  UserController(this.service);

  final name = 'John'.obs;
  final age = 30.obs;

  void loadUserData() {}
}
