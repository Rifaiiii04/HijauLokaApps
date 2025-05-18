import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/shipping_address.dart';
import 'package:hijauloka/services/address_service.dart';

class AddressFormScreen extends StatefulWidget {
  final VoidCallback onAddressAdded;
  final ShippingAddress? addressToEdit;

  const AddressFormScreen({
    super.key,
    required this.onAddressAdded,
    this.addressToEdit,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressService = AddressService();

  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLabelController = TextEditingController();
  final _addressController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _detailAddressController = TextEditingController();

  bool _isPrimary = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // If editing an existing address, populate the form
    if (widget.addressToEdit != null) {
      _recipientNameController.text = widget.addressToEdit!.recipientName;
      _phoneController.text = widget.addressToEdit!.phone;
      _addressLabelController.text = widget.addressToEdit!.addressLabel ?? '';
      _addressController.text = widget.addressToEdit!.address;
      _rtController.text = widget.addressToEdit!.rt ?? '';
      _rwController.text = widget.addressToEdit!.rw ?? '';
      _houseNumberController.text = widget.addressToEdit!.houseNumber ?? '';
      _postalCodeController.text = widget.addressToEdit!.postalCode ?? '';
      _detailAddressController.text = widget.addressToEdit!.detailAddress ?? '';
      _isPrimary = widget.addressToEdit!.isPrimary;
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressLabelController.dispose();
    _addressController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final address = ShippingAddress(
        id: widget.addressToEdit?.id ?? 0,
        recipientName: _recipientNameController.text,
        phone: _phoneController.text,
        addressLabel:
            _addressLabelController.text.isEmpty
                ? ''
                : _addressLabelController.text,
        address: _addressController.text,
        rt: _rtController.text.isEmpty ? '' : _rtController.text,
        rw: _rwController.text.isEmpty ? '' : _rwController.text,
        houseNumber:
            _houseNumberController.text.isEmpty
                ? ''
                : _houseNumberController.text,
        postalCode:
            _postalCodeController.text.isEmpty
                ? ''
                : _postalCodeController.text,
        detailAddress:
            _detailAddressController.text.isEmpty
                ? ''
                : _detailAddressController.text,
        isPrimary: _isPrimary,
        distance: widget.addressToEdit?.distance ?? 0,
      );

      Map<String, dynamic> result;
      if (widget.addressToEdit == null) {
        // Add new address
        result = await _addressService.addShippingAddress(address);
      } else {
        // Update existing address
        result = await _addressService.updateShippingAddress(address);
      }

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        widget.onAddressAdded();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.addressToEdit == null
                  ? 'Address added successfully'
                  : 'Address updated successfully',
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to save address'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Alamat Pengiriman'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Label Alamat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressLabelController,
                        decoration: InputDecoration(
                          hintText: 'Rumah, Kantor, dll',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Nomor Telepon',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Nama Penerima',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _recipientNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama penerima tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Alamat Lengkap',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                hintText: 'Masukkan alamat lengkap',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Alamat tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: Implement location picker
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RT',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _rtController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RW',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _rwController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'No. Rumah',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _houseNumberController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Kode Pos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Detail Tambahan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _detailAddressController,
                        decoration: InputDecoration(
                          hintText:
                              'Patokan, warna rumah, atau instruksi khusus lainnya',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text('Jadikan alamat utama'),
                        value: _isPrimary,
                        onChanged: (value) {
                          setState(() {
                            _isPrimary = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.addressToEdit == null
                                ? 'Simpan Alamat'
                                : 'Perbarui Alamat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
