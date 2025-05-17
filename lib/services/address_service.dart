import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hijauloka/models/shipping_address.dart';
import 'package:hijauloka/services/auth_service.dart';

class AddressService {
  final String baseUrl = 'https://admin.hijauloka.my.id/api';
  final AuthService _authService = AuthService();

  // Helper function untuk konversi ke string
  String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

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
        'user_id': _toString(user.id),
        'recipient_name': _toString(address.recipientName),
        'phone': _toString(address.phone),
        'address_label': address.addressLabel,
        'address': _toString(address.address),
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
        'id': _toString(address.id),
        'recipient_name': _toString(address.recipientName),
        'phone': _toString(address.phone),
        'address_label': address.addressLabel,
        'address': _toString(address.address),
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
      body: jsonEncode({'id': _toString(addressId)}),
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
        'id': _toString(addressId),
        'user_id': _toString(user.id),
      }),
    );

    return jsonDecode(response.body);
  }
}
