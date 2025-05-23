import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/product.dart'; // Add this import
import 'package:hijauloka/services/auth_service.dart'; // Add this import for AuthService
import 'package:hijauloka/utils/currency_formatter.dart';

class ProductDetail {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String image;
  final double rating;
  final String careVideo;
  final List<Review> reviews;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.image,
    required this.rating,
    required this.careVideo,
    required this.reviews,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    List<Review> reviewsList = [];
    if (json['reviews'] != null) {
      reviewsList = List<Review>.from(
        json['reviews'].map((review) => Review.fromJson(review)),
      );
    }

    return ProductDetail(
      id: json['id_product'],
      name: json['nama_product'],
      description: json['desk_product'],
      price: double.parse(json['harga'].toString()),
      stock: json['stok'],
      category: json['kategori'] ?? 'Uncategorized',
      image: json['gambar'],
      rating: double.parse(json['rating']?.toString() ?? '0.0'),
      careVideo: json['cara_rawat_video'] ?? '',
      reviews: reviewsList,
    );
  }
}

class Review {
  final int id;
  final String username;
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.username,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id_review'],
      username: json['username'] ?? 'Anonymous',
      rating: json['rating'],
      comment: json['ulasan'],
      date: json['tgl_review'],
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic>? productDetail;

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('Fetching product detail for ID: ${widget.product.id}');
      final response = await http
          .get(
            Uri.parse(
              'https://admin.hijauloka.my.id/api/get_product_detail.php?id=${widget.product.id}',
            ),
          )
          .timeout(const Duration(seconds: 15));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        final data = json.decode(response.body);

        // Check for both 'success' and 'status' keys as API might use either
        if ((data['success'] == true || data['status'] == 'success') &&
            data['data'] != null) {
          setState(() {
            productDetail = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load product details';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching product detail: $e');
      setState(() {
        errorMessage = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  // Move the _buildImagePlaceholder function inside the class
  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Gambar tidak tersedia',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchProductDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
              : _buildProductDetail(),
      bottomNavigationBar:
          isLoading || errorMessage.isNotEmpty ? null : _buildBottomBar(),
    );
  }

  Widget _buildProductDetail() {
    final product = productDetail!;

    // Gunakan image_url dari API jika tersedia, jika tidak buat URL sendiri
    final String imageUrl =
        product['image_url'] ??
        "https://admin.hijauloka.my.id/uploads/" + (product['gambar'] ?? '');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[100]),
            child:
                imageUrl.isEmpty
                    ? _buildImagePlaceholder()
                    : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        print('Image URL: $imageUrl');
                        return _buildImagePlaceholder();
                      },
                    ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rest of the product detail UI
                // ...
                // Category
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product['kategori'] ?? 'Tidak Berkategori',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ),

                const SizedBox(height: 12),

                // Product Name
                Text(
                  product['nama_product'] ?? 'Nama Produk',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Rating
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index <
                                (double.tryParse(
                                          product['rating']?.toString() ?? '0',
                                        ) ??
                                        0)
                                    .floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product['rating']?.toString() ?? '0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price
                Text(
                  CurrencyFormatter.format(
                    double.parse(product['harga']?.toString() ?? '0'),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),

                // Stock
                Text(
                  'Stok: ${product['stok'] ?? '0'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 24),

                // Description
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  product['desk_product'] ?? 'Deskripsi tidak tersedia',
                  style: TextStyle(color: Colors.grey[800], height: 1.5),
                ),

                const SizedBox(height: 24),

                // Care Instructions
                const Text(
                  'Petunjuk Perawatan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                product['cara_rawat_video'] != null &&
                        product['cara_rawat_video'].toString().isNotEmpty
                    ? InkWell(
                      onTap: () {
                        // Open video link
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tonton video perawatan',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Text(
                      'Petunjuk perawatan tidak tersedia',
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                const SizedBox(height: 24),

                // Reviews
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ulasan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                product['reviews'] == null ||
                        (product['reviews'] as List).isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Belum ada ulasan',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                    : Column(
                      children:
                          (product['reviews'] as List)
                              .take(3)
                              .map((review) => _buildReviewItem(review))
                              .toList(),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['username'] ?? 'Anonim',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                review['tgl_review']?.toString().split(' ')[0] ??
                    '', // Just show the date part
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < (int.tryParse(review['rating']?.toString() ?? '0') ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review['ulasan'] ?? 'Tidak ada komentar',
            style: TextStyle(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _addToCart(); // Call the add to cart method
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tambah ke Keranjang',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Beli Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to handle adding products to cart
  Future<void> _addToCart() async {
    // Check if user is logged in
    final bool isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn) {
      // Show login dialog or navigate to login screen
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

    // Get product ID from the product detail
    if (productDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detail produk tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fix: Access id_product directly from the Map
    final productId = productDetail!['id_product'];
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID produk tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int quantity = 1; // Default quantity

    setState(() {
      isLoading = true;
    });

    try {
      print(
        'Sending request with: userId=$userId, productId=$productId, quantity=$quantity',
      );

      final requestBody = {
        'id_user': userId,
        'id_product': productId.toString(),
        'jumlah': quantity.toString(),
      };
      print('Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse('https://admin.hijauloka.my.id/api/add_to_cart.php'),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 15));

      print('Add to cart response body: ${response.body}');

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
          // Show error message with more details
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
      print('Error adding to cart: $e');
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
        isLoading = false;
      });
    }
  }

  // Add this method to show login required dialog
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
}
