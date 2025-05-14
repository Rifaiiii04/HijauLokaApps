class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final double rating;
  final String image;
  final String description;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.rating,
    required this.image,
    this.description = '',
    this.stock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.tryParse(json['id_product']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      name: json['nama_product'] ?? json['name'] ?? 'Unnamed Product',
      price: double.tryParse(json['harga']?.toString() ?? json['price']?.toString() ?? '0') ?? 0,
      category: json['kategori'] ?? json['category'] ?? 'Uncategorized',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      image: json['gambar'] ?? json['image'] ?? '',
      description: json['deskripsi'] ?? json['description'] ?? '',
      stock: int.tryParse(json['stok']?.toString() ?? json['stock']?.toString() ?? '0') ?? 0,
    );
  }
}