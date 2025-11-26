import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/services.dart' hide TextInput; // Required for rootBundle

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  bool _isLoading = true; // To prevent sending messages before init

  @override
  void initState() {
    super.initState();
    _initDialogflow();
  }

  Future<void> _initDialogflow() async {
    try {
      // CORRECT WAY: Load asset as a string first
      String jsonString = await rootBundle.loadString('assets/durgsure-mva-66a73fa85f7d.json');

      // Initialize DialogFlowtter with the loaded string
      dialogFlowtter = DialogFlowtter(
        jsonPath: jsonString,
        // Alternatively, depending on exact version:
        // credentials: DialogAuthCredentials.fromJson(jsonString)
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showBot(
          "Hi! Welcome to DrugSure Support. How can I help you today?",
          options: ["About App", "How to Use App", "How It Works"],
        );
      }
    } catch (e) {
      print("Error initializing Dialogflow: $e");
      if (mounted) {
        _showBot("Error connecting to support system.");
      }
    }
  }

  void _showBot(String text, {List<String>? options}) {
    if (!mounted) return;
    setState(() {
      messages.insert(0, {
        "type": "bot",
        "text": text,
        "options": options,
      });
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      messages.insert(0, {"type": "user", "text": text});
    });

    _controller.clear();

    try {
      final response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(text: TextInput(text: text)),
      );

      if (response.message == null) return;

      // Extract text safely
      String? textResponse = response.message!.text?.text?.isNotEmpty == true
          ? response.message!.text!.text![0]
          : "I didn't catch that.";

      // Extract Payload/Options (if your Dialogflow agent sends custom payloads)
      // This is a basic implementation; customize based on your agent setup
      List<String>? options;

      _showBot(textResponse, options: options);

    } catch (e) {
      _showBot("Support is currently unavailable. Please try again later.");
    }
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    final bool isUser = msg["type"] == "user";
    final String text = msg["text"];
    final List<String>? options = msg["options"];

    // Message Bubble
    final bubble = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF0A5C5A) : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
          bottomRight: isUser ? Radius.zero : const Radius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
        ),
      ),
    );

    // Layout for Bubble + Options
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            bubble,
            if (options != null && options.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((opt) {
                  return InkWell(
                    onTap: () => _sendMessage(opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF0A5C5A)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        opt,
                        style: const TextStyle(
                            color: Color(0xFF0A5C5A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Support"),
        backgroundColor: const Color(0xFF0A5C5A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("Start a conversation..."))
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, i) => buildMessage(messages[i]),
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, -2)
                  )
                ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: _isLoading ? "Connecting..." : "Type a message...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0A5C5A),
                  child: IconButton(
                    onPressed: () => _sendMessage(_controller.text),
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}