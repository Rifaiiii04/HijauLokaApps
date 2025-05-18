import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Keep for compatibility with existing code
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:hijauloka/services/auth_service.dart';
import 'package:hijauloka/screens/checkout/checkout_screen.dart';
import 'package:hijauloka/services/api_client.dart';
import 'package:hijauloka/widgets/network_error_dialog.dart';

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double productPrice;
  final String productImage;
  int quantity;
  bool isSelected; // Add selection state

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
    this.isSelected = true, // Default to selected
  });

  double get totalPrice => productPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id_cart'],
      productId: json['id_product'],
      productName: json['product']['nama_product'],
      productPrice: double.parse(json['product']['harga'].toString()),
      productImage: json['product']['image_url'] ?? '',
      quantity: json['jumlah'],
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _userId;
  bool _isLoggedIn = false;
  bool _selectAll = true; // Track if all items are selected

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    final userId = await AuthService.getUserId();

    setState(() {
      _isLoggedIn = isLoggedIn;
      _userId = userId;
    });

    if (isLoggedIn && userId != null) {
      _loadCartItems();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Silakan login untuk melihat keranjang belanja Anda.';
      });
    }
  }

  Future<void> _loadCartItems() async {
    if (_userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Silakan login untuk melihat keranjang belanja Anda.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiClient.get(
        'get_cart.php',
        queryParams: {'id_user': _userId!},
        converter: (data) {
          return (data as List).map((item) => CartItem.fromJson(item)).toList();
        },
      );

      if (response.success) {
        setState(() {
          _cartItems = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading cart items: $e');
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    final item = _cartItems[index];

    if (newQuantity <= 0) {
      // Remove the item
      await _removeItem(index);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://admin.hijauloka.my.id/api/update_cart.php'),
            body: {
              'id_cart': item.id.toString(),
              'jumlah': newQuantity.toString(),
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _cartItems[index].quantity = newQuantity;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to update cart'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error updating cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(int index) async {
    final item = _cartItems[index];

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://admin.hijauloka.my.id/api/remove_from_cart.php'),
            body: {'id_cart': item.id.toString()},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _cartItems.removeAt(index);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'Failed to remove item from cart',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error removing item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Toggle selection for all items
  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      for (var item in _cartItems) {
        item.isSelected = _selectAll;
      }
    });
  }

  // Toggle selection for a single item
  void _toggleItemSelection(int index) {
    setState(() {
      _cartItems[index].isSelected = !_cartItems[index].isSelected;
      // Update _selectAll based on all items selection state
      _selectAll = _cartItems.every((item) => item.isSelected);
    });
  }

  // Get only selected items
  List<CartItem> get _selectedItems {
    return _cartItems.where((item) => item.isSelected).toList();
  }

  // Calculate subtotal for selected items only
  double get _selectedTotalPrice {
    return _selectedItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Check if any items are selected
  bool get _hasSelectedItems {
    return _cartItems.any((item) => item.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(title: 'Keranjang Belanja'),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : !_isLoggedIn
              ? _buildLoginRequired()
              : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartList(),
      bottomNavigationBar:
          (!_isLoggedIn || _cartItems.isEmpty || !_hasSelectedItems)
              ? null
              : _buildCheckoutBar(),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Login Diperlukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan login untuk melihat keranjang belanja Anda',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    // Check if the error is related to connection issues
    final bool isConnectionError =
        _errorMessage.toLowerCase().contains('connection') ||
        _errorMessage.toLowerCase().contains('refused') ||
        _errorMessage.toLowerCase().contains('network') ||
        _errorMessage.toLowerCase().contains('timeout');

    if (isConnectionError) {
      // Show the connection error dialog when the view is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          NetworkErrorDialog.show(
            context,
            message: _errorMessage,
            onRetry: _loadCartItems,
            onContinue: () {
              // Navigate back to home screen
              Navigator.pop(context);
            },
          );
        }
      });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isConnectionError ? Icons.wifi_off : Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            isConnectionError ? 'Connection Problem' : 'Error Loading Cart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isConnectionError
                  ? 'Cannot connect to the server. Please check your internet connection.'
                  : _errorMessage,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadCartItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Keranjang Belanja Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan produk ke keranjang untuk mulai berbelanja',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Jelajahi Produk'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return Column(
      children: [
        // Select all option
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: _selectAll,
                onChanged: (_) => _toggleSelectAll(),
                activeColor: AppTheme.primaryColor,
              ),
              Text(
                'Pilih Semua Produk',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return _buildCartItemCard(item, index);
            },
          ),
        ),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add checkbox
            Checkbox(
              value: item.isSelected,
              onChanged: (_) => _toggleItemSelection(index),
              activeColor: AppTheme.primaryColor,
            ),
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.productImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${item.productPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Controls
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed:
                                () => _updateQuantity(index, item.quantity - 1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed:
                                () => _updateQuantity(index, item.quantity + 1),
                          ),
                        ],
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeItem(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${_selectedItems.length} item)',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Rp${_selectedTotalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biaya Pengiriman',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Text(
                'Rp15,000',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp${(_selectedTotalPrice + 15000).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            _hasSelectedItems
                ? () {
                  // Make sure at least one item is selected
                  if (_selectedItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pilih setidaknya satu produk untuk checkout',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Convert SELECTED cart items to JSON string and pass to checkout screen
                  final cartItemsJson = jsonEncode(
                    _selectedItems
                        .map(
                          (item) => {
                            'id': item.id,
                            'productId': item.productId,
                            'productName': item.productName,
                            'productPrice': item.productPrice,
                            'productImage': item.productImage,
                            'quantity': item.quantity,
                          },
                        )
                        .toList(),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CheckoutScreen(
                            cartItemsJson: cartItemsJson,
                            subtotal: _selectedTotalPrice,
                          ),
                    ),
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: Colors.grey,
        ),
        child: Text(
          'Checkout (${_selectedItems.length} Item)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
