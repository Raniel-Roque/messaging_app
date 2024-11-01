import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

// Send Message
  void sendMessage() async {
    // Send if only there is an input
    String trimmedMessage = _messageController.text.trim();
    if (trimmedMessage.isNotEmpty) {
      // Send message
      await _chatService.sendMessage(
        widget.receiverID,
        trimmedMessage,
      );

      // Clear text
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 10,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display all messages
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: _buildMessageList(),
              ),
            ),

            // Display user input
            _buildUserInput(),
          ],
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
        // Errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        // Return list view
        return Column(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Build Message
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // Align message to right = current. left = receiver
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
            userID: data["senderID"],
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
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message",
              obscureText: false,
              isMultiLine: true,
            ),
          ),

          SizedBox(
            width: 10,
          ),

          // Send Button
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                sendMessage();
              },
              icon: Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
