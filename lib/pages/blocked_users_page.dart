import 'package:flutter/material.dart';
import 'package:messaging_app/components/user_tile.dart';

import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  //chat and auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //Unblock Box
  void _showUnblockBox(BuildContext context, String userID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Unblock User"),
        content: Text("Are you sure you want to unblock this user?"),
        actions: [
          //Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          //Report Button (Confirm)
          TextButton(
            onPressed: () {
              ChatService().unblockUser(userID);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You have unblocked the user"),
                ),
              );
            },
            child: Text("Unblock"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Get current user
    String userID = _authService.getCurrentUser()!.uid;

    //UI
    return Scaffold(
      appBar: AppBar(
        title: Text("Blocked Users"),
        actions: [],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getBlockedUsersStream(userID),
        builder: (context, snapshot) {
          //Errors
          if (snapshot.hasError) {
            return Center(
              child: const Text("Error loading.."),
            );
          }

          //Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final blockedUsers = snapshot.data ?? [];

          //No users blocked
          if (blockedUsers.isEmpty) {
            return Center(
              child: const Text("No Blocked Users"),
            );
          }
          //Return list view
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                text: user['email'],
                onTap: () => _showUnblockBox(context, user['uid']),
              );
            },
          );
        },
      ),
    );
  }
}
