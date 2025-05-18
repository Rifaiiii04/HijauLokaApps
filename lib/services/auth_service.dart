import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijauloka/models/user.dart';

class AuthService {
  // Updated API URL to use hosted URL
  final String baseUrl = 'https://admin.hijauloka.my.id/api';

  // For storing user data
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';
  // Add missing constants for user ID
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Register user
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String address,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': name,
          'email': email,
          'password': password,
          'alamat': address,
          'no_tlp': phone,
        }),
      );

      final data = jsonDecode(response.body);

      // If registration is successful, automatically log the user in
      if (response.statusCode == 200 && data['success'] == true) {
        await login(email, password);
      }

      return data;
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(userKey, jsonEncode(data['user']));

        // Save token if provided
        if (data['token'] != null) {
          await prefs.setString(tokenKey, data['token']);
        }

        // Save user ID, name, and email separately for easier access
        if (data['user'] != null) {
          await prefs.setString(_userIdKey, data['user']['id_user'].toString());
          await prefs.setString(_userNameKey, data['user']['nama'] ?? '');
          await prefs.setString(_userEmailKey, data['user']['email'] ?? '');
        }

        // Save login timestamp
        await prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
      }

      return data;
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userIdKey) && prefs.getString(_userIdKey) != null;
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);

    if (userData != null) {
      try {
        return User.fromJson(jsonDecode(userData));
      } catch (e) {
        print('Error parsing user data: $e');
        await prefs.remove(userKey);
        return null;
      }
    }

    return null;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
    await prefs.remove(tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Get auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }
}
