// lib/services/skin_analysis_service.dart
//
// DrugSure - Skin Disease AI Analysis Service
// Uses Google Gemini API (FREE tier - gemini-2.5-flash model)
// Gemini handles BOTH image understanding + text generation in ONE call,
// so we don't need a separate classifier model + separate text model.
//
// FREE TIER LIMITS (as of mid-2026): ~10-15 requests/minute, 250 RPD+ depending
// on model. More than enough for a college project / personal app.
//
// HOW TO GET YOUR FREE API KEY:
// 1. Go to https://aistudio.google.com/app/apikey
// 2. Sign in with Google account (no credit card needed)
// 3. Click "Create API Key"
// 4. Copy the key and paste it below in GEMINI_API_KEY

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SkinAnalysisResult {
  final String conditionName;      // e.g. "Acne (Mild to Moderate)"
  final String description;        // What it is
  final String possibleCauses;     // Why it happens
  final List<String> homeRemedies; // Safe general suggestions
  final String whenToSeeDoctor;    // Red flags / urgency
  final String severity;           // "Low", "Moderate", "High" - for UI color coding
  final double confidenceNote;     // 0.0-1.0, model's own confidence if it gives one (else 0.5 default)
  final DateTime analyzedAt;

  SkinAnalysisResult({
    required this.conditionName,
    required this.description,
    required this.possibleCauses,
    required this.homeRemedies,
    required this.whenToSeeDoctor,
    required this.severity,
    required this.confidenceNote,
    required this.analyzedAt,
  });

  // Convert to Map for saving in Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'conditionName': conditionName,
      'description': description,
      'possibleCauses': possibleCauses,
      'homeRemedies': homeRemedies,
      'whenToSeeDoctor': whenToSeeDoctor,
      'severity': severity,
      'confidenceNote': confidenceNote,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory SkinAnalysisResult.fromFirestoreMap(Map<String, dynamic> map) {
    return SkinAnalysisResult(
      conditionName: map['conditionName'] ?? 'Unknown',
      description: map['description'] ?? '',
      possibleCauses: map['possibleCauses'] ?? '',
      homeRemedies: List<String>.from(map['homeRemedies'] ?? []),
      whenToSeeDoctor: map['whenToSeeDoctor'] ?? '',
      severity: map['severity'] ?? 'Moderate',
      confidenceNote: (map['confidenceNote'] ?? 0.5).toDouble(),
      analyzedAt: DateTime.tryParse(map['analyzedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class SkinAnalysisException implements Exception {
  final String message;
  SkinAnalysisException(this.message);
  @override
  String toString() => message;
}

class SkinAnalysisService {
  // =========================================================================
  // STEP 1: PUT YOUR FREE GEMINI API KEY HERE
  // Get it free from: https://aistudio.google.com/app/apikey
  // =========================================================================
  static const String _geminiApiKey = 'AQ.Ab8RN6LZoOUwNex5ByycDIHmbFrkh-FVTrpbHhvShX-m6wPJjA';

  // Using gemini-2.5-flash: free tier, fast, supports image input.
  // If this model ever gets restricted in your region, switch to
  // 'gemini-2.0-flash' below (just change the string).
  static const String _model = 'gemini-2.5-flash';

  static String get _endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_geminiApiKey';


  Future<SkinAnalysisResult> analyzeSkinImage(File imageFile) async {
    if (_geminiApiKey == 'AQ.Ab8RN6LZoOUwNex5ByycDIHmbFrkh-FVTrpbHhvShX-m6wPJjA') {
      throw SkinAnalysisException(
        'API key not set! Open skin_analysis_service.dart and paste your '
        'free Gemini API key from https://aistudio.google.com/app/apikey',
      );
    }

    try {
      // Read image and convert to base64 (Gemini needs base64 for inline images)
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Detect mime type from file extension (keep it simple: jpg/png cover 95% of cases)
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';

      // The prompt is the most important part - it forces Gemini to return
      // STRICT JSON so we can parse it reliably in Flutter, instead of
      // free-flowing text that's hard to display in structured UI.
      const prompt = '''
You are a dermatology assistant helping a general user understand a photo of their skin condition. 
Analyze the uploaded skin image carefully.

Respond ONLY with valid JSON (no markdown, no backticks, no extra text) in EXACTLY this structure:

{
  "conditionName": "most likely condition name, e.g. Acne Vulgaris (Mild)",
  "description": "2-3 sentences explaining what this condition is in simple language",
  "possibleCauses": "2-3 sentences on common causes of this condition",
  "homeRemedies": ["remedy 1", "remedy 2", "remedy 3", "remedy 4"],
  "whenToSeeDoctor": "1-2 sentences on warning signs that mean they should see a dermatologist urgently",
  "severity": "Low" or "Moderate" or "High",
  "confidenceNote": a number between 0 and 1 representing your confidence
}

IMPORTANT RULES:
- If the image does not clearly show a skin condition or is not a skin photo at all, set conditionName to "Unclear Image" and explain in description that a clearer photo is needed.
- Always include a gentle reminder within whenToSeeDoctor that this is an AI estimate, not a medical diagnosis.
- Keep language simple, avoid overly technical jargon, write for a general audience.
- Do not include any text outside the JSON object.
''';

      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": mimeType,
                  "data": base64Image,
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.4,       // lower = more consistent/factual, less "creative"
          "maxOutputTokens": 1024,
          "responseMimeType": "application/json", // forces Gemini to return clean JSON
        }
      };

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        // Common error cases handled with friendly messages
        if (response.statusCode == 400) {
          throw SkinAnalysisException(
            'Invalid request - check your API key is correct.\n${response.body}',
          );
        } else if (response.statusCode == 429) {
          throw SkinAnalysisException(
            'Free tier limit reached for now. Please wait a minute and try again.',
          );
        }
        throw SkinAnalysisException(
          'Server error (${response.statusCode}): ${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      // Navigate Gemini's response structure to get the actual text content
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw SkinAnalysisException(
          'No response from AI. The image might have been blocked by safety filters.',
        );
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List;
      final rawText = parts[0]['text'] as String;

      // Parse the JSON that Gemini returned
      final Map<String, dynamic> parsedJson = jsonDecode(rawText);

      return SkinAnalysisResult(
        conditionName: parsedJson['conditionName'] ?? 'Unknown',
        description: parsedJson['description'] ?? '',
        possibleCauses: parsedJson['possibleCauses'] ?? '',
        homeRemedies: List<String>.from(parsedJson['homeRemedies'] ?? []),
        whenToSeeDoctor: parsedJson['whenToSeeDoctor'] ?? '',
        severity: parsedJson['severity'] ?? 'Moderate',
        confidenceNote: (parsedJson['confidenceNote'] ?? 0.5).toDouble(),
        analyzedAt: DateTime.now(),
      );
    } on SkinAnalysisException {
      rethrow;
    } catch (e) {
      throw SkinAnalysisException('Something went wrong: $e');
    }
  }
}
