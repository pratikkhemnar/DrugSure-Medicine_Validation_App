import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // --- CONTROLLERS FOR ALERTS ---
  final _alertTitleController = TextEditingController();
  final _alertMsgController = TextEditingController();
  final _alertDateController = TextEditingController(); // e.g., "2 hrs ago" or "05 Dec"
  String _selectedAlertType = 'info'; // Default
  final _alertFormKey = GlobalKey<FormState>();

  // --- CONTROLLERS FOR TIPS ---
  final _tipTitleController = TextEditingController();
  final _tipSubtitleController = TextEditingController();
  String _selectedTipColor = 'teal'; // Default
  final _tipFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _alertTitleController.dispose();
    _alertMsgController.dispose();
    _alertDateController.dispose();
    _tipTitleController.dispose();
    _tipSubtitleController.dispose();
    super.dispose();
  }

  // --- FIREBASE LOGIC: POST ALERT ---
  Future<void> _postAlert() async {
    if (!_alertFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('alerts').add({
        'title': _alertTitleController.text.trim(),
        'message': _alertMsgController.text.trim(),
        'date': _alertDateController.text.trim(),
        'type': _selectedAlertType,
        'timestamp': FieldValue.serverTimestamp(), // For sorting
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alert Posted Successfully!")));
      _clearAlertForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearAlertForm() {
    _alertTitleController.clear();
    _alertMsgController.clear();
    _alertDateController.clear();
    setState(() => _selectedAlertType = 'info');
  }

  // --- FIREBASE LOGIC: POST TIP ---
  Future<void> _postTip() async {
    if (!_tipFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('tips').add({
        'title': _tipTitleController.text.trim(),
        'subtitle': _tipSubtitleController.text.trim(),
        'color': _selectedTipColor,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Health Tip Posted Successfully!")));
      _clearTipForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearTipForm() {
    _tipTitleController.clear();
    _tipSubtitleController.clear();
    setState(() => _selectedTipColor = 'teal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.blueGrey[900],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          tabs: [
            Tab(icon: Icon(Icons.notifications_active), text: "Post Alert"),
            Tab(icon: Icon(Icons.lightbulb), text: "Post Health Tip"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAlertTab(),
          _buildTipTab(),
        ],
      ),
    );
  }

  // --- UI: ALERT FORM ---
  Widget _buildAlertTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _alertFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Create New Regulatory Alert", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            _buildTextField(
                controller: _alertTitleController,
                label: "Alert Title",
                hint: "e.g. Batch #3029 Recall"
            ),
            SizedBox(height: 15),

            _buildTextField(
                controller: _alertMsgController,
                label: "Details/Message",
                hint: "e.g. Paracetamol batch found contaminated...",
                maxLines: 3
            ),
            SizedBox(height: 15),

            _buildTextField(
                controller: _alertDateController,
                label: "Date Label",
                hint: "e.g. Today, 2 hrs ago, 12 Oct"
            ),
            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: _selectedAlertType,
              decoration: InputDecoration(
                labelText: "Alert Severity",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'info', child: Text("Info (Teal)")),
                DropdownMenuItem(value: 'warning', child: Text("Warning (Orange)")),
                DropdownMenuItem(value: 'critical', child: Text("Critical (Red)")),
              ],
              onChanged: (val) => setState(() => _selectedAlertType = val!),
            ),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _postAlert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text("POST ALERT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI: TIP FORM ---
  Widget _buildTipTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _tipFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Create New Health Tip", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            _buildTextField(
                controller: _tipTitleController,
                label: "Tip Title",
                hint: "e.g. Stay Hydrated"
            ),
            SizedBox(height: 15),

            _buildTextField(
                controller: _tipSubtitleController,
                label: "Short Description",
                hint: "e.g. Drink 8 glasses of water daily."
            ),
            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: _selectedTipColor,
              decoration: InputDecoration(
                labelText: "Card Color Style",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'teal', child: Text("Teal (Standard)")),
                DropdownMenuItem(value: 'blue', child: Text("Blue (Calm)")),
                DropdownMenuItem(value: 'purple', child: Text("Purple (Creative)")),
                DropdownMenuItem(value: 'orange', child: Text("Orange (Energetic)")),
              ],
              onChanged: (val) => setState(() => _selectedTipColor = val!),
            ),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _postTip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text("POST TIP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (val) => val!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }
}