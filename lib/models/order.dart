import 'package:hijauloka/models/cart_item.dart';
import 'package:intl/intl.dart';

class Order {
  final String orderId;
  final String userId;
  final String recipientName;
  final String phone;
  final String address;
  final String detailAddress;
  final String paymentMethod;
  final String shippingMethod;
  final double subtotal;
  final double shippingCost;
  final double total;
  final String status;
  final String createdAt;
  final List<CartItem> items;
  final String? paymentUrl;

  Order({
    required this.orderId,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.detailAddress,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
    this.paymentUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<CartItem> orderItems = [];
    if (json['items'] != null) {
      orderItems = List<CartItem>.from(
        (json['items'] as List).map(
          (item) => CartItem(
            id:
                int.tryParse(
                  item['id']?.toString() ??
                      item['id_product']?.toString() ??
                      '0',
                ) ??
                0,
            productId:
                int.tryParse(
                  item['product_id']?.toString() ??
                      item['id_product']?.toString() ??
                      '0',
                ) ??
                0,
            productName: item['product_name'] ?? '',
            productPrice:
                double.tryParse(item['price']?.toString() ?? '0') ?? 0,
            productImage: item['product_image'] ?? '',
            quantity: int.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
          ),
        ),
      );
    }

    // Handle potentially different field names from API vs offline mode
    final shippingAddress =
        json['shipping_address'] as Map<String, dynamic>? ?? {};

    return Order(
      orderId: json['order_id'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      recipientName:
          shippingAddress['recipient_name'] ??
          json['recipient_name'] ??
          json['user_name'] ??
          '',
      phone:
          shippingAddress['phone'] ?? json['phone'] ?? json['user_phone'] ?? '',
      address: shippingAddress['address'] ?? json['address'] ?? '',
      detailAddress:
          shippingAddress['detail_address'] ?? json['detail_address'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      shippingMethod: json['shipping_method'] ?? '',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      shippingCost:
          double.tryParse(json['shipping_cost']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      createdAt:
          json['date'] ?? json['created_at'] ?? DateTime.now().toString(),
      items: orderItems,
      paymentUrl: json['payment_url'],
    );
  }

  DateTime get orderDate => DateTime.tryParse(createdAt) ?? DateTime.now();

  String get formattedDate {
    // Check if we already have a formatted date from the API
    if (createdAt.contains('Jan') ||
        createdAt.contains('Feb') ||
        createdAt.contains('Mar') ||
        createdAt.contains('Apr') ||
        createdAt.contains('May') ||
        createdAt.contains('Jun') ||
        createdAt.contains('Jul') ||
        createdAt.contains('Aug') ||
        createdAt.contains('Sep') ||
        createdAt.contains('Oct') ||
        createdAt.contains('Nov') ||
        createdAt.contains('Dec')) {
      return createdAt;
    }

    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    return dateFormat.format(orderDate);
  }

  String get statusText {
    // If we already have a statusText from API, use it
    if (status.contains('Menunggu') ||
        status.contains('Diproses') ||
        status.contains('Dikirim') ||
        status.contains('Selesai') ||
        status.contains('Dibatalkan')) {
      return status;
    }

    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'diproses':
      case 'processing':
        return 'Diproses';
      case 'dikirim':
      case 'shipped':
        return 'Dikirim';
      case 'terkirim':
      case 'delivered':
        return 'Terkirim';
      case 'selesai':
      case 'completed':
        return 'Selesai';
      case 'dibatalkan':
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFC107'; // Amber
      case 'diproses':
      case 'processing':
        return '#2196F3'; // Blue
      case 'dikirim':
      case 'shipped':
        return '#673AB7'; // Deep Purple
      case 'terkirim':
      case 'delivered':
        return '#4CAF50'; // Green
      case 'selesai':
      case 'completed':
        return '#009688'; // Teal
      case 'dibatalkan':
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  bool get canCancel {
    return status == 'pending' || status == 'processing';
  }

  bool get canTrack {
    return status == 'shipped' || status == 'delivered';
  }

  bool get canReview {
    return status == 'delivered' || status == 'completed';
  }

  bool get needsPayment {
    return status == 'pending' &&
        paymentMethod == 'midtrans' &&
        paymentUrl != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'id_user': userId,
      'recipient_name': recipientName,
      'phone': phone,
      'address': address,
      'detail_address': detailAddress,
      'payment_method': paymentMethod,
      'shipping_method': shippingMethod,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'status': status,
      'created_at': createdAt,
      'items':
          items
              .map(
                (item) => {
                  'id_product': item.productId,
                  'quantity': item.quantity,
                  'price': item.productPrice,
                  'product_name': item.productName,
                  'product_image': item.productImage,
                },
              )
              .toList(),
      'payment_url': paymentUrl,
    };
  }
}
