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
  
  // New fields
  final String userAddress;
  final double subtotal;
  final List<CartItem> items;

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
    this.userAddress = 'N/A',
    this.subtotal = 0.0,
    this.items = const [],
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse items if available
    List<CartItem> orderItems = [];
    double calculatedSubtotal = 0.0;
    
    if (json['items'] != null) {
      try {
        // Calculate subtotal directly from JSON data
        for (var item in json['items']) {
          double price = 0;
          int quantity = 1;
          
          if (item['price'] != null) {
            price = (item['price'] is num) ? (item['price'] as num).toDouble() : 
                  double.tryParse(item['price'].toString()) ?? 0;
          } else if (item['harga_satuan'] != null) {
            price = (item['harga_satuan'] is num) ? (item['harga_satuan'] as num).toDouble() : 
                  double.tryParse(item['harga_satuan'].toString()) ?? 0;
          }
          
          if (item['quantity'] != null) {
            quantity = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 
                      int.tryParse(item['quantity'].toString()) ?? 1;
          } else if (item['jumlah'] != null) {
            quantity = (item['jumlah'] is num) ? (item['jumlah'] as num).toInt() : 
                      int.tryParse(item['jumlah'].toString()) ?? 1;
          }
          
          calculatedSubtotal += price * quantity;
        }
        
        // Still create the CartItem objects for the items list
        orderItems = List<CartItem>.from(
          json['items'].map((item) => CartItem.fromJson(item))
        );
      } catch (e) {
        print('Error parsing items: $e');
        // Continue with empty items list
      }
    }
    
    // Use provided subtotal or calculated one
    double finalSubtotal = json['subtotal'] != null 
        ? (json['subtotal'] is num) 
            ? (json['subtotal'] as num).toDouble() 
            : double.tryParse(json['subtotal'].toString()) ?? calculatedSubtotal 
        : calculatedSubtotal;
    
    // If subtotal is still 0 but we have a total and shipping cost, calculate it
    if (finalSubtotal == 0) {
      double total = 0.0;
      double shipping = 0.0;
      
      if (json['total_harga'] != null) {
        total = (json['total_harga'] is num) 
            ? (json['total_harga'] as num).toDouble() 
            : double.tryParse(json['total_harga'].toString()) ?? 0.0;
      } else if (json['total'] != null) {
        total = (json['total'] is num) 
            ? (json['total'] as num).toDouble() 
            : double.tryParse(json['total'].toString()) ?? 0.0;
      }
      
      if (json['ongkir'] != null) {
        shipping = (json['ongkir'] is num) 
            ? (json['ongkir'] as num).toDouble() 
            : double.tryParse(json['ongkir'].toString()) ?? 0.0;
      } else if (json['shipping_cost'] != null) {
        shipping = (json['shipping_cost'] is num) 
            ? (json['shipping_cost'] as num).toDouble() 
            : double.tryParse(json['shipping_cost'].toString()) ?? 0.0;
      }
      
      if (total > 0) {
        finalSubtotal = total - shipping;
      }
    }
    
    return Order(
      id: json['id'] != null ? (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0) : 
          json['id_order'] != null ? (json['id_order'] is int ? json['id_order'] : int.tryParse(json['id_order'].toString()) ?? 0) : 0,
      
      orderId: json['order_id']?.toString() ?? json['id_order']?.toString() ?? '',
      
      userId: json['user_id'] != null ? (json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0) : 
              json['id_user'] != null ? (json['id_user'] is int ? json['id_user'] : int.tryParse(json['id_user'].toString()) ?? 0) : 0,
      
      orderDate: json['order_date']?.toString() ?? json['tgl_pemesanan']?.toString() ?? '',
      
      status: json['status']?.toString() ?? json['stts_pemesanan']?.toString() ?? '',
      
      total: json['total'] != null ? (json['total'] is num ? (json['total'] as num).toDouble() : double.tryParse(json['total'].toString()) ?? 0.0) :
             json['total_harga'] != null ? (json['total_harga'] is num ? (json['total_harga'] as num).toDouble() : double.tryParse(json['total_harga'].toString()) ?? 0.0) : 0.0,
      
      completedDate: json['completed_date']?.toString() ?? json['tgl_selesai']?.toString(),
      
      shippedDate: json['shipped_date']?.toString() ?? json['tgl_dikirim']?.toString(),
      
      cancelledDate: json['cancelled_date']?.toString() ?? json['tgl_batal']?.toString(),
      
      adminId: json['admin_id'] != null ? (json['admin_id'] is int ? json['admin_id'] : int.tryParse(json['admin_id'].toString()) ?? 0) : 
               json['id_admin'] != null ? (json['id_admin'] is int ? json['id_admin'] : int.tryParse(json['id_admin'].toString()) ?? 0) : 0,
      
      paymentStatus: json['payment_status']?.toString() ?? json['stts_pembayaran']?.toString() ?? '',
      
      paymentMethod: json['payment_method']?.toString() ?? json['metode_pembayaran']?.toString() ?? '',
      
      shippingMethod: json['shipping_method']?.toString() ?? json['kurir']?.toString() ?? '',
      
      shippingCost: json['shipping_cost'] != null ? (json['shipping_cost'] is num ? (json['shipping_cost'] as num).toDouble() : double.tryParse(json['shipping_cost'].toString()) ?? 0.0) :
                    json['ongkir'] != null ? (json['ongkir'] is num ? (json['ongkir'] as num).toDouble() : double.tryParse(json['ongkir'].toString()) ?? 0.0) : 0.0,
      
      midtransOrderId: json['midtrans_order_id']?.toString() ?? json['midtransOrderId']?.toString(),
      
      userName: json['user_name']?.toString() ?? json['userName']?.toString(),
      
      userEmail: json['user_email']?.toString() ?? json['userEmail']?.toString(),
      
      userPhone: json['user_phone']?.toString() ?? json['userPhone']?.toString(),
      
      adminName: json['admin_name']?.toString() ?? json['adminName']?.toString(),
      
      paymentUrl: json['payment_url']?.toString() ?? json['paymentUrl']?.toString(),
      
      userAddress: json['user_address']?.toString() ?? json['userAddress']?.toString() ?? 'N/A',
      
      subtotal: finalSubtotal,
      
      items: orderItems,
      
      shippingAddress: json['shipping_address'] ?? json['shippingAddress'],
    );
  }
  
  // Improved shipping address getters
  String get recipientName => 
      shippingAddress?['recipient_name']?.toString() ?? 
      userName ?? 
      'N/A';
      
  String get phone => 
      shippingAddress?['phone']?.toString() ?? 
      userPhone ?? 
      'N/A';
      
  String get address => 
      shippingAddress?['full_address']?.toString() ?? 
      shippingAddress?['address']?.toString() ?? 
      userAddress ?? 
      'N/A';
      
  String get detailAddress => 
      shippingAddress?['detail_address']?.toString() ?? 
      '';
}
