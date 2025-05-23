import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:http/http.dart' as http; // Fixed the quote here
import '../../models/featured_product.dart';
import 'widgets/welcome_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/blog_section.dart';
import 'widgets/cta_section.dart';
import 'package:hijauloka/models/product.dart';
import 'package:hijauloka/screens/product/product_detail_screen.dart';
import 'package:hijauloka/services/auth_service.dart';
import 'package:hijauloka/utils/currency_formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FeaturedProduct> _products = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchFeaturedProducts();
  }

  Future<void> fetchFeaturedProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://admin.hijauloka.my.id/api/product/featured.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final list =
              (data['data'] as List)
                  .where((e) => e != null)
                  .map((e) => FeaturedProduct.fromJson(e))
                  .toList();

          setState(() => _products = list);
        } else {
          setState(() => _error = 'Tidak ada produk rekomendasi.');
        }
      } else {
        setState(
          () =>
              _error = 'Gagal mengambil data produk. [${response.statusCode}]',
        );
      }
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Product _convertToProduct(FeaturedProduct featuredProduct) {
    return Product(
      id: featuredProduct.id_product ?? '0',
      name: featuredProduct.nama_product ?? '',
      price: featuredProduct.harga ?? 0,
      description: featuredProduct.desk_product ?? '',
      image: featuredProduct.gambar ?? '',
      category: featuredProduct.nama_kategori ?? '',
      rating: featuredProduct.rating ?? 0.0,
      stock: featuredProduct.stok ?? 0,
      categoryId: featuredProduct.id_kategori ?? '0',
    );
  }

  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty)
      return 'https://via.placeholder.com/150';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('uploads/'))
      return "https://admin.hijauloka.my.id/$imagePath";
    return "https://admin.hijauloka.my.id/uploads/$imagePath";
  }

  Widget _buildProductCard(FeaturedProduct product) {
    final imageUrl = _buildImageUrl(product.gambar);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = _products.indexOf(product);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ProductDetailScreen(product: _convertToProduct(product)),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildProductImage(imageUrl), _buildProductInfo(product)],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Image.network(
        imageUrl,
        height: 110,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              height: 110,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 40,
              ),
            ),
      ),
    );
  }

  Widget _buildProductInfo(FeaturedProduct product) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.nama_product ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _buildRatingSection(product),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(product.harga ?? 0),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildRatingSection(FeaturedProduct product) {
    return Row(
      children: [
        ...List.generate(
          5,
          (star) => Icon(
            Icons.star,
            color:
                star < (product.rating ?? 0).floor()
                    ? Colors.amber
                    : Colors.amber.withOpacity(0.3),
            size: 12,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '(${(product.rating ?? 0.0).toStringAsFixed(1)})',
          style: TextStyle(color: Colors.grey[600], fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.favorite_border,
            color: Colors.grey,
            size: 16,
          ),
        ),
        GestureDetector(
          onTap: () => _addToCart(_convertToProduct(_products[_currentIndex])),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

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
        'id_product': product.id,
        'jumlah': quantity.toString(),
      };

      final response = await http
          .post(
            Uri.parse('https://admin.hijauloka.my.id/api/add_to_cart.php'),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'Produk berhasil ditambahkan ke keranjang',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${data['message'] ?? 'Gagal menambahkan produk ke keranjang'}',
              ),
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

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Login Diperlukan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Silakan login untuk menambahkan produk ke keranjang',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _products.length,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.only(right: 15),
            child: _buildProductCard(_products[index]),
          ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        _error!,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi Terbaik',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 250,
          child:
              _isLoading
                  ? _buildLoading()
                  : _error != null
                  ? _buildError()
                  : _products.isEmpty
                  ? const Center(child: Text('Tidak ada produk rekomendasi.'))
                  : _buildProductList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: const AppHeader(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const WelcomeSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                _buildRecommendedSection(), // Removed const here as it calls a method
          ),
          const CategoriesSection(),
          const BlogSection(),
          const CTASection(),
        ],
      ),
    );
  }
}
