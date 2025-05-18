import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/product.dart';
import 'package:hijauloka/providers/filter_provider.dart';
import 'package:hijauloka/services/product_service.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:hijauloka/widgets/filter_drawer.dart';
import 'package:hijauloka/widgets/product_card.dart';
import 'package:hijauloka/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:hijauloka/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    
    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    filterProvider.setSearchQuery(_searchController.text);
    _applyFilters();
  }

  Future<void> fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final products = await _productService.fetchProducts();
      
      setState(() {
        _products = products;
        _isLoading = false;
        _errorMessage = '';
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    setState(() {
      _filteredProducts = filterProvider.applyFilters(_products);
    });
  }

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return const FilterDrawer();
      },
    ).then((_) => _applyFilters());
  }

  // Add this method to handle adding products to cart
  Future<void> _addToCart(Product product) async {
    // Check if user is logged in
    final bool isLoggedIn = await AuthService.isLoggedIn();
    
    if (!isLoggedIn) {
      // Show login dialog
      _showLoginRequiredDialog();
      return;
    }
    
    // Get the user ID from AuthService
    final String? userId = await AuthService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login tidak valid, silakan login ulang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final int quantity = 1; // Default quantity
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requestBody = {
        'id_user': userId,
        'id_product': product.id.toString(),
        'jumlah': quantity.toString(),
      };
      
      final response = await http.post(
        Uri.parse('https://admin.hijauloka.my.id/api/add_to_cart.php'),
        body: requestBody,
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Produk berhasil ditambahkan ke keranjang'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${data['message'] ?? 'Gagal menambahkan produk ke keranjang'}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Add this method to show login required dialog
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text('Anda harus login terlebih dahulu untuk menambahkan produk ke keranjang.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Header section - Wrap in SingleChildScrollView to prevent overflow
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // Add this to minimize height
                          children: [
                            const Text(
                              'Katalog Tanaman',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Temukan berbagai koleksi tanaman hias pilihan untuk rumah Anda',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              maxLines: 2, // Limit to 2 lines
                              overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                            ),
                            const SizedBox(height: 15),
                            // Search bar
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Cari tanaman...',
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    _showFilterDrawer(context);
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.filter_list,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Product grid
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: fetchProducts,
                          child: _filteredProducts.isEmpty
                              ? const Center(child: Text('No products found'))
                              : GridView.builder(
                                  padding: const EdgeInsets.all(15),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.68,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 28,
                                  ),
                                  itemCount: _filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = _filteredProducts[index];
                                    return ProductCard(
                                      name: product.name,
                                      price: 'Rp${product.price.toStringAsFixed(0)}',
                                      imageUrl: ProductService.getFullImageUrl(product.image),
                                      rating: product.rating,
                                      category: product.category,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductDetailScreen(product: product),
                                          ),
                                        );
                                      },
                                      onAddToCart: () => _addToCart(product),
                                    );
                                  },
                                ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
