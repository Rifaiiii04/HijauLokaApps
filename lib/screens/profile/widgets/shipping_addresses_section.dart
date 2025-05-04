import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/shipping_address.dart';
import 'package:hijauloka/screens/profile/widgets/address_card.dart';
import 'package:hijauloka/screens/profile/address_form_screen.dart';
import 'package:hijauloka/services/address_service.dart';

class ShippingAddressesSection extends StatefulWidget {
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
  State<ShippingAddressesSection> createState() => _ShippingAddressesSectionState();
}

class _ShippingAddressesSectionState extends State<ShippingAddressesSection> {
  late List<ShippingAddress> _addresses;
  final AddressService _addressService = AddressService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addresses = widget.addresses;
  }

  @override
  void didUpdateWidget(ShippingAddressesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.addresses != oldWidget.addresses) {
      setState(() {
        _addresses = widget.addresses;
      });
    }
  }

  Future<void> _refreshAddresses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final addresses = await _addressService.getShippingAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error refreshing addresses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressFormScreen(
                        onAddressAdded: widget.onAddressAdded,
                      ),
                    ),
                  );
                  
                  if (result == true) {
                    // Address was added, refresh the list
                    _refreshAddresses();
                    widget.onAddressAdded();
                  }
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_addresses.isEmpty)
            const Center(
              child: Text(
                'No shipping addresses found',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...(_addresses.map((address) => Column(
              children: [
                AddressCard(
                  address: address,
                  onDelete: () async {
                    await widget.onAddressDeleted(address.id);
                    _refreshAddresses();
                  },
                  onSetPrimary: () async {
                    await widget.onSetPrimary(address.id);
                    _refreshAddresses();
                  },
                ),
                const SizedBox(height: 12),
              ],
            )).toList()),
        ],
      ),
    );
  }
}