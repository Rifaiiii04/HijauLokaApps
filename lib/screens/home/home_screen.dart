import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/widgets/product_card.dart';
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

  @override
  void initState() {
    super.initState();
    fetchFeaturedProducts();
  }

  Future<void> fetchFeaturedProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.51.213/hijaulokapi/api/product/featured.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          _products =
              (data['data'] as List)
                  .map((e) => FeaturedProduct.fromJson(e))
                  .toList();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
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
                            : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: ProductCard(
                                    name: product.namaProduct,
                                    price:
                                        'Rp${product.harga.toStringAsFixed(0)}',
                                    imageUrl: product.gambar,
                                    rating: product.rating ?? 0.0,
                                    category:
                                        '', // Isi jika ingin tampil kategori
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

            // Bottom padding
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
