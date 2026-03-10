import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String jobTitle;
  final String employeeName;

  ChatScreen({
    required this.senderId,
    required this.receiverId,
    required this.jobTitle,
    required this.employeeName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = {
      'senderId': widget.senderId,
      'text': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    String chatId = widget.senderId + '_' + widget.receiverId;

    DocumentReference chatDocRef = _firestore.collection('chats').doc(chatId);
    DocumentSnapshot chatDocSnapshot = await chatDocRef.get();

    if (!chatDocSnapshot.exists) {
      await chatDocRef.set({
        'participants': [widget.senderId, widget.receiverId],
        'jobTitle': widget.jobTitle,
        'lastMessage': _messageController.text,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await chatDocRef.update({
        'lastMessage': _messageController.text,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    }

    await chatDocRef.collection('messages').add(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    String chatId = widget.senderId + '_' + widget.receiverId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.employeeName}'),
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
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                        messages[index].data() as Map<String, dynamic>;
                    bool isSentByMe =
                        messageData['senderId'] == widget.senderId;

                    return ListTile(
                      title: Align(
                        alignment: isSentByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            messageData['text'],
                            style: TextStyle(
                                color:
                                    isSentByMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
