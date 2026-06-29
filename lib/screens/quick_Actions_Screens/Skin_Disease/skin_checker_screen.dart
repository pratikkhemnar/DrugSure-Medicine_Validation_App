// lib/screens/skin_checker_screen.dart
//
// Main screen: user picks image (camera/gallery) -> sends to Gemini AI
// -> shows structured result -> saves to Firestore history.
//
// Add this screen to your DrugSure navigation (drawer/bottom nav/home grid)
// like you do for other features (e.g. Health Risk Assessment).

import 'dart:io';
import 'package:drugsuremva/screens/quick_Actions_Screens/Skin_Disease/skin_analysis_service.dart';
import 'package:drugsuremva/screens/quick_Actions_Screens/Skin_Disease/skin_history_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class SkinCheckerScreen extends StatefulWidget {
  const SkinCheckerScreen({super.key});

  @override
  State<SkinCheckerScreen> createState() => _SkinCheckerScreenState();
}

class _SkinCheckerScreenState extends State<SkinCheckerScreen> {
  final SkinAnalysisService _analysisService = SkinAnalysisService();
  final SkinHistoryService _historyService = SkinHistoryService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  SkinAnalysisResult? _result;
  bool _isAnalyzing = false;
  String? _errorMessage;

  // ---------------------------------------------------------------------
  // IMAGE PICKING (Camera + Gallery)
  // ---------------------------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // compress a bit to keep upload fast
        maxWidth: 1024,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access camera/gallery: $e';
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ANALYZE WITH GEMINI AI
  // ---------------------------------------------------------------------
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _analysisService.analyzeSkinImage(_selectedImage!);

      setState(() {
        _result = result;
        _isAnalyzing = false;
      });

      // Save to Firestore history in the background (don't block UI)
      _saveToHistory(result);
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e is SkinAnalysisException ? e.message : e.toString();
      });
    }
  }

  Future<void> _saveToHistory(SkinAnalysisResult result) async {
    if (_selectedImage == null) return;
    try {
      final imageUrl = await _historyService.uploadSkinImage(_selectedImage!);
      await _historyService.saveAnalysis(result: result, imageUrl: imageUrl);
    } catch (e) {
      // Silent fail for history save - don't disturb user with this error
      // since the analysis itself succeeded and is shown on screen.
      debugPrint('History save failed: $e');
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Health Checker'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 16),

            // Image preview / placeholder
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade500),
                          const SizedBox(height: 8),
                          Text('Tap to add a skin photo',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            if (_selectedImage != null)
              TextButton.icon(
                onPressed: _showImageSourceSheet,
                icon: const Icon(Icons.refresh),
                label: const Text('Change Photo'),
              ),

            const SizedBox(height: 8),

            // Analyze button
            ElevatedButton(
              onPressed: (_selectedImage == null || _isAnalyzing) ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Analyze Skin', style: TextStyle(fontSize: 16)),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
              ),
            ],

            // Result card
            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(SkinAnalysisResult result) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Condition name + severity chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.conditionName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _severityColor(result.severity).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.severity,
                    style: TextStyle(
                      color: _severityColor(result.severity),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            _sectionTitle('What is this?'),
            Text(result.description),
            const SizedBox(height: 16),

            _sectionTitle('Possible Causes'),
            Text(result.possibleCauses),
            const SizedBox(height: 16),

            _sectionTitle('Suggested Care'),
            ...result.homeRemedies.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),

            _sectionTitle('When to See a Doctor'),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(result.whenToSeeDoctor, style: const TextStyle(fontSize: 13.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
}
