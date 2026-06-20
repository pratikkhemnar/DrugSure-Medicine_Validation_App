// file: lib/consultancy/patient_view.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'consultancy_service.dart';


class PatientConsoleView extends StatelessWidget {
  const PatientConsoleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listens to the service for changes
    return ListenableBuilder(
      listenable: ConsultancyService(),
      builder: (context, _) {
        final service = ConsultancyService();
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: const TabBar(
                  labelColor: Colors.teal,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.teal,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(icon: Icon(Icons.search), text: "Find Doctors"),
                    Tab(icon: Icon(Icons.event_note), text: "My Bookings"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildDoctorList(context, service),
                    _buildAppointmentsList(context, service),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorList(BuildContext context, ConsultancyService service) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.doctors.length,
      itemBuilder: (context, index) {
        final doc = service.doctors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ExpansionTile(
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.teal[50],
              child: Text(doc.avatar, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text("${doc.specialty} • ${doc.experience}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            children: [
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Available Slots Today", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 12),
                    doc.availableSlots.isEmpty
                        ? const Text("No slots remaining for today.", style: TextStyle(color: Colors.redAccent))
                        : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: doc.availableSlots.map((slot) {
                        return InkWell(
                          onTap: () {
                            service.bookAppointment(doc, slot);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('✅ Booked ${doc.name} at $slot')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.teal.withOpacity(0.3)),
                            ),
                            child: Text(slot, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsList(BuildContext context, ConsultancyService service) {
    if (service.appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No appointments booked yet.", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.appointments.length,
      itemBuilder: (context, index) {
        final appt = service.appointments[index];
        bool isJoinable = appt.status == 'Live';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isJoinable ? Colors.green : Colors.transparent, width: 2),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appt.doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  _buildStatusBadge(appt.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text("${appt.date} at ${appt.timeSlot}", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isJoinable ? () => _launchJitsiCall(context, appt.roomId) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.video_call, color: isJoinable ? Colors.white : Colors.grey),
                  label: Text(
                    isJoinable ? "Join Video Call Now" : "Waiting for Doctor...",
                    style: TextStyle(color: isJoinable ? Colors.white : Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.grey[100]!;
    Color text = Colors.grey[600]!;
    if (status == 'Live') {
      bg = Colors.green[50]!;
      text = Colors.green[700]!;
    } else if (status == 'Completed') {
      bg = Colors.blue[50]!;
      text = Colors.blue[700]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Future<void> _launchJitsiCall(BuildContext context, String roomId) async {
    final Uri jitsiUrl = Uri.parse('https://meet.jit.si/$roomId');
    if (!await launchUrl(jitsiUrl, mode: LaunchMode.externalApplication)) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open video.')));
    }
  }
}