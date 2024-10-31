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

    // Trim whitespace from email and password fields
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Check if any of the fields are empty
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showErrorDialog(
        "All fields are required.",
        "Please enter your email, password, and confirm password.",
      );
      return;
    }

    // Check if the email format is valid
    if (!EmailValidator.validate(email)) {
      showErrorDialog(
        "Invalid email format!",
        "Please enter a valid email.",
      );
      return;
    }

    // Password strength validation
    final passwordPattern = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[~`!@#\$%\^&\*\(\)\-_+=\{\}\[\]\|\\:;"<>,\./\?]).{8,}$');

    if (!passwordPattern.hasMatch(password)) {
      showErrorDialog(
        "Weak Password",
        "Password must be at least 8 characters long, include at least one uppercase letter, one lowercase letter, one number, and one special character.",
      );
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      showErrorDialog(
        "Passwords don't match!",
        "Please ensure both passwords are the same.",
      );
      return;
    }

    try {
      // Attempt sign-up
      await auth.signUpWithEmailPassword(email, password);
    } catch (e) {
      print('Error ${e}');
      //Error Handling (Email is in use & Invalid Email Format (2nd one due to issue with .com))
      if (e.toString().contains('email-already-in-use')) {
        showErrorDialog(
          'This email is already in use.',
          "Please enter a valid email.",
        );
      } else if (e.toString().contains('invalid-email')) {
        showErrorDialog(
          'Invalid Email',
          "Please enter a valid email.",
        );
      } else {
        showErrorDialog(
          'Unknown error occurred.',
          "Please try again later.",
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
