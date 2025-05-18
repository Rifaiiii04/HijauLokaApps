import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'https://admin.hijauloka.my.id/api';
  static const String fallbackBaseUrl = 'http://localhost:8000/api';

  static bool _usingFallbackServer = false;

  // Get the current active URL
  static String get activeBaseUrl {
    if (_usingFallbackServer) {
      return fallbackBaseUrl;
    } else {
      return baseUrl;
    }
  }

  // Check if we're using fallback server
  static bool get usingFallbackServer => _usingFallbackServer;

  // Set fallback server
  static Future<void> setUsingFallbackServer(bool value) async {
    _usingFallbackServer = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('using_fallback_server', value);
  }

  // Load settings from shared preferences
  static Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _usingFallbackServer = prefs.getBool('using_fallback_server') ?? false;
    } catch (e) {
      // In case of error, keep defaults
      _usingFallbackServer = false;
    }
  }
}
