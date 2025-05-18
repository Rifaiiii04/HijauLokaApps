class FeaturedProduct {
  final String? id_product;
  final String? nama_product; // Changed from namaProduct to match API
  final double? harga;
  final String? desk_product; // Changed from deskripsi to match API
  final String? gambar;
  final String? nama_kategori; // Changed from kategori to match API
  final double? rating;
  final int? stok;
  final String? id_kategori; // Added missing field

  FeaturedProduct({
    this.id_product,
    this.nama_product,
    this.harga,
    this.desk_product,
    this.gambar,
    this.nama_kategori,
    this.rating,
    this.stok,
    this.id_kategori,
  });

  factory FeaturedProduct.fromJson(Map<String, dynamic> json) {
    return FeaturedProduct(
      id_product: json['id_product'],
      nama_product: json['nama_product'],
      harga:
          json['harga'] != null
              ? double.tryParse(json['harga'].toString()) ?? 0.0
              : 0.0,
      desk_product: json['desk_product'],
      gambar: json['gambar'],
      nama_kategori: json['nama_kategori'],
      rating:
          json['rating'] != null
              ? double.tryParse(json['rating'].toString()) ?? 0.0
              : 0.0,
      stok: json['stok'] != null ? int.tryParse(json['stok'].toString()) : 0,
      id_kategori: json['id_kategori'],
    );
  }
}
