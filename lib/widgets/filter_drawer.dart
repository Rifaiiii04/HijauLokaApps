import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/providers/filter_provider.dart';
import 'package:hijauloka/utils/currency_formatter.dart';
import 'package:provider/provider.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
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
                      _buildPriceRangeSection(context, filterProvider),
                      const SizedBox(height: 35),

                      // Categories
                      _buildSectionTitle('Kategori'),
                      const SizedBox(height: 15),
                      _buildCategoriesSection(filterProvider),
                      const SizedBox(height: 35),

                      // Rating
                      _buildSectionTitle('Rating'),
                      const SizedBox(height: 15),
                      _buildRatingSection(filterProvider),
                      const SizedBox(height: 35),

                      // Sort by
                      _buildSectionTitle('Urutkan'),
                      const SizedBox(height: 15),
                      _buildSortBySection(filterProvider),
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
                        onPressed: () {
                          filterProvider.resetFilters();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.black87, fontSize: 16),
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

  Widget _buildPriceRangeSection(
    BuildContext context,
    FilterProvider filterProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(CurrencyFormatter.format(0)),
              Text(CurrencyFormatter.format(1000000)),
            ],
          ),
          const SizedBox(height: 15),
          RangeSlider(
            values: filterProvider.priceRange,
            max: 1000000,
            divisions: 10,
            activeColor: AppTheme.primaryColor,
            labels: RangeLabels(
              filterProvider.priceRange.start.round().toString(),
              filterProvider.priceRange.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              filterProvider.setPriceRange(values);
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                  ),
                  controller: TextEditingController(
                    text: filterProvider.priceRange.start.round().toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final start = int.tryParse(value) ?? 0;
                    if (start <= filterProvider.priceRange.end) {
                      filterProvider.setPriceRange(
                        RangeValues(
                          start.toDouble(),
                          filterProvider.priceRange.end,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 15),
              const Text('–'),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                  ),
                  controller: TextEditingController(
                    text: filterProvider.priceRange.end.round().toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final end = int.tryParse(value) ?? 1000000;
                    if (end >= filterProvider.priceRange.start) {
                      filterProvider.setPriceRange(
                        RangeValues(
                          filterProvider.priceRange.start,
                          end.toDouble(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(FilterProvider filterProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            filterProvider.selectedCategories.keys.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: filterProvider.selectedCategories[category],
                        onChanged: (bool? value) {
                          filterProvider.toggleCategory(
                            category,
                            value ?? false,
                          );
                        },
                        activeColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(category, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRatingSection(FilterProvider filterProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            [5, 4, 3, 2, 1].map((rating) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: filterProvider.selectedRatings[rating],
                        onChanged: (bool? value) {
                          filterProvider.toggleRating(rating, value ?? false);
                        },
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
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    if (rating == 5)
                      const Text(' & Up', style: TextStyle(fontSize: 15)),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSortBySection(FilterProvider filterProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filterProvider.sortBy,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Popularitas', child: Text('Popularitas')),
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
          onChanged: (value) {
            if (value != null) {
              filterProvider.setSortBy(value);
            }
          },
        ),
      ),
    );
  }
}
