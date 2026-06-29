// lib/screens/skin_history_screen.dart
//
// Shows past skin analysis records from Firestore (newest first).
// Optional screen - add a button/nav item to reach this from SkinCheckerScreen.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drugsuremva/screens/quick_Actions_Screens/Skin_Disease/skin_history_service.dart';
import 'package:flutter/material.dart';


class SkinHistoryScreen extends StatefulWidget {
  const SkinHistoryScreen({super.key});

  @override
  State<SkinHistoryScreen> createState() => _SkinHistoryScreenState();
}

class _SkinHistoryScreenState extends State<SkinHistoryScreen> {
  final SkinHistoryService _historyService = SkinHistoryService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skin Check History')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _historyService.getHistoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(
              child: Text('No skin checks yet. Analyze a photo to get started!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final severity = record['severity'] ?? 'Moderate';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: record['imageUrl'] != null
                        ? CachedNetworkImage(
                            imageUrl: record['imageUrl'],
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const SizedBox(
                              width: 56, height: 56,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.image, size: 56),
                  ),
                  title: Text(
                    record['conditionName'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    record['analyzedAt']?.toString().split('.').first ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor(severity).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      severity,
                      style: TextStyle(color: _severityColor(severity), fontSize: 11),
                    ),
                  ),
                  onTap: () => _showDetailDialog(record),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record['conditionName'] ?? 'Unknown'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(record['description'] ?? ''),
              const SizedBox(height: 10),
              Text('Causes:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(record['possibleCauses'] ?? ''),
              const SizedBox(height: 10),
              Text('When to see doctor:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(record['whenToSeeDoctor'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(record);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _historyService.deleteAnalysis(record['id'], record['imageUrl']);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
