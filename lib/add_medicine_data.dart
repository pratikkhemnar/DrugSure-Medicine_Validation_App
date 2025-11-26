import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final serialController = TextEditingController();
  final upicController = TextEditingController();
  final genericController = TextEditingController();
  final brandController = TextEditingController();
  final manufacturerController = TextEditingController();
  final batchController = TextEditingController();
  final mfgDateController = TextEditingController();
  final expDateController = TextEditingController();
  final licenseController = TextEditingController();

  bool loading = false;

  Future<void> saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final data = {
      "serialNumber": serialController.text.trim(),
      "upic": upicController.text.trim(),
      "genericName": genericController.text.trim(),
      "brandName": brandController.text.trim(),
      "manufacturer": manufacturerController.text.trim(),
      "batchNumber": batchController.text.trim(),
      "manufactureDate": mfgDateController.text.trim(),
      "expiryDate": expDateController.text.trim(),
      "licenseNo": licenseController.text.trim(),

      // LOWERCASE fields for searching
      "brandNameLower": brandController.text.trim().toLowerCase(),
      "genericNameLower": genericController.text.trim().toLowerCase(),
      "batchNumberLower": batchController.text.trim().toLowerCase(),
    };

    try {
      await FirebaseFirestore.instance.collection("medicines").add(data);

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Medicine Added Successfully!")),
      );

      // Clear form
      serialController.clear();
      upicController.clear();
      genericController.clear();
      brandController.clear();
      manufacturerController.clear();
      batchController.clear();
      mfgDateController.clear();
      expDateController.clear();
      licenseController.clear();

    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    serialController.dispose();
    upicController.dispose();
    genericController.dispose();
    brandController.dispose();
    manufacturerController.dispose();
    batchController.dispose();
    mfgDateController.dispose();
    expDateController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Required field" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Medicine Info")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Serial Number", serialController),
              _buildTextField("UPIC Code", upicController),
              _buildTextField("Generic Name", genericController),
              _buildTextField("Brand Name", brandController),
              _buildTextField("Manufacturer", manufacturerController, maxLines: 2),
              _buildTextField("Batch Number", batchController),
              _buildTextField("Manufacture Date (e.g., Jun-2025)", mfgDateController),
              _buildTextField("Expiry Date (e.g., May-2027)", expDateController),
              _buildTextField("License Number", licenseController),
              SizedBox(height: 20),

              loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: saveMedicine,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: Colors.teal,
                ),
                child: Text("Save Medicine",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
