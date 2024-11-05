import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messaging_app/components/chat_bubble.dart';
import 'package:messaging_app/components/my_text_field.dart';

import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage(
      {super.key, required this.receiverEmail, required this.receiverID});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Send Message
  void sendMessage() async {
    //Send only if there is an input
    String trimmedMessage = _messageController.text.trim();
    if (trimmedMessage.isNotEmpty) {
      _messageController.clear();
      await _chatService.sendMessage(
        widget.receiverID,
        trimmedMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Hide keyboard when tapping outside
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: _buildMessageList(),
                ),
              ),
              _buildUserInput(),
            ],
          ),
        ),
      ),
    );
  }

  // Build Message List
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;
        List<Widget> messageWidgets = [];
        String? lastDate;

        for (var doc in docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Timestamp timestamp = data['timestamp'];
          DateTime dateTime = timestamp.toDate();
          String formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);

          // Add a date header if the date changes
          if (lastDate != formattedDate) {
            messageWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
            );
            lastDate = formattedDate;
          }

          // Add each message using _buildMessageItem
          messageWidgets.add(_buildMessageItem(doc));
        }

        return Column(
          children: messageWidgets,
        );
      },
    );
  }

  // Build Message
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // Align message to right = current user. left = receiver
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            messageID: doc.id,
            senderID: data["senderID"],
            receiverID: data["receiverID"],
            timestamp: data["timestamp"],
            isDeleted: data['messageDeleted'] ?? false,
          ),
        ],
      ),
    );
  }

  // Build message input
  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
      child: Row(
        children: [
          SizedBox(width: 15),
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message",
              obscureText: false,
              isMultiLine: true,
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration:
                BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
