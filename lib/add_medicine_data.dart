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

  // Replaced validateController with a Dropdown variable
  String? selectedStatus;
  final List<String> statusOptions = ["Genuine", "Banned", "Fake"];

  bool loading = false;

  Future<void> saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a Verification Result status")),
      );
      return;
    }

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
      "result": selectedStatus, // Store the dropdown value

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
      setState(() {
        selectedStatus = null;
      });

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Product Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              SizedBox(height: 10),

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
              Text("Verification Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              SizedBox(height: 10),

              // Dropdown for Status
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: "Select Result Status",
                  border: OutlineInputBorder(),
                ),
                items: statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: status == "Genuine" ? Colors.green
                            : status == "Banned" ? Colors.red
                            : status == "Caution" ? Colors.orange
                            : Colors.red[900],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedStatus = val;
                  });
                },
                validator: (val) => val == null ? "Please select a status" : null,
              ),

              SizedBox(height: 30),

              Center(
                child: loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: saveMedicine,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                    backgroundColor: Colors.teal,
                  ),
                  child: Text("Save Medicine",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}