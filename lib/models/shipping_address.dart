class ShippingAddress {
  final int id;
  final int userId;
  final String recipientName;
  final String phone;
  final String? addressLabel;
  final String address;
  final String? rt;
  final String? rw;
  final String? houseNumber;
  final String? postalCode;
  final String? detailAddress;
  final bool isPrimary;
  final String createdAt;

  ShippingAddress({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phone,
    this.addressLabel,
    required this.address,
    this.rt,
    this.rw,
    this.houseNumber,
    this.postalCode,
    this.detailAddress,
    required this.isPrimary,
    required this.createdAt,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: int.parse(json['id']),
      userId: int.parse(json['user_id']),
      recipientName: json['recipient_name'] ?? '',
      phone: json['phone'] ?? '',
      addressLabel: json['address_label'],
      address: json['address'] ?? '',
      rt: json['rt'],
      rw: json['rw'],
      houseNumber: json['house_number'],
      postalCode: json['postal_code'],
      detailAddress: json['detail_address'],
      isPrimary: json['is_primary'] == '1',
      createdAt: json['created_at'] ?? '',
    );
  }
}