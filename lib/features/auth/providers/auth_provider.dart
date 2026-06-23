import 'package:flutter/material.dart';
import 'package:aeronet_app_flutter/data/repositories/auth_repository.dart';
import 'package:aeronet_app_flutter/data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthProvider() {
    _currentUser = AuthRepository.instance.currentUser;
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => AuthRepository.instance.isLoggedIn;

  void checkSession() {
    _currentUser = AuthRepository.instance.currentUser;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await AuthRepository.instance.login(email, password);
      _currentUser = user;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String name, String email, String password) async {
    _setLoading(true);
    try {
      await AuthRepository.instance.signup(name, email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await AuthRepository.instance.logout();
      _currentUser = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
