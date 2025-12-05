import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const _userKey = 'user_profile';

  Future<void> _cacheUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<User?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> payload = jsonDecode(jsonString) as Map<String, dynamic>;
      return User.fromJson(payload);
    } catch (_) {
      await _clearCachedUser();
      return null;
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      final payload = _apiService.parseResponse(response);
      final authResponse = AuthResponse.fromJson(payload['data'] as Map<String, dynamic>);
      await _apiService.saveToken(authResponse.token);
      await _cacheUser(authResponse.user);
      return authResponse;
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        {
          'full_name': name,
          'email': email,
          'password': password,
          'confirm_password': password,
        },
        includeAuth: false,
      );

      final payload = _apiService.parseResponse(response);
      final authResponse = AuthResponse.fromJson(payload['data'] as Map<String, dynamic>);
      await _apiService.saveToken(authResponse.token);
      await _cacheUser(authResponse.user);
      return authResponse;
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await _apiService.post(ApiConfig.logout, {});
      _apiService.parseResponse(response);
      await _apiService.removeToken();
      await _clearCachedUser();
    } catch (e) {
      // Even if the API call fails, remove the local token
      await _apiService.removeToken();
      await _clearCachedUser();
    }
  }

  Future<User> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? location,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConfig.profile,
        {
          if (fullName != null) 'full_name': fullName,
          if (email != null) 'email': email,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (location != null) 'location': location,
        },
      );

      final payload = _apiService.parseResponse(response);
      final user = User.fromJson(payload['data'] as Map<String, dynamic>);
      await _cacheUser(user);
      return user;
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
}
