import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/utils/currency_formatter.dart';

class ShippingMethodSection extends StatelessWidget {
  final String selectedShippingMethod;
  final Function(String, double) onShippingMethodSelected;

  const ShippingMethodSection({
    Key? key,
    required this.selectedShippingMethod,
    required this.onShippingMethodSelected,
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
            'Metode Pengiriman',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildShippingMethodCard(
            'hijauloka',
            'HijauLoka Kurir',
            'Pengiriman dalam 1-2 hari kerja',
            15000,
          ),
          const SizedBox(height: 8),
          _buildShippingMethodCard(
            'jne',
            'JNE',
            'Coming Soon',
            25000,
            isEnabled: false,
          ),
          const SizedBox(height: 8),
          _buildShippingMethodCard(
            'jnt',
            'JNT',
            'Coming Soon',
            20000,
            isEnabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingMethodCard(
    String value,
    String title,
    String description,
    double cost, {
    bool isEnabled = true,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              selectedShippingMethod == value && isEnabled
                  ? AppTheme.primaryColor
                  : Colors.grey[300]!,
          width: selectedShippingMethod == value && isEnabled ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap:
            isEnabled
                ? () {
                  onShippingMethodSelected(value, cost);
                }
                : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: selectedShippingMethod,
                onChanged:
                    isEnabled
                        ? (newValue) {
                          if (newValue != null) {
                            onShippingMethodSelected(newValue, cost);
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
              Text(
                CurrencyFormatter.format(cost),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? AppTheme.primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
