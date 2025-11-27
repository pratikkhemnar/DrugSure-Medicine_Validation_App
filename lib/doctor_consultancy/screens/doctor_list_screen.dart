// lib/doctor_consultancy/screens/doctor_list_screen.dart
import 'package:flutter/material.dart';
import 'package:drugsuremva/doctor_consultancy/services/signaling_service.dart';
import 'video_call_screen.dart';

// Replace with your actual server addresses
class SignalingConfig {
  static const emulator = 'http://10.0.2.2:4000';
  // static const phone = 'http://192.168.1.100:4000'; // replace with PC IP if using real phone
}

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final List<Map<String, String>> doctors = [
    {'id': 'doc1', 'name': 'Dr. Rahul'},
    {'id': 'doc2', 'name': 'Dr. Priya'},
  ];

  // We create a new SignalingService per call flow (can be shared if you prefer)
  void _startCall({required String doctorId, required String doctorName}) {
    final signaling = SignalingService(serverUrl: SignalingConfig.emulator, onAnyEvent: (e, d) => print('sig:$e $d'));
    signaling.init();

    // For demo: use a fixed room like 'room-test' or generate a unique room
    final roomId = 'room_test_1';
    final userId = 'patient_${DateTime.now().millisecondsSinceEpoch}';

    // join the room so server knows about us
    signaling.joinRoom(roomId, userId);

    // Navigate to VideoCallScreen and pass the signaling instance
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          signaling: signaling,
          roomId: roomId,
          localId: userId,
          isInitiator: true, // patient initiates in this demo
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, idx) {
          final d = doctors[idx];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(d['name']!),
            subtitle: Text('Tap to start call'),
            trailing: ElevatedButton(
              onPressed: () => _startCall(doctorId: d['id']!, doctorName: d['name']!),
              child: const Text('Call'),
            ),
          );
        },
      ),
    );
  }
}
