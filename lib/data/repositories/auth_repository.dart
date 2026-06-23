import 'package:aeronet_app_flutter/data/services/auth_service.dart';
import 'package:aeronet_app_flutter/data/services/storage_service.dart';
import 'package:aeronet_app_flutter/data/models/user_model.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  UserModel? get currentUser => StorageService.instance.getUser();
  String? get token => StorageService.instance.getToken();
  bool get isLoggedIn => token != null && currentUser != null;

  Future<UserModel> login(String email, String password) async {
    final authData = await AuthService.instance.login(email, password);
    final String tokenVal = authData['token'];
    final UserModel userVal = authData['user'];

    await StorageService.instance.saveToken(tokenVal);
    await StorageService.instance.saveUser(userVal);

    return userVal;
  }

  Future<void> signup(String name, String email, String password) async {
    await AuthService.instance.signupClient(name, email, password);
  }

  Future<void> logout() async {
    await StorageService.instance.clearAuth();
  }
}
