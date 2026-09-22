import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _userNameKey = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';

  Uri _uri(String path) => Uri.parse('${AppConstants.baseUrl}$path');

  Future<AuthResult> _postAuth(String path, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(AppConstants.requestTimeout);

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = AuthResult.fromJson(
          (decoded as Map).cast<String, dynamic>(),
        );
        await _saveSession(result);
        return result;
      }

      String detail = 'Something went wrong.';
      if (decoded is Map && decoded['detail'] != null) {
        detail = decoded['detail'].toString();
      }
      throw AuthException(detail);
    } on SocketException {
      throw const AuthException('Could not reach the server.');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected error: $e');
    }
  }

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) {
    return _postAuth('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<AuthResult> login({required String email, required String password}) {
    return _postAuth('/auth/login', {'email': email, 'password': password});
  }

  Future<void> _saveSession(AuthResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, result.accessToken);
    await prefs.setString(_userIdKey, result.user.id);
    await prefs.setString(_userNameKey, result.user.name);
    await prefs.setString(_userEmailKey, result.user.email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);
    if (id == null || name == null || email == null) return null;
    return AppUser(id: id, name: name, email: email);
  }
}
