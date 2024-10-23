import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/services/login_or_register.dart';
import '../pages/home_page.dart';

//Listens to every state whether signed in or out
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //User is logged in
          if (snapshot.hasData) {
            return const HomePage();
          }
          //User in NOT logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
