import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijauloka/models/cart_item.dart';
import 'package:hijauloka/services/auth_service.dart';

class OrderService {
  final String baseUrl = 'https://admin.hijauloka.my.id/api';
  final AuthService _authService = AuthService();

  // Debug method to validate parameters
  void _validateCreateOrderParams(Map<String, dynamic> data) {
    try {
      // Check for required fields
      final requiredFields = [
        'user_id',
        'shipping_address_id',
        'payment_method',
        'shipping_method',
        'shipping_cost',
        'subtotal',
        'total',
        'items',
      ];

      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          print('WARNING: Missing required field: $field');
        }
      }

      // Validate items array
      if (data['items'] is List && (data['items'] as List).isNotEmpty) {
        final items = data['items'] as List;
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          if (item is Map) {
            if (!item.containsKey('product_id') || item['product_id'] == null) {
              print('WARNING: Item $i is missing product_id');
            }
            if (!item.containsKey('quantity') || item['quantity'] == null) {
              print('WARNING: Item $i is missing quantity');
            }
            if (!item.containsKey('price') || item['price'] == null) {
              print('WARNING: Item $i is missing price');
            }
          } else {
            print('WARNING: Item $i is not a Map');
          }
        }
      } else {
        print('WARNING: items is not a valid List or is empty');
      }

      print('Validation completed for order data');
    } catch (e) {
      print('Error validating order data: $e');
    }
  }

  // Create a new order
  Future<Map<String, dynamic>> createOrder({
    required String shippingAddressId,
    required String paymentMethod,
    required String shippingMethod,
    required double shippingCost,
    required double subtotal,
    required double total,
    required List<CartItem> items,
  }) async {
    try {
      final user = await _authService.getCurrentUser();

      if (user == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // Format data to match database schema exactly
      final Map<String, dynamic> orderData = {
        'user_id': user.id.toString(),
        'user_name': user.name,
        'user_email': user.email,
        'user_phone': user.phone,
        'shipping_address_id': shippingAddressId,
        'payment_method': paymentMethod,
        'shipping_method': shippingMethod,
        'shipping_cost': shippingCost,
        'subtotal': subtotal,
        'total': total,
        'items':
            items
                .map(
                  (item) => {
                    'product_id': item.productId.toString(),
                    'quantity': item.quantity.toString(),
                    'price': item.productPrice,
                    'product_name': item.productName,
                  },
                )
                .toList(),
      };

      // Validate parameters before sending
      _validateCreateOrderParams(orderData);

      print('Creating order with data: ${jsonEncode(orderData)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/order/create_order.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(orderData),
          )
          .timeout(const Duration(seconds: 30));

      print(
        'Order creation response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 500) {
        return {
          'success': false,
          'message': 'Database error occurred. Please check server logs.',
          'debug_info':
              'The server returned a 500 error. This is likely due to a database constraint or field type mismatch.',
        };
      }

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server returned status code ${response.statusCode}',
          'debug_info': response.body,
        };
      }

      // Add safety check for empty response
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Server returned empty response'};
      }

      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } catch (e) {
        return {
          'success': false,
          'message': 'Failed to parse server response',
          'debug_info': response.body,
        };
      }
    } catch (e) {
      print('Error creating order: $e');
      return {'success': false, 'message': 'Error creating order: $e'};
    }
  }

  // Get order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final user = await _authService.getCurrentUser();
      String userId = user?.id.toString() ?? "";

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/order/get_order_detail.php?order_id=${orderId.toString()}&user_id=$userId',
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message':
              'Failed to retrieve order details. Server returned status code ${response.statusCode}',
          'debug_info': response.body,
        };
      }

      // Defensive: check if response is valid JSON
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } catch (e) {
        return {
          'success': false,
          'message': 'Server returned invalid data (not JSON).',
          'debug_info': response.body,
        };
      }
    } catch (e) {
      print('Error fetching order details: $e');
      return {'success': false, 'message': 'Error connecting to server: $e'};
    }
  }

  // Helper method to format dates consistently
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Get user orders
  Future<Map<String, dynamic>> getUserOrders({
    String status = '',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final user = await _authService.getCurrentUser();

      if (user == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      String url =
          '$baseUrl/order/get_user_orders.php?user_id=${user.id.toString()}&page=$page&limit=$limit';
      if (status.isNotEmpty) {
        url += '&status=$status';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message':
              'Failed to retrieve orders. Server returned status code ${response.statusCode}',
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('Error fetching user orders: $e');
      return {'success': false, 'message': 'Error connecting to server: $e'};
    }
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final user = await _authService.getCurrentUser();

      if (user == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/order/update_order_status.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'order_id': orderId.toString(),
              'status': status,
              'user_id': user.id.toString(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error updating order status: $e'};
    }
  }

  // Get payment URL for an order
  Future<Map<String, dynamic>> getPaymentUrl(String orderId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/order/payment.php?order_id=$orderId'))
          .timeout(const Duration(seconds: 15));

      // This might return HTML, so handle appropriately
      if (response.statusCode == 200) {
        // For now, just return the URL
        return {
          'success': true,
          'payment_url': '$baseUrl/order/payment.php?order_id=$orderId',
        };
      } else {
        return {'success': false, 'message': 'Failed to get payment URL'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error getting payment URL: $e'};
    }
  }
}
