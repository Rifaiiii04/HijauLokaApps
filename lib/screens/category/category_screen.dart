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
                                    childAspectRatio: 0.68, // Adjusted from 0.7 to 0.68 to make cards slightly taller
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
                                            builder: (context) => ProductDetailScreen(productId: product.id),
                                          ),
                                        );
                                      },
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
