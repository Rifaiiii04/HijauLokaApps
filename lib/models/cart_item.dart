class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double productPrice;
  final String productImage;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
  });

  double get totalPrice => productPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id_cart'],
      productId: json['id_product'],
      productName: json['product']['nama_product'],
      productPrice: double.parse(json['product']['harga'].toString()),
      productImage: json['product']['image_url'] ?? '',
      quantity: json['jumlah'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'quantity': quantity,
    };
  }
}