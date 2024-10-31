import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth/auth_service.dart';
import 'package:email_validator/email_validator.dart';

class RegisterPage extends StatelessWidget {
  final void Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  //Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void signUp(BuildContext context) async {
    final auth = AuthService();

    // Trim whitespace from email and password fields
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Check if any of the fields are empty
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("All fields are required."),
          content:
              Text("Please enter your email, password, and confirm password."),
        ),
      );
      return;
    }

    // Check if the email format is valid
    if (!EmailValidator.validate(email)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Invalid email format!"),
          content: Text("Please enter a valid email."),
        ),
      );
      return;
    }

    // Password strength validation
    final passwordPattern = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[~`!@#\$%\^&\*\(\)\-_+=\{\}\[\]\|\\:;"<>,\./\?]).{8,}$');

    if (!passwordPattern.hasMatch(password)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Weak Password"),
          content: Text(
              "Password must be at least 8 characters long, include at least one uppercase letter, one lowercase letter, one number, and one special character."),
        ),
      );
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      // Show password mismatch dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Passwords don't match!"),
        ),
      );
      return;
    }

    try {
      // Attempt sign-up
      await auth.signUpWithEmailPassword(email, password);
      // Additional logic if needed on successful sign-up, like navigation
    } catch (error) {
      if (error.toString().contains('email-already-in-use')) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('This email is already in use.'),
            content: Text("Please enter a valid email."),
          ),
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('An unknown error occurred.'),
          ),
        );
      }
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

                //Create New Account Message
                Text(
                  "Let's create an account for you!",
                  style: TextStyle(
                    fontSize: 16,
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

                const SizedBox(height: 10),

                //Confirm Password TextField
                MyTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true),

                const SizedBox(height: 25),

                //Sign Up Button
                MyButton(onTap: () => signUp(context), text: 'Sign Up'),

                const SizedBox(height: 15),

                //Have an account? Login Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already a member?'),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        'Login now',
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
