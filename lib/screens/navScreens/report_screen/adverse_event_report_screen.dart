import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';   // <-- IMPORTANT
import 'adr_questions_screen.dart';
import 'models/firebase_service.dart';

class AdverseEventReportScreen extends StatefulWidget {
  @override
  _AdverseEventReportScreenState createState() =>
      _AdverseEventReportScreenState();
}

class _AdverseEventReportScreenState extends State<AdverseEventReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  final TextEditingController _placeOfPurchaseController =
  TextEditingController();
  final TextEditingController _natureOfIssueController =
  TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime? _manufacturingDate;
  DateTime? _expiryDate;
  DateTime? _purchaseDate;
  DateTime? _incidentDate;
  List<String> _photoUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Adverse Event Report'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Patient Information'),
              _buildPatientInfoSection(),

              SizedBox(height: 24),
              _buildSectionHeader('Medication Information'),
              _buildMedicationInfoSection(),

              SizedBox(height: 24),
              _buildSectionHeader('Issue/Concern'),
              _buildIssueSection(),

              SizedBox(height: 24),
              _buildSectionHeader('Photo Evidence (Optional)'),
              _buildPhotoSection(),

              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[800],
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _patientNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter patient name' : null,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter age' : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGender = value!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
              value!.isEmpty ? 'Please enter weight' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _medicineNameController,
              decoration: InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter medicine name' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _manufacturerController,
              decoration: InputDecoration(
                labelText: 'Manufacturer',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter manufacturer' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _batchNumberController,
              decoration: InputDecoration(
                labelText: 'Batch/Lot Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter batch number' : null,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker('Manufacturing Date',
                      _manufacturingDate, (date) => setState(() {
                        _manufacturingDate = date;
                      })),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker('Expiry Date', _expiryDate,
                          (date) => setState(() {
                        _expiryDate = date;
                      })),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _placeOfPurchaseController,
              decoration: InputDecoration(
                labelText: 'Place of Purchase',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter place of purchase' : null,
            ),
            SizedBox(height: 12),
            _buildDatePicker(
                'Purchase Date',
                _purchaseDate,
                    (date) =>
                    setState(() => _purchaseDate = date)),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _natureOfIssueController,
              decoration: InputDecoration(
                labelText: 'Nature of Issue',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please describe the issue' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please describe the issue' : null,
            ),
            SizedBox(height: 12),
            _buildDatePicker(
                'Date of Incident',
                _incidentDate,
                    (date) =>
                    setState(() => _incidentDate = date)),
          ],
        ),
      ),
    );
  }

  /// ⭐ FIXED PHOTO SECTION — NO OVERRIDING ERROR
  Widget _buildPhotoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_photoUrls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _photoUrls.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(
                        File(_photoUrls[index]), // <-- FIXED
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, size: 16, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _photoUrls.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt),
              label: Text('Upload Photos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[700],
              ),
            ),

            SizedBox(height: 8),
            Text(
              'Upload images of medicine, packaging, or affected area',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () => _selectDate(context, onDateSelected),
      child: InputDecorator(
        decoration:
        InputDecoration(labelText: label, border: OutlineInputBorder()),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate)
                  : 'Select date',
              style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey),
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        ),
        child: Text('Submit Report & Continue'),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onDateSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onDateSelected(picked);
  }

  Future<void> _pickImage() async {
    final XFile? image =
    await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _photoUrls.add(image.path));
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_manufacturingDate == null ||
        _expiryDate == null ||
        _purchaseDate == null ||
        _incidentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select all required dates')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ADRQuestionsScreen(
          reportData: {
            'patientName': _patientNameController.text,
            'age': int.parse(_ageController.text),
            'gender': _selectedGender,
            'weight': double.parse(_weightController.text),
            'medicineName': _medicineNameController.text,
            'manufacturer': _manufacturerController.text,
            'batchNumber': _batchNumberController.text,
            'manufacturingDate': _manufacturingDate!,
            'expiryDate': _expiryDate!,
            'placeOfPurchase': _placeOfPurchaseController.text,
            'purchaseDate': _purchaseDate!,
            'natureOfIssue': _natureOfIssueController.text,
            'description': _descriptionController.text,
            'incidentDate': _incidentDate!,
            'photoUrls': _photoUrls,
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _medicineNameController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
    _placeOfPurchaseController.dispose();
    _natureOfIssueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
