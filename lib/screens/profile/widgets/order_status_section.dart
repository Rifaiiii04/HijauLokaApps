import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/screens/orders/order_list_screen.dart';

class OrderStatusSection extends StatelessWidget {
  final Map<String, int> orderCounts;

  const OrderStatusSection({
    super.key,
    this.orderCounts = const {
      'pending': 0,
      'processing': 0,
      'shipped': 0,
      'delivered': 0,
    },
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pesanan Saat Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderListScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(
                context,
                'Menunggu',
                orderCounts['pending']?.toString() ?? '0',
                Icons.access_time,
                Colors.orange,
                'pending',
              ),
              _buildOrderStatusItem(
                context,
                'Diproses',
                orderCounts['processing']?.toString() ?? '0',
                Icons.inventory,
                Colors.blue,
                'processing',
              ),
              _buildOrderStatusItem(
                context,
                'Dikirim',
                orderCounts['shipped']?.toString() ?? '0',
                Icons.local_shipping,
                Colors.indigo,
                'shipped',
              ),
              _buildOrderStatusItem(
                context,
                'Selesai',
                orderCounts['delivered']?.toString() ?? '0',
                Icons.check_circle,
                Colors.green,
                'delivered',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
    String status,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderListScreen(initialStatus: status),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
