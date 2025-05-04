import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/widgets/product_card.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'widgets/welcome_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/blog_section.dart';
import 'widgets/cta_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: ProductCard(
                            name: 'Lidah Mertua',
                            price: 'Rp32.000',
                            imageUrl: 'https://via.placeholder.com/150',
                            rating: 0.0,
                            category: 'Indoor',  // Fixed: removed space before colon
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