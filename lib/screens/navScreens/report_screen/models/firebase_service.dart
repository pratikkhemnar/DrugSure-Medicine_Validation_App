import 'package:cloud_firestore/cloud_firestore.dart';
import 'adverse_event_model.dart';

class FirebaseService {
  final CollectionReference _reportsCollection =
  FirebaseFirestore.instance.collection('adverse_event_reports');

  Future<String> saveAdverseEventReport(AdverseEventReport report) async {
    try {
      final docRef = await _reportsCollection.add(report.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }

  Future<List<AdverseEventReport>> getReports() async {
    try {
      final querySnapshot = await _reportsCollection.get();
      return querySnapshot.docs.map((doc) {
        return AdverseEventReport.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }
}