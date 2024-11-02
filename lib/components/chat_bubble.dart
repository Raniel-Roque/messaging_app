import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/services/chat/chat_service.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageID;
  final String userID;
  final Timestamp timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.userID,
    required this.timestamp,
  });

  //Time Formatter
  String _formatTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat.jm().format(dateTime);
  }

  //Show options
  void _showOptions(BuildContext context, String messageID, String userID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              //Report Message Button
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report Message'),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageID, userID);
                },
              ),

              //Block User
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userID);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Report message
  void _reportMessage(BuildContext context, String messageID, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report Message"),
        content: Text("Are you sure you want to report this message?"),
        actions: [
          //Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          //Report Button (Confirm)
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageID, userID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You have reported the message"),
                ),
              );
            },
            child: Text(
              "Report",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Block User
  void _blockUser(BuildContext context, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Block User"),
        content: Text("Are you sure you want to block this user?"),
        actions: [
          //Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          //Block Button (Confirm)
          TextButton(
            onPressed: () {
              ChatService().blockUser(userID);
              //Dismiss Dialog => Dismiss Chat => Home Page
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("User has been blocked"),
                ),
              );
            },
            child: Text(
              "Block",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          _showOptions(context, messageID, userID);
        }
      },
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 5.0),
            child: Text(
              _formatTime(timestamp),
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
