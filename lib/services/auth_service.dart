import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijauloka/models/user.dart';

class AuthService {
  // Change this to your actual API URL
  final String baseUrl = 'http://10.0.2.2/hijauloka/api';
  
  // For storing user data
  static const String userKey = 'user_data';
  
  // Register user
  Future<Map<String, dynamic>> register(String name, String email, String password, String address, String phone) async {
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
    
    return jsonDecode(response.body);
  }
  
  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      // Save user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userKey, jsonEncode(data['user']));
    }
    
    return data;
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(userKey);
  }
  
  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    
    return null;
  }
  
  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }
}