import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String peerUserId;

  ChatScreen({required this.currentUserId, required this.peerUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String chatId;

  @override
  void initState() {
    super.initState();
    // Generate chatId (lexicographical order ensures same chat for both users)
    chatId = widget.currentUserId.hashCode <= widget.peerUserId.hashCode
        ? '${widget.currentUserId}_${widget.peerUserId}'
        : '${widget.peerUserId}_${widget.currentUserId}';
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final msgDoc = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final messageData = {
      'senderId': widget.currentUserId,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    // Save message
    await msgDoc.set(messageData);

    // Update lastMessage in chat doc
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [widget.currentUserId, widget.peerUserId],
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == widget.currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['message'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.teal),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
