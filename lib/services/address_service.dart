import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijauloka/models/shipping_address.dart';
import 'package:hijauloka/services/auth_service.dart';

class AddressService {
  final String baseUrl = 'http://192.168.50.213/hijauloka/api';
  final AuthService _authService = AuthService();

  // Get all shipping addresses for the current user
  Future<List<ShippingAddress>> getShippingAddresses() async {
    final user = await _authService.getCurrentUser();

    if (user == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/address/get_addresses.php?user_id=${user.id}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['addresses'] != null) {
        return List<ShippingAddress>.from(
          data['addresses'].map((address) => ShippingAddress.fromJson(address)),
        );
      }
    }

    return [];
  }

  // Add a new shipping address
  Future<Map<String, dynamic>> addShippingAddress(
    ShippingAddress address,
  ) async {
    final user = await _authService.getCurrentUser();

    if (user == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/address/add_address.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': user.id.toString(),
        'recipient_name': address.recipientName,
        'phone': address.phone,
        'address_label': address.addressLabel,
        'address': address.address,
        'rt': address.rt,
        'rw': address.rw,
        'house_number': address.houseNumber,
        'postal_code': address.postalCode,
        'detail_address': address.detailAddress,
        'is_primary': address.isPrimary ? '1' : '0',
      }),
    );

    return jsonDecode(response.body);
  }

  // Update a shipping address
  Future<Map<String, dynamic>> updateShippingAddress(
    ShippingAddress address,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/address/update_address.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': address.id.toString(),
        'recipient_name': address.recipientName,
        'phone': address.phone,
        'address_label': address.addressLabel,
        'address': address.address,
        'rt': address.rt,
        'rw': address.rw,
        'house_number': address.houseNumber,
        'postal_code': address.postalCode,
        'detail_address': address.detailAddress,
        'is_primary': address.isPrimary ? '1' : '0',
      }),
    );

    return jsonDecode(response.body);
  }

  // Delete a shipping address
  Future<Map<String, dynamic>> deleteShippingAddress(int addressId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/address/delete_address.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': addressId.toString()}),
    );

    return jsonDecode(response.body);
  }

  // Set an address as primary
  Future<Map<String, dynamic>> setPrimaryAddress(int addressId) async {
    final user = await _authService.getCurrentUser();

    if (user == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/address/set_primary.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': addressId.toString(),
        'user_id': user.id.toString(),
      }),
    );

    return jsonDecode(response.body);
  }
}
