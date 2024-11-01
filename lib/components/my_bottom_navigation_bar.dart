import 'package:flutter/material.dart';
import '../pages/settings_page.dart';
import '../services/auth/auth_service.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  void logout(BuildContext context) {
    final auth = AuthService();
    auth.signOut();
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              logout(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You have logged out"),
                ),
              );
            },
            child: Text(
              "Logout",
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
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          TextStyle(color: Theme.of(context).colorScheme.primaryFixed),
      unselectedLabelStyle:
          TextStyle(color: Theme.of(context).colorScheme.primaryFixed),
      selectedItemColor: Theme.of(context).colorScheme.primaryFixed,
      unselectedItemColor: Theme.of(context).colorScheme.primaryFixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Navigate to Home
            Navigator.popUntil(context, (route) => route.isFirst);
            break;
          case 1:
            // Navigate to Settings
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
            break;
          case 2:
            // Show logout confirmation
            _showLogoutConfirmation(context);
            break;
        }
      },
    );
  }
}
