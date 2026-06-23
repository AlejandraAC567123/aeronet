import 'package:aeronet_app_flutter/data/services/api_client.dart';
import 'package:aeronet_app_flutter/data/models/user_model.dart';
import 'package:aeronet_app_flutter/core/utils/helpers.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.instance.post('/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    
    final data = asMap(response);
    final userJson = asMap(data['user']);
    final token = '${data['access_token'] ?? ''}';
    final user = UserModel.fromJson(userJson);

    return {
      'token': token,
      'user': user,
    };
  }

  Future<void> signupClient(String name, String email, String password) async {
    await ApiClient.instance.post('/auth/signup-client', {
      'full_name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
  }
}
