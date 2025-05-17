import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijauloka/models/product.dart';

class ProductService {
  static const String baseUrl = 'https://admin.hijauloka.my.id/api';
  static const String imageBaseUrl = 'https://admin.hijauloka.my.id/uploads/';

  static String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$imageBaseUrl$imagePath';
  }

  Future<List<Product>> fetchProducts() async {
    try {
      print('Fetching products from: $baseUrl/product/all.php');
      
      final response = await http.get(
        Uri.parse('$baseUrl/product/all.php'),
      ).timeout(const Duration(seconds: 15)); // Add timeout
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }
        
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Connection error: $e');
    }
  }
}