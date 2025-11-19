import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiParser {
  static const String geminiKey = "YOUR_GEMINI_API_KEY";

  static Future<Map<String, dynamic>> decode(String qrData) async {
    final model = GenerativeModel(
      model: "gemini-pro",
      apiKey: geminiKey,
    );

    final result = await model.generateContent([
      Content.text("""
Convert this scanned QR/Barcode data into clean JSON format:
$qrData
Example JSON:
{
  "name": "",
  "batch_no": "",
  "expiry": "",
  "manufacturer": ""
}
""")
    ]);

    try {
      return _extractJson(result.text!);
    } catch (_) {
      return {"error": "Unable to decode"};
    }
  }

  static Map<String, dynamic> _extractJson(String text) {
    final start = text.indexOf("{");
    final end = text.lastIndexOf("}") + 1;
    final jsonString = text.substring(start, end);
    return jsonDecode(jsonString);
  }
}
