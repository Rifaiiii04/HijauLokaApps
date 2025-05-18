import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';

class PaymentMethodSection extends StatelessWidget {
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodSelected;

  const PaymentMethodSection({
    Key? key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
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
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodCard(
            'midtrans',
            'Pembayaran Online',
            'QRIS, Transfer Bank, E-Wallet, Kartu Kredit',
          ),
          const SizedBox(height: 8),
          _buildPaymentMethodCard(
            'cod',
            'Cash on Delivery (COD)',
            'Bayar di tempat saat barang diterima',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String value,
    String title,
    String description, {
    bool isEnabled = true,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selectedPaymentMethod == value && isEnabled
              ? AppTheme.primaryColor
              : Colors.grey[300]!,
          width: selectedPaymentMethod == value && isEnabled ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isEnabled
            ? () {
                onPaymentMethodSelected(value);
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: selectedPaymentMethod,
                onChanged: isEnabled
                    ? (newValue) {
                        if (newValue != null) {
                          onPaymentMethodSelected(newValue);
                        }
                      }
                    : null,
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isEnabled ? Colors.grey[600] : Colors.grey,
                      ),
                    ),
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