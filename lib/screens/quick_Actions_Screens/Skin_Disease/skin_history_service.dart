// lib/services/skin_history_service.dart
//
// Handles saving/fetching skin analysis history to Firestore.
// Add this alongside your existing Firestore service files in DrugSure.
//
// FIRESTORE STRUCTURE:
// users/{userId}/skin_analyses/{autoId}
//   - imageUrl: String (Firebase Storage URL)
//   - conditionName, description, possibleCauses, homeRemedies,
//     whenToSeeDoctor, severity, confidenceNote, analyzedAt

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'skin_analysis_service.dart';

class SkinHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /// Uploads the skin image to Firebase Storage and returns its download URL.
  /// Call this BEFORE saving the analysis record.
  Future<String> uploadSkinImage(File imageFile) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final fileName =
        'skin_images/$_userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Saves a completed analysis (with image URL) to Firestore history.
  Future<void> saveAnalysis({
    required SkinAnalysisResult result,
    required String imageUrl,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final data = result.toFirestoreMap();
    data['imageUrl'] = imageUrl;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('skin_analyses')
        .add(data);
  }

  /// Stream of past analyses, newest first - use this to build the history screen.
  Stream<List<Map<String, dynamic>>> getHistoryStream() {
    if (_userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('skin_analyses')
        .orderBy('analyzedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Delete a single history entry (and its image from Storage).
  Future<void> deleteAnalysis(String docId, String? imageUrl) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('skin_analyses')
        .doc(docId)
        .delete();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (_) {
        // Image might already be deleted, ignore.
      }
    }
  }
}
