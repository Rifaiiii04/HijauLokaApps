import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hijauloka/widgets/product_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  RangeValues _currentRangeValues = const RangeValues(0, 1000000);
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('Fetching products...');
      final response = await http.get(
        Uri.parse('http://192.168.170.213/hijauloka/api/get_products.php'),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');

        if (data['status'] == 'success') {
          final productsList = List<Map<String, dynamic>>.from(data['data']);
          print('Number of products: ${productsList.length}');

          setState(() {
            products = productsList;
            isLoading = false;
            errorMessage = '';
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load products';
            isLoading = false;
          });
        }
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          errorMessage =
              errorData['message'] ?? 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        errorMessage = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : errorMessage.isNotEmpty
              ? Center(
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
                      onPressed: fetchProducts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Temukan berbagai koleksi tanaman hias\npilihan untuk rumah Anda',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                      child:
                          products.isEmpty
                              ? const Center(child: Text('No products found'))
                              : GridView.builder(
                                padding: const EdgeInsets.all(15),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 28,
                                    ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return _buildProductCard(
                                    name: product['name'],
                                    price: 'Rp${product['price']}',
                                    category:
                                        product['category'] ?? 'Uncategorized',
                                    rating:
                                        product['rating']?.toDouble() ?? 0.0,
                                    imageUrl: product['image'],
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String price,
    required String category,
    required double rating,
    required String imageUrl,
  }) {
    // Use the same image URL logic as before
    const String baseImgUrl = "http://192.168.170.213/hijauloka/uploads/";
    String cleanImageUrl = imageUrl.trim();
    cleanImageUrl = cleanImageUrl.replaceAll('//', '/');
    final fullImageUrl = baseImgUrl + cleanImageUrl;

    return ProductCard(
      name: name,
      price: price,
      imageUrl: fullImageUrl,
      rating: rating,
      category: category,
      onTap: () {},
    );
  }

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Produk',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Range
                        _buildSectionTitle('Rentang Harga'),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Rp0'),
                                  Text('Rp1.000.000'),
                                ],
                              ),
                              const SizedBox(height: 15),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RangeSlider(
                                        values: _currentRangeValues,
                                        max: 1000000,
                                        divisions: 10,
                                        activeColor: AppTheme.primaryColor,
                                        labels: RangeLabels(
                                          _currentRangeValues.start
                                              .round()
                                              .toString(),
                                          _currentRangeValues.end
                                              .round()
                                              .toString(),
                                        ),
                                        onChanged: (RangeValues values) {
                                          setState(() {
                                            _currentRangeValues = values;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 12,
                                                    ),
                                              ),
                                              controller: TextEditingController(
                                                text:
                                                    _currentRangeValues.start
                                                        .round()
                                                        .toString(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          const Text('–'),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 12,
                                                    ),
                                              ),
                                              controller: TextEditingController(
                                                text:
                                                    _currentRangeValues.end
                                                        .round()
                                                        .toString(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Categories
                        _buildSectionTitle('Kategori'),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildCheckboxItem('Indoor'),
                              _buildCheckboxItem('Outdoor'),
                              _buildCheckboxItem('Mudah dirawat'),
                              _buildCheckboxItem('Florikultura'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Rating
                        _buildSectionTitle('Rating'),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildRatingCheckbox(5, true),
                              _buildRatingCheckbox(4, false),
                              _buildRatingCheckbox(3, false),
                              _buildRatingCheckbox(2, false),
                              _buildRatingCheckbox(1, false),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Sort by
                        _buildSectionTitle('Urutkan'),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: 'Popularitas',
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Popularitas',
                                  child: Text('Popularitas'),
                                ),
                                DropdownMenuItem(
                                  value: 'Harga Terendah',
                                  child: Text('Harga Terendah'),
                                ),
                                DropdownMenuItem(
                                  value: 'Harga Tertinggi',
                                  child: Text('Harga Tertinggi'),
                                ),
                                DropdownMenuItem(
                                  value: 'Rating Tertinggi',
                                  child: Text('Rating Tertinggi'),
                                ),
                              ],
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ),

                // Buttons
                Container(
                  padding: const EdgeInsets.all(20),
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
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Terapkan',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCheckboxItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: false,
              onChanged: (bool? value) {},
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildRatingCheckbox(int stars, bool hasUpOption) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: false,
              onChanged: (bool? value) {},
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
          if (hasUpOption) const Text(' & Up', style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
