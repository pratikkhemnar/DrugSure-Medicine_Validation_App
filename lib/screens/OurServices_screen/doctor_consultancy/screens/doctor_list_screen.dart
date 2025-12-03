// lib/doctor_consultancy/screens/doctor_list_screen.dart
import 'package:flutter/material.dart';
import '../services/signaling_service.dart';
import 'video_call_screen.dart';

class SignalingConfig {
  static const emulator = 'http://10.0.2.2:4000';
  static String get serverUrl => emulator;
}

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  final List<Doctor> _doctors = [
    Doctor(
      id: 'doc1',
      name: 'Dr. Rahul Sharma',
      specialization: 'General Physician',
      rating: 4.8,
      experience: '8 years',
      consultationFee: '₹199',
      available: true,
      languages: ['English', 'Hindi'],
      nextAvailable: 'Available now',
      imageColor: Colors.blue,
    ),
    Doctor(
      id: 'doc2',
      name: 'Dr. Priya Patel',
      specialization: 'Dermatologist',
      rating: 4.9,
      experience: '12 years',
      consultationFee: '₹299',
      available: true,
      languages: ['English', 'Hindi'],
      nextAvailable: '10 mins',
      imageColor: const Color(0xFFEC407A),
    ),
    Doctor(
      id: 'doc3',
      name: 'Dr. Pranav Garud',
      specialization: 'Cardiologist',
      rating: 4.7,
      experience: '15 years',
      consultationFee: '₹199',
      available: true,
      languages: ['English', 'Hindi', 'Marathi'],
      nextAvailable: '5 mins',
      imageColor: Colors.green,
    ),
    Doctor(
      id: 'doc4',
      name: 'Dr. Anjali Mehta',
      specialization: 'Pediatrician',
      rating: 4.9,
      experience: '10 years',
      consultationFee: '₹399',
      available: false,
      languages: ['English', 'Hindi'],
      nextAvailable: 'Tomorrow 2 PM',
      imageColor: Colors.orange,
    ),
  ];

  Future<void> _startCall(Doctor doctor) async {
    if (!doctor.available) {
      _showUnavailableDialog(doctor);
      return;
    }

    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final signaling = SignalingService(
        serverUrl: SignalingConfig.serverUrl,
        onAnyEvent: (e, d) => debugPrint('Signaling: $e - $d'),
      );

      await signaling.init();

      final roomId =
          'room_${doctor.id}_${DateTime.now().millisecondsSinceEpoch}';
      final userId = 'patient_${DateTime.now().millisecondsSinceEpoch}';

      signaling.joinRoom(roomId, userId);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            signaling: signaling,
            roomId: roomId,
            localId: userId,
            doctorName: doctor.name,
          ),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Failed to connect: $e');
      _showErrorSnackbar();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUnavailableDialog(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Doctor Unavailable'),
        content: Text(
            'Dr. ${doctor.name.split(' ').last} is not available right now. Next available: ${doctor.nextAvailable}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Connection failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consult Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Theme.of(context).primaryColor.withOpacity(0.02),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  icon: Icons.video_call_rounded,
                  value: '24/7',
                  label: 'Video Consult',
                ),
                _StatCard(
                  icon: Icons.access_time_filled_rounded,
                  value: '15 min',
                  label: 'Wait Time',
                ),
                _StatCard(
                  icon: Icons.verified_rounded,
                  value: '4.8★',
                  label: 'Avg. Rating',
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search doctors...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon:
                        Icon(Icons.search_rounded, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list_rounded,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Doctors List
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading doctors...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _DoctorCard(
                      doctor: _doctors[index],
                      onCall: () => _startCall(_doctors[index]),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final String experience;
  final String consultationFee;
  final bool available;
  final List<String> languages;
  final String nextAvailable;
  final Color imageColor;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.experience,
    required this.consultationFee,
    required this.available,
    required this.languages,
    required this.nextAvailable,
    required this.imageColor,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onCall;

  const _DoctorCard({
    required this.doctor,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    doctor.imageColor.withOpacity(0.2),
                    doctor.imageColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: doctor.imageColor,
              ),
            ),

            const SizedBox(width: 16),

            // Doctor Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Status Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: doctor.available
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: doctor.available
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: doctor.available
                                    ? Colors.green
                                    : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              doctor.available ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: doctor.available
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    doctor.specialization,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Rating, Experience and Fee Row -> CHANGED TO WRAP TO FIX OVERFLOW
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              doctor.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.work_outline_rounded,
                                size: 14, color: Colors.blue[700]),
                            const SizedBox(width: 4),
                            Text(
                              doctor.experience,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          doctor.consultationFee,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Languages
                  if (doctor.languages.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: doctor.languages.map((lang) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            lang,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Call Button
            Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: doctor.available
                          ? [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ]
                          : [
                        Colors.grey[400]!,
                        Colors.grey[500]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (doctor.available
                            ? Theme.of(context).primaryColor
                            : Colors.grey)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onCall,
                    icon: const Icon(
                      Icons.video_call_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                if (!doctor.available) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      doctor.nextAvailable,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}