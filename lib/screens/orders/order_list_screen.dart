import 'package:flutter/material.dart';
import 'package:hijauloka/services/order_service.dart';
import 'package:hijauloka/screens/orders/order_detail_screen.dart';
import 'package:hijauloka/theme/app_theme.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/utils/currency_formatter.dart';

class OrderListScreen extends StatefulWidget {
  final String? initialStatus;

  const OrderListScreen({Key? key, this.initialStatus}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final List<String> _statuses = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];
  late String _selectedStatus;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Set initial status based on widget parameter
    _selectedStatus =
        widget.initialStatus != null
            ? _getStatusText(widget.initialStatus!)
            : 'Semua';
    _fetchOrders();
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Semua';
    }
  }

  String _getStatusValue(String displayStatus) {
    switch (displayStatus) {
      case 'Menunggu':
        return 'pending';
      case 'Diproses':
        return 'processing';
      case 'Dikirim':
        return 'shipped';
      case 'Selesai':
        return 'delivered';
      case 'Dibatalkan':
        return 'cancelled';
      default:
        return '';
    }
  }

  void _fetchOrders() async {
    setState(() => _isLoading = true);
    final orderService = OrderService();

    try {
      final result = await orderService.getUserOrders(
        status:
            _selectedStatus == 'Semua' ? '' : _getStatusValue(_selectedStatus),
      );

      if (result['success'] == true) {
        setState(() {
          _orders = result['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders = [];
          _isLoading = false;
        });

        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load orders'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error in _fetchOrders: $e');
      setState(() {
        _orders = [];
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading orders: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final orderService = OrderService();
    final result = await orderService.updateOrderStatus(orderId, 'dibatalkan');
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibatalkan!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal membatalkan pesanan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatusTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children:
              _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      status,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Color(0xFF4CAF50),
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = status;
                        _fetchOrders();
                      });
                    },
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    // Add null check and default values
    if (order == null) {
      return const SizedBox.shrink();
    }

    print('Order data: ${order.toString()}');

    final canCancel = order['can_cancel'] == true;
    final status = order['status']?.toString().toLowerCase() ?? '';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    // Use order_id from the database
    final orderId = order['order_id']?.toString() ?? '';

    print('Order ID extracted: $orderId');

    // Format date from tgl_pemesanan
    final orderDate =
        order['formatted_date'] ?? order['tgl_pemesanan'] ?? 'Unknown date';

    // Get status text
    final statusText = order['status_text'] ?? _getStatusDisplayText(status);

    // Map payment status
    final paymentStatus =
        order['payment_status'] ??
        (order['stts_pembayaran'] == 'lunas' ? 'Lunas' : 'Menunggu');

    // Safely convert total to double
    double total = 0;
    try {
      total =
          order['total_harga'] is num
              ? (order['total_harga'] as num).toDouble()
              : double.tryParse(order['total_harga']?.toString() ?? '0') ?? 0;
    } catch (e) {
      print('Error parsing total: $e');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          // Add debug print
          print('Navigating to order detail for ID: $orderId');

          if (orderId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order ID is missing. Cannot view details.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: orderId),
            ),
          ).then((_) {
            // Refresh orders when returning from detail screen
            _fetchOrders();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$orderId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        orderDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Payment Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payment, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Pembayaran: $paymentStatus',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              if (canCancel) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                    label: const Text('Batalkan Pesanan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _cancelOrder(orderId),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get status display text
  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildStatusTabs(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _orders.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _orders.length,
                      itemBuilder:
                          (context, index) => _buildOrderCard(_orders[index]),
                    ),
          ),
        ],
      ),
    );
  }
}
