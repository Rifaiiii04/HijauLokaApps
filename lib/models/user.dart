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
    // Helper function untuk konversi ke int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    // Helper function untuk konversi ke string
    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return User(
      id: parseId(json['id_user']),
      name: parseString(json['nama']),
      email: parseString(json['email']),
      address: parseString(json['alamat']),
      shippingAddress: json['shipping_address']?.toString(),
      phone: parseString(json['no_tlp']),
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': id,
      'nama': name,
      'email': email,
      'alamat': address,
      'shipping_address': shippingAddress,
      'no_tlp': phone,
      'profile_image': profileImage,
    };
  }
}
