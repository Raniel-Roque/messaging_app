import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/components/chat_bubble.dart';
import 'package:messaging_app/components/my_text_field.dart';

import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  //Text controller
  final TextEditingController _messageController = TextEditingController();

  //Chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //Send Message
  void sendMessage() async {
    //Send if only there is an input
    if (_messageController.text.isNotEmpty) {
      //send message
      await _chatService.sendMessage(receiverID, _messageController.text);

      //Clear text
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          //Display all message
          Expanded(child: _buildMessageList()),

          //Display user input
          _buildUserInput(),
        ],
      ),
    );
  }

  //Build Message List
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(receiverID, senderID),
      builder: (context, snapshot) {
        //Errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        //Return list view
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  //Build Message
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //Is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    //Align message to right = current. left = receiver
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  //Build message input
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
                obscureText: false),
          ),

          SizedBox(
            width: 10,
          ),

          //Send Button
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: sendMessage,
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
