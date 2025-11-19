import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SymptomCheckerScreen extends StatefulWidget {
  @override
  _SymptomCheckerScreenState createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool loading = false;
  String result = "";

  SpeechToText speech = SpeechToText();
  FlutterTts tts = FlutterTts();
  bool isListening = false;
  bool isSpeaking = false;

  final String apiKey = "AIzaSyB-c82jXIzMDLxIW41gh0qFKIVqXC2qIh8";

  late GenerativeModel model;

  @override
  void initState() {
    super.initState();

    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        "You are a medical symptom checker. Never prescribe medicines.",
      ),
    );

    tts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  Future<void> speakText(String text) async {
    await tts.stop();
    setState(() => isSpeaking = true);
    await tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await tts.stop();
    setState(() => isSpeaking = false);
  }

  Future<void> checkSymptoms() async {
    stopSpeaking(); // stop previous audio

    final userInput = _controller.text.trim();
    if (userInput.isEmpty) {
      setState(() => result = "Please enter symptoms.");
      return;
    }

    setState(() {
      loading = true;
      result = "";
    });

    final prompt = """
User Symptoms: $userInput

Provide:

• 3 Possible Causes  
• Precautions  
• When to Visit a Doctor  
• Simple explanation  
• NEVER prescribe medicines  
""";

    try {
      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      setState(() {
        result = response.text ?? "No response. Try again.";
      });

      speakText(result); // speak result
    } catch (e) {
      setState(() {
        result = "⚠ Error: $e";
      });
    }

    setState(() => loading = false);
  }

  Future<void> startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(onResult: (value) {
        setState(() => _controller.text = value.recognizedWords);
      });
    }
  }

  void stopListening() {
    setState(() => isListening = false);
    speech.stop();
  }

  void _clearInput() {
    stopSpeaking();
    setState(() {
      _controller.clear();
      result = "";
    });
  }

  @override
  void dispose() {
    stopSpeaking();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Symptom Checker",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal[800]),
          onPressed: () {
            stopSpeaking();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty || result.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all, color: Colors.teal[800]),
              onPressed: _clearInput,
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 10),

            Text(
              "How are you feeling?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),

            SizedBox(height: 6),

            Text(
              "Describe your symptoms for AI analysis",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.teal.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Example: headache, fever, cough for 2 days...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [

                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isListening ? Colors.red : Colors.teal[50],
                          ),
                          child: IconButton(
                            onPressed: () {
                              isListening ? stopListening() : startListening();
                            },
                            icon: Icon(
                              isListening ? Icons.mic_off : Icons.mic,
                              color: isListening ? Colors.white : Colors.teal,
                              size: 22,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        if (isListening)
                          Text(
                            "Listening...",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        Spacer(),

                        Text(
                          "${_controller.text.length} chars",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[700]!, Colors.teal[500]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: loading ? null : checkSymptoms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: loading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Analyzing...",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Analyze Symptoms",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            if (loading)
              _buildLoadingIndicator()
            else if (result.isEmpty)
              _buildEmptyState()
            else
              _buildResultCard(),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 40),
          CircularProgressIndicator(color: Colors.teal),
          SizedBox(height: 20),
          Text("Analyzing your symptoms...",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal[800])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.health_and_safety, size: 60, color: Colors.teal),
            SizedBox(height: 15),
            Text(
              "Describe Your Symptoms",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: EdgeInsets.all(18),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.teal.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_information, color: Colors.teal, size: 26),
              SizedBox(width: 10),
              Text(
                "AI Analysis",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900]),
              )
            ],
          ),

          SizedBox(height: 14),

          Text(
            result,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 16),

          if (isSpeaking)
            Center(
              child: ElevatedButton.icon(
                onPressed: stopSpeaking,
                icon: Icon(Icons.stop, color: Colors.white),
                label: Text("Stop Voice"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "This is AI-generated advice. Please consult a qualified doctor.",
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
