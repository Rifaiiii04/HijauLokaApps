import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';

class AddAddressDialog extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  const AddAddressDialog({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _detailController = TextEditingController();
  bool _isPrimary = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _labelController.dispose();
    _addressController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Alamat Baru'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Penerima'),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(labelText: 'Label Alamat (Rumah, Kantor, dll)'),
                validator: (value) => value!.isEmpty ? 'Label alamat tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rtController,
                      decoration: const InputDecoration(labelText: 'RT'),
                      validator: (value) => value!.isEmpty ? 'RT tidak boleh kosong' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _rwController,
                      decoration: const InputDecoration(labelText: 'RW'),
                      validator: (value) => value!.isEmpty ? 'RW tidak boleh kosong' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _houseNumberController,
                decoration: const InputDecoration(labelText: 'Nomor Rumah'),
                validator: (value) => value!.isEmpty ? 'Nomor rumah tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Kode Pos'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Kode pos tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: 'Detail Alamat (Patokan)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Jadikan Alamat Utama'),
                value: _isPrimary,
                onChanged: (value) {
                  setState(() {
                    _isPrimary = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'recipient_name': _nameController.text,
                'phone': _phoneController.text,
                'address_label': _labelController.text,
                'address': _addressController.text,
                'rt': _rtController.text,
                'rw': _rwController.text,
                'house_number': _houseNumberController.text,
                'postal_code': _postalCodeController.text,
                'detail_address': _detailController.text,
                'is_primary': _isPrimary ? '1' : '0',
              });
              Navigator.of(context).pop();
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}