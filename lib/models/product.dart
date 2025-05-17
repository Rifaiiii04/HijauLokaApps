class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? image;
  final double rating;
  final String category;
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
    required this.rating,
    required this.category,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['nama_product'] ?? '',
      description: json['description'] ?? json['desk_product'] ?? '',
      price: _parsePrice(json['price'] ?? json['harga'] ?? 0),
      stock: _parseStock(json['stock'] ?? json['stok'] ?? 0),
      image: json['image'] ?? json['gambar'],
      rating: _parseRating(json['rating'] ?? 0),
      category: json['category'] ?? json['kategori'] ?? 'Uncategorized',
      categoryId: json['category_id']?.toString() ?? json['id_kategori']?.toString() ?? '0',
    );
  }

  static double _parsePrice(dynamic price) {
    if (price is String) {
      return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }
    return (price ?? 0.0).toDouble();
  }

  static int _parseStock(dynamic stock) {
    if (stock is String) {
      return int.tryParse(stock) ?? 0;
    }
    return stock ?? 0;
  }

  static double _parseRating(dynamic rating) {
    if (rating is String) {
      return double.tryParse(rating) ?? 0.0;
    }
    return (rating ?? 0.0).toDouble();
  }
}