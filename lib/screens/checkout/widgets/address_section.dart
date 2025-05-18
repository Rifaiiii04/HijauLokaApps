import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/shipping_address.dart';

class AddressSection extends StatelessWidget {
  final List<ShippingAddress> addresses;
  final ShippingAddress? selectedAddress;
  final Function(ShippingAddress) onAddressSelected;
  final VoidCallback onAddAddressPressed;

  const AddressSection({
    Key? key,
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddAddressPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alamat Pengiriman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (addresses.isEmpty)
            Center(
              child: Column(
                children: [
                  const Text('Belum ada alamat tersimpan'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onAddAddressPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Tambah Alamat'),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ...addresses.map((address) => _buildAddressCard(address)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onAddAddressPressed,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Alamat Baru'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(ShippingAddress address) {
    final isSelected = selectedAddress?.id == address.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          onAddressSelected(address);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<int?>(
                value: address.id,
                groupValue: selectedAddress?.id,
                onChanged: (value) {
                  onAddressSelected(address);
                },
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.recipientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (address.isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Utama',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(address.phone),
                    const SizedBox(height: 4),
                    Text(address.fullAddress),
                    if (address.detailAddress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Catatan: ${address.detailAddress}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}