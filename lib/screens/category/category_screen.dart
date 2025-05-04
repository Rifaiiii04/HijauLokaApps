import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/widgets/product_card.dart';
import 'package:hijauloka/widgets/app_header.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  RangeValues _currentRangeValues = const RangeValues(0, 1000000);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(),
      body: Column(
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
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
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            hintStyle: TextStyle(color: Colors.grey[500]),
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
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                // Sample product data
                final List<Map<String, dynamic>> products = [
                  {
                    'name': 'Lidah Mertua',
                    'price': 'Rp32.000',
                    'category': 'Indoor',
                    'rating': 0.0,
                  },
                  {
                    'name': 'Monstera',
                    'price': 'Rp45.000',
                    'category': 'Indoor',
                    'rating': 0.0,
                  },
                  {
                    'name': 'Peace Lily',
                    'price': 'Rp35.000',
                    'category': 'Indoor',
                    'rating': 0.0,
                  },
                  {
                    'name': 'Ketapang Brazil',
                    'price': 'Rp45.000',
                    'category': 'Indoor',
                    'rating': 0.0,
                  },
                  {
                    'name': 'Bonsai',
                    'price': 'Rp120.000',
                    'category': 'Indoor',
                    'rating': 0.0,
                  },
                  {
                    'name': 'Aglaonema',
                    'price': 'Rp55.000',
                    'category': 'Indoor',
                    'rating': 0.0,
                  },
                ];
                
                if (index < products.length) {
                  final product = products[index];
                  return ProductCard(
                    name: product['name'] as String,
                    price: product['price'] as String,
                    imageUrl: 'https://via.placeholder.com/150',
                    rating: product['rating'] as double,
                    category: product['category'] as String,
                  );
                }
                
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDrawer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Price Range
                const Text(
                  'Rentang Harga',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text('Rp0'),
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              RangeSlider(
                                values: _currentRangeValues,
                                max: 1000000,
                                divisions: 10,
                                activeColor: AppTheme.primaryColor,
                                labels: RangeLabels(
                                  _currentRangeValues.start.round().toString(),
                                  _currentRangeValues.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _currentRangeValues = values;
                                  });
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      controller: TextEditingController(
                                        text: _currentRangeValues.start.round().toString(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('–'),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      controller: TextEditingController(
                                        text: _currentRangeValues.end.round().toString(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const Text('Rp1.000.000'),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Categories
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCheckboxItem('Indoor'),
                _buildCheckboxItem('Outdoor'),
                _buildCheckboxItem('Mudah dirawat'),
                _buildCheckboxItem('Florikultura'),
                const SizedBox(height: 20),
                
                // Rating
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _buildRatingCheckbox(5, true),
                _buildRatingCheckbox(4, false),
                _buildRatingCheckbox(3, false),
                _buildRatingCheckbox(2, false),
                _buildRatingCheckbox(1, false),
                const SizedBox(height: 20),
                
                // Sort by
                const Text(
                  'Urutkan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: 'Popularitas',
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
                const SizedBox(height: 25),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.black87),
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
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Terapkan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCheckboxItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRatingCheckbox(int stars, bool hasUpOption) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
          const SizedBox(width: 10),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              ),
            ),
          ),
          if (hasUpOption) const Text(' & Up', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}