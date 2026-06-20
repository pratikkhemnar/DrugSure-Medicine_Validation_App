// file: lib/consultancy/models.dart

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String experience;
  final String avatar;
  final List<String> availableSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.avatar,
    required this.availableSlots,
  });
}

class Appointment {
  final String id;
  final Doctor doctor;
  final String patientName;
  final String timeSlot;
  final String date;
  final String roomId;
  String status; // 'Scheduled', 'Live', 'Completed'

  Appointment({
    required this.id,
    required this.doctor,
    required this.patientName,
    required this.timeSlot,
    required this.date,
    required this.roomId,
    this.status = 'Scheduled',
  });
}