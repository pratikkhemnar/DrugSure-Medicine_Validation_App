import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  DialogFlowtter? dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDialogflow();
  }

  Future<void> _initDialogflow() async {
    try {
      print("Attempting to load Dialogflow asset...");

      // CRITICAL: Ensure this matches your ACTUAL file name in the assets folder exactly.
      // Common Error: Check hyphens (-) vs underscores (_)
      dialogFlowtter = DialogFlowtter(
        jsonPath: 'assets/durgsure-mva-fc6165734076.json',
      );

      print("Dialogflow Initialized Successfully");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showBot(
          "Hi! Welcome to DrugSure Support. How can I help you today?",
          options: ["About App", "How to Use App", "Report Issue"],
        );
      }
    } catch (e) {
      print("CRITICAL ERROR initializing Dialogflow: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showBot("Error: Could not connect. Check your internet and asset file name.");
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

    if (dialogFlowtter == null) {
      print("Error: DialogFlowtter is NULL. Init failed previously.");
      _showBot("Support service is not initialized. Please restart the page.");
      return;
    }

    try {
      print("Sending message to Dialogflow: $text");

      final response = await dialogFlowtter!.detectIntent(
        queryInput: QueryInput(text: TextInput(text: text, languageCode: "en")),
      );

      if (response.message == null) {
        print("Received NULL message from Dialogflow");
        return;
      }

      // Extract text safely
      String textResponse = "I didn't understand that.";

      // Check message structure
      if (response.message?.text?.text?.isNotEmpty == true) {
        textResponse = response.message!.text!.text![0];
      } else {
        print("Response received but had no text content.");
      }

      _showBot(textResponse);

    } catch (e) {
      print("Error sending message: $e");
      _showBot("Connection error. Please check your internet.");
    }
  }

  @override
  void dispose() {
    dialogFlowtter?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    final bool isUser = msg["type"] == "user";
    final String text = msg["text"];
    final List<String>? options = msg["options"];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
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
                  fontSize: 15,
                ),
              ),
            ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("DrugSure Support"),
        backgroundColor: const Color(0xFF0A5C5A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Start a conversation...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, i) => buildMessage(messages[i]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Color(0xFF0A5C5A)),
            ),
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
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isLoading ? Colors.grey : const Color(0xFF0A5C5A),
                  child: IconButton(
                    onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
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