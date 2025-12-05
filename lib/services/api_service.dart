import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    await loadToken();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    await loadToken();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    await loadToken();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {bool includeAuth = true}) async {
    await loadToken();
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    
    try {
      final response = await http.delete(
        url,
        headers: _getHeaders(includeAuth: includeAuth),
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> parseResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Invalid response from server');
    }

    final withinSuccessRange = response.statusCode >= 200 && response.statusCode < 300;
    final status = body['status'];

    if (withinSuccessRange && (status == null || status == 'success')) {
      return body;
    }

    final message = body['message'] ?? 'Request failed (${response.statusCode})';
    throw Exception(message);
  }
}
