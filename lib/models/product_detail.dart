class ProductDetail {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String image;
  final double rating;
  final String caraRawatVideo;
  final List<String> images;
  final List<Review> reviews;
  final double avgRating;
  final int countRating;

  ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.image,
    required this.rating,
    required this.caraRawatVideo,
    required this.images,
    required this.reviews,
    required this.avgRating,
    required this.countRating,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    try {
      imagesList = List<String>.from(json['images'] ?? []);
    } catch (e) {
      print('Error parsing images: $e');
    }
    
    List<Review> reviewsList = [];
    try {
      reviewsList = (json['reviews'] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList();
    } catch (e) {
      print('Error parsing reviews: $e');
    }
    
    return ProductDetail(
      id: int.parse(json['product']['id_product'] ?? '0'),
      name: json['product']['nama_product'] ?? 'Unknown Product',
      description: json['product']['desk_product'] ?? '',
      price: double.tryParse(json['product']['harga']?.toString() ?? '0') ?? 0,
      stock: int.tryParse(json['product']['stok']?.toString() ?? '0') ?? 0,
      category: json['product']['nama_kategori'] ?? '',
      image: json['product']['gambar'] ?? '',
      rating: double.tryParse(json['product']['rating']?.toString() ?? '0') ?? 0,
      caraRawatVideo: json['product']['cara_rawat_video'] ?? '',
      images: imagesList,
      reviews: reviewsList,
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0,
      countRating: json['count_rating'] ?? 0,
    );
  }
}

class Review {
  final String namaUser;
  final int rating;
  final String ulasan;

  Review({required this.namaUser, required this.rating, required this.ulasan});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      namaUser: json['nama_user'] ?? '',
      rating: int.tryParse(json['rating'].toString()) ?? 0,
      ulasan: json['ulasan'] ?? '',
    );
  }
}
