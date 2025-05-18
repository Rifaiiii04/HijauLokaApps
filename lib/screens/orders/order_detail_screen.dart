import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:hijauloka/models/order.dart';
import 'package:hijauloka/models/cart_item.dart';
import 'package:hijauloka/services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Order? _order;
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _orderService.getOrderDetails(widget.orderId);

      if (result['success'] == true) {
        setState(() {
          _order = Order.fromJson(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load order details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPaymentUrl() async {
    if (_order?.paymentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment URL not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri url = Uri.parse(_order!.paymentUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch payment URL: ${_order!.paymentUrl}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(title: 'Detail Pesanan'),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadOrderDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStatusCard(),
                    const SizedBox(height: 16),
                    _buildOrderInfoCard(),
                    const SizedBox(height: 16),
                    _buildShippingAddressCard(),
                    const SizedBox(height: 16),
                    _buildOrderItemsCard(),
                    const SizedBox(height: 16),
                    _buildPaymentDetailsCard(),
                  ],
                ),
              ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(_order!.status),
                  color: Color(
                    int.parse('0xFF${_order!.statusColor.substring(1)}'),
                  ),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _order!.statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      int.parse('0xFF${_order!.statusColor.substring(1)}'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(_order!.status),
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_order!.needsPayment) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _launchPaymentUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Bayar Sekarang'),
                ),
              ),
            ],
            if (_order!.canCancel) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement cancel order
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Batalkan Pesanan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pesanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID Pesanan', _order!.orderId),
            const Divider(height: 16),
            _buildInfoRow('Tanggal Pemesanan', _order!.formattedDate),
            const Divider(height: 16),
            _buildInfoRow(
              'Metode Pengiriman',
              _getShippingMethodText(_order!.shippingMethod),
            ),
            const Divider(height: 16),
            _buildInfoRow(
              'Metode Pembayaran',
              _getPaymentMethodText(_order!.paymentMethod),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _order!.recipientName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_order!.phone),
            const SizedBox(height: 4),
            Text(_order!.address),
            if (_order!.detailAddress.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Catatan: ${_order!.detailAddress}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (var item in _order!.items) _buildOrderItemRow(item),
            const Divider(height: 32),
            _buildPriceRow('Subtotal', _order!.subtotal),
            _buildPriceRow('Biaya Pengiriman', _order!.shippingCost),
            const SizedBox(height: 8),
            _buildPriceRow('Total', _order!.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Metode Pembayaran',
              _getPaymentMethodText(_order!.paymentMethod),
            ),
            const Divider(height: 16),
            _buildInfoRow(
              'Status Pembayaran',
              _order!.needsPayment ? 'Menunggu Pembayaran' : 'Lunas',
            ),
            if (_order!.paymentMethod == 'cod') ...[
              const Divider(height: 16),
              _buildInfoRow(
                'Instruksi',
                'Silakan siapkan uang tunai sebesar Rp ${_order!.total.toStringAsFixed(0)} untuk dibayarkan kepada kurir ketika pesanan tiba.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrderItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item.productPrice.toStringAsFixed(0)} x ${item.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${(item.productPrice * item.quantity).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Diterima';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.payment;
      case 'processing':
        return Icons.inventory;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Silakan selesaikan pembayaran untuk melanjutkan proses pesanan Anda.';
      case 'processing':
        return 'Pesanan Anda sedang diproses dan akan segera dikirim.';
      case 'shipped':
        return 'Pesanan Anda sedang dalam perjalanan ke alamat pengiriman.';
      case 'delivered':
        return 'Pesanan Anda telah diterima. Terima kasih telah berbelanja di HijauLoka!';
      case 'cancelled':
        return 'Pesanan Anda telah dibatalkan.';
      default:
        return '';
    }
  }

  String _getShippingMethodText(String method) {
    switch (method) {
      case 'hijauloka':
        return 'HijauLoka Kurir';
      case 'jne':
        return 'JNE';
      case 'jnt':
        return 'J&T';
      default:
        return method;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'midtrans':
        return 'Pembayaran Online';
      case 'cod':
        return 'Cash on Delivery (COD)';
      default:
        return method;
    }
  }
}

class OrderDetail {
  final String orderId;
  final DateTime orderDate;
  final String status;
  final String recipientName;
  final String phone;
  final String address;
  final String detailAddress;
  final String shippingMethod;
  final String paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double total;
  final List<OrderItem> items;
  final String? paymentUrl;

  OrderDetail({
    required this.orderId,
    required this.orderDate,
    required this.status,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.detailAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.items,
    this.paymentUrl,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json['order_id'] ?? '',
      orderDate: DateTime.parse(
        json['created_at'] ?? DateTime.now().toString(),
      ),
      status: json['status'] ?? 'pending',
      recipientName: json['recipient_name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      detailAddress: json['detail_address'] ?? '',
      shippingMethod: json['shipping_method'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
      shippingCost: double.parse(json['shipping_cost']?.toString() ?? '0'),
      total: double.parse(json['total']?.toString() ?? '0'),
      paymentUrl: json['payment_url'],
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: int.parse(json['product_id']?.toString() ?? '0'),
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: double.parse(json['price']?.toString() ?? '0'),
      quantity: int.parse(json['quantity']?.toString() ?? '0'),
    );
  }
}
