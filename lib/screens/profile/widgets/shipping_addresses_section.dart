import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/shipping_address.dart';
import 'package:hijauloka/screens/profile/widgets/address_card.dart';
import 'package:hijauloka/screens/profile/address_form_screen.dart';

class ShippingAddressesSection extends StatelessWidget {
  final List<ShippingAddress> addresses;
  final Function(int) onAddressDeleted;
  final Function(int) onSetPrimary;
  final VoidCallback onAddressAdded;

  const ShippingAddressesSection({
    super.key,
    required this.addresses,
    required this.onAddressDeleted,
    required this.onSetPrimary,
    required this.onAddressAdded,
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
                'Shipping Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressFormScreen(
                        onAddressAdded: onAddressAdded,
                      ),
                    ),
                  );
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (addresses.isEmpty)
            const Center(
              child: Text(
                'No shipping addresses found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...addresses.map((address) => Column(
              children: [
                AddressCard(
                  address: address,
                  onDelete: () => onAddressDeleted(address.id),
                  onSetPrimary: () => onSetPrimary(address.id),
                ),
                const SizedBox(height: 12),
              ],
            )).toList(),
        ],
      ),
    );
  }
}