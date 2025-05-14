import 'package:flutter/material.dart';
import 'package:hijauloka/models/product.dart';

class FilterProvider extends ChangeNotifier {
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 1000000);
  String _searchQuery = '';
  String _sortBy = 'Popularitas';
  Map<String, bool> _selectedCategories = {
    'Indoor': false,
    'Outdoor': false,
    'Mudah dirawat': false,
    'Florikultura': false,
  };
  Map<int, bool> _selectedRatings = {
    5: false,
    4: false,
    3: false,
    2: false,
    1: false,
  };

  // Getters
  RangeValues get priceRange => _priceRange;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  Map<String, bool> get selectedCategories => _selectedCategories;
  Map<int, bool> get selectedRatings => _selectedRatings;

  // Setters
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void toggleCategory(String category, bool value) {
    _selectedCategories[category] = value;
    notifyListeners();
  }

  void toggleRating(int rating, bool value) {
    _selectedRatings[rating] = value;
    notifyListeners();
  }

  // Reset all filters
  void resetFilters() {
    _priceRange = const RangeValues(0, 1000000);
    _searchQuery = '';
    _sortBy = 'Popularitas';
    
    for (var key in _selectedCategories.keys) {
      _selectedCategories[key] = false;
    }
    
    for (var key in _selectedRatings.keys) {
      _selectedRatings[key] = false;
    }
    
    notifyListeners();
  }

  // Apply filters to product list
  List<Product> applyFilters(List<Product> products) {
    if (products.isEmpty) return [];
    
    var filteredProducts = products.where((product) {
      // Search filter
      final bool matchesSearch = _searchQuery.isEmpty || 
                              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                              product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Price filter
      final bool matchesPrice = product.price >= _priceRange.start && 
                             product.price <= _priceRange.end;
      
      // Category filter
      bool matchesCategory = true;
      if (_selectedCategories.values.any((selected) => selected)) {
        matchesCategory = _selectedCategories.entries
            .where((entry) => entry.value)
            .any((entry) => product.category.contains(entry.key));
      }
      
      // Rating filter
      bool matchesRating = true;
      if (_selectedRatings.values.any((selected) => selected)) {
        matchesRating = _selectedRatings.entries
            .where((entry) => entry.value)
            .any((entry) => product.rating >= entry.key);
      }
      
      return matchesSearch && matchesPrice && matchesCategory && matchesRating;
    }).toList();
    
    // Apply sorting
    switch (_sortBy) {
      case 'Harga Terendah':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Harga Tertinggi':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Rating Tertinggi':
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Popularitas':
      default:
        // Assume products are already sorted by popularity from the API
        break;
    }
    
    return filteredProducts;
  }
}