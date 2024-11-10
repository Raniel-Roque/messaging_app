import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:Whispr/components/my_button.dart';
import 'package:Whispr/components/my_text_field.dart';
import 'package:Whispr/services/auth/auth_service.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  //Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void signIn(BuildContext context) async {
    // Auth Service
    final authService = AuthService();

    // Helper function to show error dialogs
    void showErrorDialog(String title, String content) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
        ),
      );
    }

    // Get trimmed input values
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Check if any of the fields are empty
    if (email.isEmpty || password.isEmpty) {
      showErrorDialog(
        'Required Fields',
        'Please enter your email and password.',
      );
      _passwordController.clear();
      return;
    }

    // Check if the email format is valid
    if (!EmailValidator.validate(email)) {
      showErrorDialog(
        'Invalid Email',
        'Please enter a valid email address.',
      );
      _passwordController.clear();
      return;
    }

    try {
      // Attempt sign-in with trimmed email and password
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      // Check the error message string for specific cases (User not Found & Invalid Credentials)
      if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential') ||
          e.toString().contains('invalid-email')) {
        showErrorDialog(
          'Incorrect Email or Password',
          'The email or password you entered is incorrect. Please try again.',
        );
      } else {
        showErrorDialog(
          'Sign In Error',
          'An unknown error occurred. Please try again later.',
        );
      }
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Logo
                Icon(
                  Icons.message,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 20),

                //Welcome Back Message
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Whispr",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      TextSpan(
                        text: ":",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primaryFixed,
                        ),
                      ),
                      TextSpan(
                        text: " Connect with your community",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.primaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                //Email TextField
                MyTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false),

                const SizedBox(height: 10),

                //Password TextField
                MyTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true),

                const SizedBox(height: 25),

                //Sign in Button
                MyButton(onTap: () => signIn(context), text: 'Sign In'),

                const SizedBox(height: 15),

                //Not a member? Register Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
