// file: lib/consultancy/consultancy_service.dart
import 'package:flutter/material.dart';
import 'models.dart';

class ConsultancyService extends ChangeNotifier {
  // Singleton pattern to keep data alive across the whole app
  static final ConsultancyService _instance = ConsultancyService._internal();
  factory ConsultancyService() => _instance;
  ConsultancyService._internal();

  // Mock Database
  final List<Doctor> doctors = [
    Doctor(
      id: "DOC001",
      name: "Dr. Aarav Sharma",
      specialty: "General Physician",
      experience: "8 Yrs Exp",
      avatar: "AS",
      availableSlots: ["10:00 AM", "11:30 AM", "02:00 PM", "04:30 PM"],
    ),
    Doctor(
      id: "DOC002",
      name: "Dr. Meera Patil",
      specialty: "Pharmacologist",
      experience: "12 Yrs Exp",
      avatar: "MP",
      availableSlots: ["09:30 AM", "11:00 AM", "03:10 PM", "05:00 PM"],
    )
  ];

  final List<Appointment> appointments = [];

  void bookAppointment(Doctor doctor, String slot) {
    final apptId = "APT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    appointments.add(
      Appointment(
        id: apptId,
        doctor: doctor,
        patientName: "Pratik K.", // Mock patient identity
        timeSlot: slot,
        date: "Today",
        roomId: "DrugSure_${doctor.id}_$apptId",
        status: 'Scheduled',
      ),
    );
    doctor.availableSlots.remove(slot);
    notifyListeners(); // Tells the UI to update instantly
  }

  void updateAppointmentStatus(Appointment appt, String newStatus) {
    appt.status = newStatus;
    notifyListeners();
  }
}