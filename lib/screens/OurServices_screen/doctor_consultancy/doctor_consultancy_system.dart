// file: lib/consultancy/consultancy_screen.dart
import 'package:flutter/material.dart';
import '../patient_view.dart';
import 'doctor_view.dart';

class DoctorConsultancySystem extends StatefulWidget {
  const DoctorConsultancySystem({Key? key}) : super(key: key);

  @override
  State<DoctorConsultancySystem> createState() => _DoctorConsultancySystemState();
}

class _DoctorConsultancySystemState extends State<DoctorConsultancySystem> {
  bool isDoctorRole = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('DrugSure Consult', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Text(
                  isDoctorRole ? "Doctor" : "Patient",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isDoctorRole,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.tealAccent[700],
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.teal[300],
                  onChanged: (value) {
                    setState(() {
                      isDoctorRole = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: isDoctorRole ? const DoctorConsoleView() : const PatientConsoleView(),
    );
  }
}