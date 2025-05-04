class User {
  final int id;
  final String name;
  final String email;
  final String address;
  final String? shippingAddress;
  final String phone;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    this.shippingAddress,
    required this.phone,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id_user']),
      name: json['nama'],
      email: json['email'],
      address: json['alamat'],
      shippingAddress: json['shipping_address'],
      phone: json['no_tlp'],
      profileImage: json['profile_image'],
    );
  }
}