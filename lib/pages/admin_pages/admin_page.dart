import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../components/admin_components/my_admin_bottom_navigation_bar.dart';
import '../../components/user_tile.dart';
import '../../services/auth/auth_service.dart';
import '../../services/chat/chat_service.dart';
import '../user_pages/chat_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  Future<void> _handleRefresh() async {
    setState(() {}); // Refreshes the UI to rebuild the user list.
    return await Future.delayed(
      Duration(seconds: 2),
    );
  }

  void _showOptions(BuildContext context, String userID) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('User Details'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Reset Password'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete Account'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Admin Page'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      bottomNavigationBar: MyAdminBottomNavigationBar(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Convert the snapshot data to a list and sort it alphabetically
        List<Map<String, dynamic>> users =
            List<Map<String, dynamic>>.from(snapshot.data!);
        users.sort((a, b) => a["email"].compareTo(b["email"]));

        return LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: ListView(
            children: [
              SizedBox(height: 10.0),
              ...users.map<Widget>(
                (userData) => _buildUserListItem(userData, context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          _showOptions(context, userData["uid"]);
        },
        onLongPress: () {},
      );
    } else {
      return Container();
    }
  }
}
