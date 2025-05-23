import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijauloka/config/api_config.dart';
import 'package:hijauloka/models/category.dart';

class CategoryService {
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://admin.hijauloka.my.id/api/get_categories.php'),
        headers: {'Content-Type': 'application/json'},
      );
      print('API RESPONSE: ${response.body}');
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }
      final result = json.decode(response.body);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> getPlantCategories() async {
    return await getCategories();
  }
}
