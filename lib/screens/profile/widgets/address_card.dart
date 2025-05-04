import 'package:flutter/material.dart';
import 'package:hijauloka/models/shipping_address.dart';

class AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;

  const AddressCard({
    super.key,
    required this.address,
    required this.onDelete,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.recipientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (address.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Primary',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            address.phone,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatAddress(address),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.detailAddress ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to edit address screen
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                  ),
                ),
              ),
              if (!address.isPrimary) ...[
                TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Address'),
                        content: const Text('Are you sure you want to delete this address?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      onDelete();
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSetPrimary,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(100, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Set as Primary',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatAddress(ShippingAddress address) {
    final parts = <String>[];
    
    if (address.address.isNotEmpty) {
      parts.add(address.address);
    }
    
    if (address.rt != null && address.rt!.isNotEmpty) {
      parts.add('RT ${address.rt}');
    }
    
    if (address.rw != null && address.rw!.isNotEmpty) {
      parts.add('RW ${address.rw}');
    }
    
    if (address.houseNumber != null && address.houseNumber!.isNotEmpty) {
      parts.add('No. ${address.houseNumber}');
    }
    
    if (address.postalCode != null && address.postalCode!.isNotEmpty) {
      parts.add('${address.postalCode}');
    }
    
    return parts.join(', ');
  }
}