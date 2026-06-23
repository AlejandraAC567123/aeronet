import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aeronet_app_flutter/data/models/user_model.dart';
import 'package:aeronet_app_flutter/core/constants/app_constants.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();
  
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.sessionTokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.sessionTokenKey);
  }

  // User Management
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.sessionUserKey, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final userJson = _prefs.getString(AppConstants.sessionUserKey);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  // API Base URL
  Future<void> saveApiBaseUrl(String url) async {
    await _prefs.setString(AppConstants.apiBaseUrlKey, url.trim().replaceAll(RegExp(r'/+$'), ''));
  }

  String getApiBaseUrl(String fallbackUrl) {
    return _prefs.getString(AppConstants.apiBaseUrlKey) ?? fallbackUrl;
  }

  // Clear Session
  Future<void> clearAuth() async {
    await _prefs.remove(AppConstants.sessionTokenKey);
    await _prefs.remove(AppConstants.sessionUserKey);
  }
}
