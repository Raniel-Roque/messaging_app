import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messaging_app/services/chat/chat_service.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String messageID;
  final String senderID;
  final String receiverID;
  final Timestamp timestamp;
  final bool isDeleted;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageID,
    required this.senderID,
    required this.receiverID,
    required this.timestamp,
    required this.isDeleted,
  });

  @override
  ChatBubbleState createState() => ChatBubbleState();
}

class ChatBubbleState extends State<ChatBubble> {
  bool _isTimestampVisible = false; // Track timestamp visibility

  // Time Formatter
  String _formatTime(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat.jm().format(dateTime);
  }

  // Show options for sender
  void _showOptionsForSender(BuildContext context, String messageID,
      String senderID, String receiverID) {
    // If the message is deleted, do not show options
    if (widget.isDeleted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Copy Message
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Message'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessage(context, widget.message);
                },
              ),

              // Delete Message
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Message'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(context, messageID, senderID, receiverID);
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(
      () {
        // Hide keyboard after modal is closed
        FocusScope.of(context).unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
    );
  }

  // Show options for receiver
  void _showOptionsForReceiver(
      BuildContext context, String messageID, String senderID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Copy Message
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Message'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessage(context, widget.message);
                },
              ),

              // Report Message Button
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report Message'),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageID, senderID);
                },
              ),

              // Block User
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, senderID);
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(
      () {
        // Hide keyboard after modal is closed
        FocusScope.of(context).unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
    );
  }

  // Report message
  void _reportMessage(BuildContext context, String messageID, String senderID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report Message"),
        content: Text("Are you sure you want to report this message?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          // Report Button (Confirm)
          TextButton(
            onPressed: () {
              ChatService().reportMessage(messageID, senderID);
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

  // Block User
  void _blockUser(BuildContext context, String senderID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Block User"),
        content: Text("Are you sure you want to block this user?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          // Block Button (Confirm)
          TextButton(
            onPressed: () {
              ChatService().blockUser(senderID);
              // Dismiss Dialog => Dismiss Chat => Home Page
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

  // Copy Message
  void _copyMessage(BuildContext context, String message) {
    Clipboard.setData(ClipboardData(text: message)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Message copied to clipboard"),
        ),
      );
    });
  }

  // Delete Message
  void _deleteMessage(BuildContext context, String messageID, String senderID,
      String otherUserID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Message"),
        content: Text("Are you sure you want to delete this message?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          // Delete Button (Confirm)
          TextButton(
            onPressed: () {
              ChatService().deleteMessage(
                  widget.messageID, widget.senderID, widget.receiverID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Message has been deleted"),
                ),
              );
            },
            child: Text(
              "Delete",
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
    // GestureDetector for both chat bubble states
    return GestureDetector(
      onLongPress: () {
        if (!widget.isCurrentUser) {
          _showOptionsForReceiver(context, widget.messageID, widget.senderID);
        } else {
          _showOptionsForSender(
              context, widget.messageID, widget.senderID, widget.receiverID);
        }
      },
      onTap: () {
        setState(() {
          _isTimestampVisible = !_isTimestampVisible;
        });
      },
      child: Column(
        crossAxisAlignment: widget.isCurrentUser
            ? CrossAxisAlignment.end // = Sender / User
            : CrossAxisAlignment.start, // = Receiver
        children: [
          widget.isDeleted ? _buildDeletedBubble() : _buildChatBubble(),
          if (_isTimestampVisible)
            Padding(
              padding:
                  const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 5.0),
              child: Text(
                _formatTime(widget.timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  // Method to build the chat bubble for deleted messages
  Widget _buildDeletedBubble() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Text(
        widget.isCurrentUser
            ? 'You have deleted this message'
            : 'User has deleted this message',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // Method to build the chat bubble for non-deleted messages
  Widget _buildChatBubble() {
    return Container(
      decoration: BoxDecoration(
        color: widget.isCurrentUser
            ? Colors.green // = Sender / User
            : Colors.blue, // = Receiver
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Text(
        widget.message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
