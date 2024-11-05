import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pages/user_pages/home_page.dart';
import '../../pages/admin_pages/admin_page.dart'; // Import the AdminPage
import 'login_or_register.dart';

// Listens to every state whether signed in or out
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is logged in
          if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                  final userData =
                      roleSnapshot.data!.data() as Map<String, dynamic>;
                  final role = userData['role'];

                  // Redirect based on user role
                  if (role == 'admin') {
                    return AdminPage(); // Redirect to AdminPage if role is admin
                  } else {
                    return HomePage(); // Redirect to HomePage for normal users
                  }
                } else {
                  return Center(
                    child: Text('Error fetching user role.'),
                  );
                }
              },
            );
          } else {
            // User is NOT logged in
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
