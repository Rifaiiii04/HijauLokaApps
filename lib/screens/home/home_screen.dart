import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
// import 'package:hijauloka/widgets/product_card.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:http/http.dart' as http;
import '../../models/featured_product.dart';
import 'widgets/welcome_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/blog_section.dart';
import 'widgets/cta_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FeaturedProduct> _products = [];
  bool _isLoading = true;
  String? _error;

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
      print('API response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: ${data['data']}');
        if (data['success'] == true && data['data'] != null) {
          final list =
              (data['data'] as List)
                  .where((e) => e != null)
                  .map((e) => FeaturedProduct.fromJson(e))
                  .toList();
          setState(() {
            _products = list;
            _isLoading = false;
          });
        } else {
          setState(() {
            _products = [];
            _isLoading = false;
            _error = 'Tidak ada produk rekomendasi.';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Gagal mengambil data produk. [${response.statusCode}]';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Terjadi kesalahan: $e';
      });
    }
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
            child: Column(
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
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                          ? Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                          : _products.isEmpty
                          ? const Center(
                            child: Text('Tidak ada produk rekomendasi.'),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              
                              // Fixed image URL handling to prevent duplication
                              String imageUrl;
                              if (product.gambar != null && product.gambar!.isNotEmpty) {
                                // Check if the image path already contains the full URL
                                if (product.gambar!.startsWith('http')) {
                                  imageUrl = product.gambar!;
                                } else if (product.gambar!.startsWith('uploads/')) {
                                  imageUrl = "https://admin.hijauloka.my.id/${product.gambar}";
                                } else {
                                  imageUrl = "https://admin.hijauloka.my.id/uploads/${product.gambar}";
                                }
                              } else {
                                imageUrl = 'https://via.placeholder.com/150';
                              }
                              
                              print('Loading image from: $imageUrl');
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 15),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                        child: Image.network(
                                          imageUrl,
                                          height: 110,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            print('Error loading image: $error');
                                            print('Failed URL: $imageUrl');
                                            return Container(
                                              height: 110,
                                              width: double.infinity,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.namaProduct ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                ...List.generate(
                                                  5,
                                                  (star) => Icon(
                                                    Icons.star,
                                                    color:
                                                        star <
                                                                (product.rating ??
                                                                        0)
                                                                    .floor()
                                                            ? Colors.amber
                                                            : Colors.amber
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                    size: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '(${(product.rating ?? 0.0).toStringAsFixed(1)})',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rp${product.harga.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.favorite_border,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppTheme.primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .shopping_cart_outlined,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Beli',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                            },
                          ),
                ),
              ],
            ),
          ),
          // Categories section
          const CategoriesSection(),
          // Blog section
          const BlogSection(),
          // Call to action section
          const CTASection(),
        ],
      ),
    );
  }
}
