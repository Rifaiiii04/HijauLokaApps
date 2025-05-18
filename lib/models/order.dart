import 'package:hijauloka/models/cart_item.dart';
import 'package:intl/intl.dart';

class Order {
  final int id;
  final String orderId;
  final int userId;
  final String orderDate;  // tgl_pemesanan
  final String status;     // stts_pemesanan
  final double total;      // total_harga
  final String? completedDate; // tgl_selesai
  final String? shippedDate;   // tgl_dikirim
  final String? cancelledDate;  // tgl_batal
  final int adminId;
  final String paymentStatus;   // stts_pembayaran
  final String paymentMethod;   // metode_pembayaran
  final String shippingMethod;  // kurir
  final double shippingCost;    // ongkir
  final String? midtransOrderId;
  
  // Additional fields for UI
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? adminName;
  final String? paymentUrl;
  final Map<String, dynamic>? shippingAddress;

  Order({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.orderDate,
    required this.status,
    required this.total,
    this.completedDate,
    this.shippedDate,
    this.cancelledDate,
    required this.adminId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.shippingCost,
    this.midtransOrderId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.adminName,
    this.paymentUrl,
    this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id_order'] ?? 0,
      orderId: json['order_id'] ?? json['id_order']?.toString() ?? '',
      userId: json['id_user'] ?? 0,
      orderDate: json['tgl_pemesanan'] ?? '',
      status: json['stts_pemesanan'] ?? json['status'] ?? '',
      total: (json['total_harga'] is num) 
          ? (json['total_harga'] as num).toDouble() 
          : double.tryParse(json['total_harga']?.toString() ?? '0') ?? 0,
      completedDate: json['tgl_selesai'],
      shippedDate: json['tgl_dikirim'],
      cancelledDate: json['tgl_batal'],
      adminId: json['id_admin'] ?? 0,
      paymentStatus: json['stts_pembayaran'] ?? '',
      paymentMethod: json['metode_pembayaran'] ?? '',
      shippingMethod: json['kurir'] ?? '',
      shippingCost: (json['ongkir'] is num) 
          ? (json['ongkir'] as num).toDouble() 
          : double.tryParse(json['ongkir']?.toString() ?? '0') ?? 0,
      midtransOrderId: json['midtrans_order_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
      adminName: json['admin_name'],
      paymentUrl: json['payment_url'],
      shippingAddress: json['shipping_address'],
    );
  }
  
  // Helper getters for UI
  bool get needsPayment => paymentStatus == 'belum_dibayar';
  bool get canCancel => status == 'pending' || status == 'diproses';
  
  String get statusText => _getStatusText(status);
  String get statusColor => _getStatusColor(status);
  
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Menunggu Pembayaran';
      case 'diproses': return 'Diproses';
      case 'dikirim': return 'Dikirim';
      case 'selesai': return 'Diterima';
      case 'dibatalkan': return 'Dibatalkan';
      default: return 'Unknown';
    }
  }
  
  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return '#FFC107';  // Orange
      case 'diproses': return '#2196F3'; // Blue
      case 'dikirim': return '#3F51B5';  // Indigo
      case 'selesai': return '#4CAF50';  // Green
      case 'dibatalkan': return '#F44336'; // Red
      default: return '#9E9E9E';  // Grey
    }
  }
  
  // Shipping address getters
  String get recipientName => shippingAddress?['recipient_name'] ?? 'N/A';
  String get phone => shippingAddress?['phone'] ?? 'N/A';
  String get address => shippingAddress?['full_address'] ?? 
                        shippingAddress?['address'] ?? 'N/A';
  String get detailAddress => shippingAddress?['detail_address'] ?? '';
}
