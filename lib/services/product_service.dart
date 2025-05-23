import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:hijauloka/models/product.dart';

class ProductService {
  static const String baseUrl = 'https://admin.hijauloka.my.id/api';
  static const String imageBaseUrl = 'https://admin.hijauloka.my.id/uploads/';

  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }

    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$imageBaseUrl$imagePath';
  }

  Future<List<Product>> fetchProducts() async {
    try {
      print('Fetching products from: $baseUrl/get_products.php');

      final response = await http
          .get(
            Uri.parse('$baseUrl/get_products.php'),
            headers: {'Accept-Charset': 'utf-8'},
          )
          .timeout(const Duration(seconds: 15));

      print('Response status code: ${response.statusCode}');
      print('Response body length: ${response.body.length}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        try {
          // Try to fix malformed UTF-8 characters
          String cleanedResponse = utf8.decode(
            response.bodyBytes,
            allowMalformed: true,
          );

          final data = json.decode(cleanedResponse);
          print('Decoded JSON data: $data');

          if (data['success'] == true && data['data'] != null) {
            final products =
                (data['data'] as List)
                    .map((json) => Product.fromJson(json))
                    .toList();

            print('Parsed ${products.length} products');
            return products;
          } else {
            throw Exception(data['message'] ?? 'Failed to load products');
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          print(
            'Raw response: ${response.body.substring(0, min(100, response.body.length))}...',
          );
          throw Exception('Error parsing response: $jsonError');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Map<String, dynamic>> getProductsByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_products_by_category.php?category_id=$categoryId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept-Charset': 'utf-8',
        },
      );

      final result = json.decode(response.body);
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
