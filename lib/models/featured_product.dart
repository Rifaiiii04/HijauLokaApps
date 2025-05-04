class FeaturedProduct {
  final int idProduct;
  final String namaProduct;
  final String deskProduct;
  final double harga;
  final int stok;
  final int? idKategori;
  final String gambar;
  final double? rating;
  final int idAdmin;
  final String? caraRawatVideo;

  FeaturedProduct({
    required this.idProduct,
    required this.namaProduct,
    required this.deskProduct,
    required this.harga,
    required this.stok,
    required this.idKategori,
    required this.gambar,
    required this.rating,
    required this.idAdmin,
    required this.caraRawatVideo,
  });

  factory FeaturedProduct.fromJson(Map<String, dynamic> json) {
    return FeaturedProduct(
      idProduct: int.parse(json['id_product'].toString()),
      namaProduct: json['nama_product'],
      deskProduct: json['desk_product'],
      harga: double.parse(json['harga'].toString()),
      stok: int.parse(json['stok'].toString()),
      idKategori:
          json['id_kategori'] != null
              ? int.tryParse(json['id_kategori'].toString())
              : null,
      gambar: json['gambar'],
      rating:
          json['rating'] != null
              ? double.tryParse(json['rating'].toString())
              : null,
      idAdmin: int.parse(json['id_admin'].toString()),
      caraRawatVideo: json['cara_rawat_video'],
    );
  }
}
