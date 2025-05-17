import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijauloka/models/product.dart';

class ProductService {
  static const String baseUrl = 'https://admin.hijauloka.my.id/api';
  static const String imageBaseUrl = 'https://admin.hijauloka.my.id/uploads/';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_products.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final productsList = List<Map<String, dynamic>>.from(data['data']);
          return productsList.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load products');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_product_detail.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          return Product.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load product details');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static String getFullImageUrl(String imageUrl) {
    try {
      if (imageUrl.isEmpty || imageUrl == "null") {
        throw Exception("Invalid image URL");
      }
      String cleanImageUrl = imageUrl.trim();
      cleanImageUrl = cleanImageUrl.replaceAll('//', '/');
      return imageBaseUrl + cleanImageUrl;
    } catch (e) {
      return 'https://via.placeholder.com/150';
    }
  }
}