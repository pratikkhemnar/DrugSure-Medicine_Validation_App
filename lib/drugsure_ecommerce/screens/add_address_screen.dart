// ============================================================
// FILE: screens/add_address_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import '../models/order_model.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? existingAddress;
  const AddAddressScreen({super.key, this.existingAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  String _addressType = 'Home';
  bool _isDefault = false;
  bool _isSaving = false;

  final List<String> _addressTypes = ['Home', 'Work', 'Other'];

  // Indian states list
  final List<String> _states = [
    'Andhra Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa', 'Gujarat',
    'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Delhi', 'Jammu & Kashmir', 'Ladakh',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingAddress != null) {
      final a = widget.existingAddress!;
      _nameCtrl.text = a.fullName;
      _phoneCtrl.text = a.phone;
      _line1Ctrl.text = a.addressLine1;
      _line2Ctrl.text = a.addressLine2;
      _cityCtrl.text = a.city;
      _stateCtrl.text = a.state;
      _pincodeCtrl.text = a.pincode;
      _addressType = a.addressType;
      _isDefault = a.isDefault;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 500)); // simulate save

    final address = Address(
      id: widget.existingAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2: _line2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      addressType: _addressType,
      isDefault: _isDefault,
    );

    if (mounted) Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          widget.existingAddress == null ? 'Add New Address' : 'Edit Address',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Type
              const Text('Address Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: _addressTypes.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _addressType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _addressType == type
                            ? const Color(0xFF1565C0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _addressType == type
                              ? const Color(0xFF1565C0)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(type,
                          style: TextStyle(
                            color: _addressType == type ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),

              _buildCard([
                _buildField('Full Name', _nameCtrl, Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Enter full name' : null),
                const SizedBox(height: 16),
                _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v!.isEmpty) return 'Enter phone number';
                      if (v.length != 10) return 'Enter valid 10-digit number';
                      return null;
                    }),
              ]),
              const SizedBox(height: 16),

              _buildCard([
                _buildField('Address Line 1', _line1Ctrl, Icons.home_outlined,
                    hint: 'House/Flat No., Building Name',
                    validator: (v) => v!.isEmpty ? 'Enter address' : null),
                const SizedBox(height: 16),
                _buildField('Address Line 2', _line2Ctrl, Icons.location_on_outlined,
                    hint: 'Street, Area, Landmark (optional)',
                    isRequired: false),
                const SizedBox(height: 16),
                _buildField('City', _cityCtrl, Icons.location_city,
                    validator: (v) => v!.isEmpty ? 'Enter city' : null),
                const SizedBox(height: 16),
                // State dropdown
                DropdownButtonFormField<String>(
                  value: _stateCtrl.text.isNotEmpty ? _stateCtrl.text : null,
                  decoration: _inputDecoration('State', Icons.map_outlined),
                  items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => _stateCtrl.text = v ?? '',
                  validator: (v) => (v == null || v.isEmpty) ? 'Select state' : null,
                ),
                const SizedBox(height: 16),
                _buildField('Pincode', _pincodeCtrl, Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Enter pincode';
                      if (v.length != 6) return 'Enter valid 6-digit pincode';
                      return null;
                    }),
              ]),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: SwitchListTile(
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                  title: const Text('Set as default address',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Use this address by default'),
                  activeColor: const Color(0xFF1565C0),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Address',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon).copyWith(hintText: hint),
      validator: isRequired
          ? (validator ?? (v) => v!.isEmpty ? 'Required' : null)
          : null,
    );
  }
}
