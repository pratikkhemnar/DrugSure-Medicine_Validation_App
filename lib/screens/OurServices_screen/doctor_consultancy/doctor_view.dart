// file: lib/consultancy/doctor_view.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'consultancy_service.dart';

class DoctorConsoleView extends StatelessWidget {
  const DoctorConsoleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConsultancyService(),
      builder: (context, _) {
        final service = ConsultancyService();
        final activeAppts = service.appointments.where((a) => a.status != 'Completed').toList();

        if (activeAppts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 70, color: Colors.green[200]),
                const SizedBox(height: 16),
                Text("Your queue is empty.", style: TextStyle(color: Colors.grey[600], fontSize: 18)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeAppts.length,
          itemBuilder: (context, index) {
            final appt = activeAppts[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: Colors.blue[50], child: const Icon(Icons.person, color: Colors.blue)),
                          const SizedBox(width: 12),
                          Text(appt.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                        child: Text(appt.timeSlot, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      if (appt.status == 'Scheduled')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              service.updateAppointmentStatus(appt, 'Live');
                              _launchJitsiCall(context, appt.roomId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            label: const Text("Start Call", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      if (appt.status == 'Live') ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchJitsiCall(context, appt.roomId),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.video_call, color: Colors.green),
                            label: const Text("Re-join", style: TextStyle(color: Colors.green)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => service.updateAppointmentStatus(appt, 'Completed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.stop, color: Colors.white),
                            label: const Text("End", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchJitsiCall(BuildContext context, String roomId) async {
    final Uri jitsiUrl = Uri.parse('https://meet.jit.si/$roomId');
    if (!await launchUrl(jitsiUrl, mode: LaunchMode.externalApplication)) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open video.')));
    }
  }
}