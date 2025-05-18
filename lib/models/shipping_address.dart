class ShippingAddress {
  final int id;
  final String recipientName;
  final String phone;
  final String addressLabel;
  final String address;
  final String rt;
  final String rw;
  final String houseNumber;
  final String postalCode;
  final String detailAddress;
  final bool isPrimary;
  final double distance;

  ShippingAddress({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.addressLabel,
    required this.address,
    required this.rt,
    required this.rw,
    required this.houseNumber,
    required this.postalCode,
    required this.detailAddress,
    required this.isPrimary,
    required this.distance,
  });

  String get fullAddress {
    return '$address, RT $rt/RW $rw, No. $houseNumber, $postalCode';
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: int.parse(json['id'].toString()),
      recipientName: json['recipient_name'] ?? '',
      phone: json['phone'] ?? '',
      addressLabel: json['address_label'] ?? '',
      address: json['address'] ?? '',
      rt: json['rt'] ?? '',
      rw: json['rw'] ?? '',
      houseNumber: json['house_number'] ?? '',
      postalCode: json['postal_code'] ?? '',
      detailAddress: json['detail_address'] ?? '',
      isPrimary: json['is_primary'] == '1' || json['is_primary'] == 1,
      distance: double.tryParse(json['jarak']?.toString() ?? '0') ?? 0,
    );
  }
}